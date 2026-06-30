#!/usr/bin/env python3
"""
Reference proof-certificate generator.

Emits a conforming eight-property proof certificate (PC-SPEC-001 v3) from a
compact decision descriptor. This is a clean-room reference implementation:

  * Architecture-neutral. Nothing here references a model, weights, adapters,
    training data, retrieval corpus, or any architectural internal. It assembles
    a certificate from the inputs of a verification *operation* only.
  * Stores no documents and captures no PHI beyond what a verification operation
    requires. Values are recorded as the named scalars a rule was checked
    against, with an attribution chain to source — not the source documents.

It enforces the one cross-property rule the schema also encodes, as an explicit
guard: substitution is unavailable by construction for CRITICAL and HIGH
decisions, so such a certificate is *unproducible* here.

Usage:
    python generate_certificate.py --emit evidence       > cert.json
    python generate_certificate.py --emit substitution   > cert.json
    python generate_certificate.py --input descriptor.json
    python generate_certificate.py --write-examples      # writes examples/

The output is always validated against reference/proof-certificate.schema.json
before it is returned; an invalid certificate raises rather than being emitted.
"""
from __future__ import annotations

import argparse
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SCHEMA_PATH = os.path.join(HERE, "proof-certificate.schema.json")
TAXONOMY_PATH = os.path.join(HERE, "risk-taxonomy-v1.json")

# Substitution is prohibited by construction for these classes (paper §4.3/§4.4).
SUBSTITUTION_PROHIBITED = {"CRITICAL", "HIGH"}

# Cadence and minimum attestation per the named, versioned taxonomy.
TAXONOMY_ID = "nxt-rbqm-risk-taxonomy"
TAXONOMY_VERSION = "1.0"
CADENCE = {
    "CRITICAL": "Every certificate",
    "HIGH": "Daily",
    "MODERATE": "Weekly",
    "LOW": "At deployment, then monthly",
}
MIN_ATTESTATION = {"CRITICAL": 2, "HIGH": 2, "MODERATE": 1, "LOW": 1}


class UnproducibleCertificate(ValueError):
    """Raised when the requested certificate cannot exist by construction."""


def _load_validator():
    """Build a Draft 2020-12 validator with the taxonomy resource registered."""
    from jsonschema import Draft202012Validator
    from referencing import Registry, Resource

    with open(SCHEMA_PATH) as fh:
        schema = json.load(fh)
    with open(TAXONOMY_PATH) as fh:
        taxonomy = json.load(fh)
    registry = Registry().with_resource(
        taxonomy["$id"], Resource.from_contents(taxonomy)
    )
    return Draft202012Validator(schema, registry=registry)


def build_certificate(d: dict) -> dict:
    """Assemble a full eight-property certificate from a compact descriptor.

    The descriptor carries only operation-level facts. See examples/ for the two
    canonical descriptors used by --emit.
    """
    risk_class = d["risk_class"]
    mode = d.get("mode", "EVIDENCE")

    if mode == "SUBSTITUTION" and risk_class in SUBSTITUTION_PROHIBITED:
        raise UnproducibleCertificate(
            f"substitution is unavailable by construction for {risk_class} "
            f"decisions; this certificate cannot be produced"
        )

    cert = {
        "certificate_id": d["certificate_id"],
        "certificate_version": "3.0",
        "generation_timestamp": d["timestamp"],
        "determination_context": {
            "determination_type": d["determination_type"],
            "jurisdiction": d["jurisdiction"],
            "phase": d.get("phase", "ACTIVATION"),
        },
        "property_1_rule_invoked": {
            "rule_source": d["rule_source"],
            "citation": d["citation"],
            "ruleset_snapshot_version": d["ruleset_snapshot_version"],
            "effective_date": d["effective_date"],
        },
        "property_2_values_verified": {"values": d["values"]},
        "property_3_verification_operation": {
            "operation_id": d["operation_id"],
            "operation_version": d.get("operation_version", "1.0"),
            "predicate": d["predicate"],
            "inputs": d.get("inputs", []),
            "result": d["operation_result"],
            "deterministic": True,
        },
        "property_4_boundary_statement": {
            "verified_scope": {"rules_evaluated": d["verified_scope"]},
            "reserved_scope": {"factors": d["reserved_scope"]},
            "reviewer_obligations": {"obligations": d["reviewer_obligations"]},
            "escalation_criteria": {
                "conditions": d["escalation_conditions"],
                "destination": d["escalation_destination"],
            },
        },
        "property_5_risk_classification": {
            "risk_class": risk_class,
            "taxonomy_id": TAXONOMY_ID,
            "taxonomy_version": TAXONOMY_VERSION,
            "frozen_at": d["timestamp"],
            "gate_rigor": d.get("gate_rigor", "standard"),
            "reverification_cadence": CADENCE[risk_class],
        },
        "property_6_human_reviewer_identity": {
            "reviewer_name": d["reviewer_name"],
            "reviewer_role": d["reviewer_role"],
            "attestation_level": d["attestation_level"],
            "attestation_binding": d["attestation_binding"],
        },
        "property_7_override_and_escalation": d["override_and_escalation"],
        "property_8_evidence_not_substitution": _build_p8(mode, d),
        "result": d["result"],
    }
    if "lineage" in d:
        cert["lineage"] = d["lineage"]

    # Guard: minimum attestation level must be met for the frozen class.
    if cert["property_6_human_reviewer_identity"]["attestation_level"] < MIN_ATTESTATION[risk_class]:
        raise UnproducibleCertificate(
            f"{risk_class} requires attestation level >= {MIN_ATTESTATION[risk_class]}"
        )

    _validate(cert)
    return cert


def _build_p8(mode: str, d: dict) -> dict:
    p8 = {
        "mode": mode,
        "declaration": d.get(
            "declaration",
            "This operation is evidence presented to the reviewer, not a "
            "substitution for the reviewer's independent judgment.",
        ),
    }
    if mode == "SUBSTITUTION":
        p8["substitution_authorized"] = True
        p8["declaration"] = d.get(
            "declaration",
            "Substitution authorized for this MODERATE/LOW decision under "
            "Property 8; the verification burden is relocated and made "
            "inspectable, not removed.",
        )
    return p8


def _validate(cert: dict) -> None:
    validator = _load_validator()
    errors = sorted(validator.iter_errors(cert), key=str)
    if errors:
        msgs = "\n".join(f"  - {e.message}" for e in errors)
        raise UnproducibleCertificate(
            "generated certificate does not conform to the schema:\n" + msgs
        )


# --------------------------------------------------------------------------- #
# Canonical demo descriptors (deterministic; no PHI; illustrative values only) #
# --------------------------------------------------------------------------- #

EVIDENCE_DESCRIPTOR = {
    "certificate_id": "cert-evidence-0001",
    "timestamp": "2026-06-30T12:00:00Z",
    "determination_type": "eligibility_criterion",
    "jurisdiction": "US",
    "phase": "ACTIVATION",
    "rule_source": "PROTOCOL",
    "citation": "Protocol AMG-301 v2.1, Section 7.3.2, Inclusion Criterion 3 (HbA1c)",
    "ruleset_snapshot_version": "AMG-301-v2.1",
    "effective_date": "2026-04-01",
    "values": [
        {
            "value_id": "v1",
            "label": "HbA1c",
            "observed_value": 7.2,
            "unit": "%",
            "threshold_or_condition": "< 9.0",
            "source_origin": "labs.hba1c (Central Lab report reference)",
            "acquisition_timestamp": "2026-04-15T09:00:00Z",
            "attribution_chain": ["Central Lab report reference", "labs.hba1c"],
        }
    ],
    "operation_id": "op-evidence-1",
    "predicate": "hba1c < 9.0",
    "inputs": [{"label": "hba1c", "value": 7.2, "source_value_id": "v1"}],
    "operation_result": "PASS",
    "verified_scope": ["Inclusion Criterion 3 numeric threshold (HbA1c < 9.0)"],
    "reserved_scope": [
        "clinical interpretation of concurrent medications affecting HbA1c",
        "contraindications not captured by the eligibility criteria",
    ],
    "reviewer_obligations": [
        "confirm the lab value against the source report",
        "confirm no reserved-scope factor applies",
    ],
    "escalation_conditions": ["observed value within 5% of the threshold"],
    "escalation_destination": "Medical Monitor",
    "risk_class": "MODERATE",
    "gate_rigor": "standard",
    "reviewer_name": "Reviewer A",
    "reviewer_role": "Qualified Reviewer",
    "attestation_level": 1,
    "attestation_binding": "sig:sha256:evidence-binding-ref",
    "override_and_escalation": {
        "outcome": "ACCEPT",
        "challenge": {"raised": False},
        "override": {"occurred": False},
        "escalation": {"criteria_met": False},
    },
    "mode": "EVIDENCE",
    "result": "PASS",
    "lineage": {
        "state_fingerprint": "sha256:state-fingerprint-evidence",
        "valid_time": "2026-06-30T12:00:00Z",
        "transaction_time": "2026-06-30T12:00:01Z",
        "supersedes_certificate_id": None,
        "certificate_hash": "sha256:certificate-hash-evidence",
    },
}

SUBSTITUTION_DESCRIPTOR = {
    "certificate_id": "cert-substitution-0001",
    "timestamp": "2026-06-30T12:05:00Z",
    "determination_type": "regulatory_document_completeness",
    "jurisdiction": "US",
    "phase": "ACTIVATION",
    "rule_source": "SOP",
    "citation": "SOP-DM-014 step 4: Form FDA 1572 box 1 (name and address) present",
    "ruleset_snapshot_version": "SOP-DM-014-r3",
    "effective_date": "2026-03-01",
    "values": [
        {
            "value_id": "v1",
            "label": "form_1572_box_1_present",
            "observed_value": True,
            "threshold_or_condition": "must be present and non-empty",
            "source_origin": "submission.form_1572.box_1 (field-presence check)",
            "acquisition_timestamp": "2026-06-30T12:04:00Z",
            "attribution_chain": ["submission package index", "form_1572.box_1"],
        }
    ],
    "operation_id": "op-substitution-1",
    "predicate": "present(form_1572.box_1)",
    "inputs": [{"label": "form_1572_box_1_present", "value": True, "source_value_id": "v1"}],
    "operation_result": "PASS",
    "verified_scope": ["presence of Form FDA 1572 box 1 per SOP-DM-014 step 4"],
    "reserved_scope": ["substantive correctness of the address content"],
    "reviewer_obligations": [
        "confirm the substitution authorization is appropriate for this LOW/MODERATE administrative check"
    ],
    "escalation_conditions": ["any presence check returns ABSENT"],
    "escalation_destination": "Regulatory Affairs Lead",
    "risk_class": "LOW",
    "gate_rigor": "light",
    "reviewer_name": "Reviewer B",
    "reviewer_role": "Qualified Reviewer",
    "attestation_level": 1,
    "attestation_binding": "sig:sha256:substitution-binding-ref",
    "override_and_escalation": {
        "outcome": "ACCEPT",
        "challenge": {"raised": False},
        "override": {"occurred": False},
        "escalation": {"criteria_met": False},
    },
    "mode": "SUBSTITUTION",
    "declaration": (
        "Substitution authorized for this LOW administrative presence check under "
        "Property 8. The human verification burden is relocated and made "
        "inspectable, not removed. Substitution is unavailable for CRITICAL/HIGH."
    ),
    "result": "PASS",
    "lineage": {
        "state_fingerprint": "sha256:state-fingerprint-substitution",
        "valid_time": "2026-06-30T12:05:00Z",
        "transaction_time": "2026-06-30T12:05:01Z",
        "supersedes_certificate_id": None,
        "certificate_hash": "sha256:certificate-hash-substitution",
    },
}

DESCRIPTORS = {"evidence": EVIDENCE_DESCRIPTOR, "substitution": SUBSTITUTION_DESCRIPTOR}


def write_examples() -> None:
    out_dir = os.path.join(HERE, "examples")
    os.makedirs(out_dir, exist_ok=True)
    for name, descriptor in DESCRIPTORS.items():
        cert = build_certificate(descriptor)
        path = os.path.join(out_dir, f"{name}-example.json")
        with open(path, "w") as fh:
            json.dump(cert, fh, indent=2)
            fh.write("\n")
        print(f"wrote {path} (validated PASS)")


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Reference proof-certificate generator.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--emit", choices=sorted(DESCRIPTORS), help="emit a canonical example to stdout")
    group.add_argument("--input", help="path to a decision descriptor JSON")
    group.add_argument("--write-examples", action="store_true", help="write examples/*.json")
    args = parser.parse_args(argv)

    if args.write_examples:
        write_examples()
        return 0

    if args.emit:
        descriptor = DESCRIPTORS[args.emit]
    else:
        with open(args.input) as fh:
            descriptor = json.load(fh)

    try:
        cert = build_certificate(descriptor)
    except UnproducibleCertificate as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 2
    json.dump(cert, sys.stdout, indent=2)
    sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
