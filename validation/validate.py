#!/usr/bin/env python3
"""
Architecture-neutral conformance checker for proof certificates (FDA artifact C).

Validates a *claimed* proof certificate against:

  1. the normative JSON Schema (reference/proof-certificate.schema.json,
     draft 2020-12), and
  2. the cross-property rules that the schema cannot express on its own.

It needs **no access to any model, weights, training data, retrieval corpus, or
architectural internal** — it reads only the certificate JSON and the published
schema/taxonomy. That is the point: a third party can check a certificate without
the system that produced it.

Programmatic use:
    from validate import check_certificate
    ok, reasons = check_certificate(cert_dict)

CLI:
    python validate.py path/to/certificate.json
"""
from __future__ import annotations

import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
SCHEMA_PATH = os.path.join(ROOT, "reference", "proof-certificate.schema.json")
TAXONOMY_PATH = os.path.join(ROOT, "reference", "risk-taxonomy-v1.json")

SUBSTITUTION_PROHIBITED = {"CRITICAL", "HIGH"}
MIN_ATTESTATION = {"CRITICAL": 2, "HIGH": 2, "MODERATE": 1, "LOW": 1}
CADENCE = {
    "CRITICAL": "Every certificate",
    "HIGH": "Daily",
    "MODERATE": "Weekly",
    "LOW": "At deployment, then monthly",
}

_validator = None


def _get_validator():
    global _validator
    if _validator is None:
        from jsonschema import Draft202012Validator
        from referencing import Registry, Resource

        with open(SCHEMA_PATH) as fh:
            schema = json.load(fh)
        with open(TAXONOMY_PATH) as fh:
            taxonomy = json.load(fh)
        registry = Registry().with_resource(
            taxonomy["$id"], Resource.from_contents(taxonomy)
        )
        _validator = Draft202012Validator(schema, registry=registry)
    return _validator


def _schema_errors(cert: dict) -> list[str]:
    validator = _get_validator()
    return [f"schema: {e.message}" for e in sorted(validator.iter_errors(cert), key=str)]


def _cross_property_errors(cert: dict) -> list[str]:
    """Rules beyond the schema's expressive reach."""
    reasons: list[str] = []
    p5 = cert.get("property_5_risk_classification", {})
    p6 = cert.get("property_6_human_reviewer_identity", {})
    p8 = cert.get("property_8_evidence_not_substitution", {})
    p3 = cert.get("property_3_verification_operation", {})
    risk_class = p5.get("risk_class")

    # Rule 1: substitution prohibited by construction for CRITICAL/HIGH.
    if risk_class in SUBSTITUTION_PROHIBITED and p8.get("mode") == "SUBSTITUTION":
        reasons.append(
            f"cross-property: risk class {risk_class} prohibits SUBSTITUTION by construction (Property 8)"
        )

    # Rule 2: minimum attestation level for the frozen class.
    level = p6.get("attestation_level")
    if risk_class in MIN_ATTESTATION and isinstance(level, int):
        if level < MIN_ATTESTATION[risk_class]:
            reasons.append(
                f"cross-property: {risk_class} requires attestation level >= "
                f"{MIN_ATTESTATION[risk_class]} but the certificate is attested at level {level} (under-attested)"
            )

    # Rule 3: top-level result must agree with the verification operation result.
    if "result" in cert and "result" in p3 and cert["result"] != p3["result"]:
        reasons.append(
            f"cross-property: top-level result '{cert['result']}' does not match "
            f"verification-operation result '{p3['result']}' (summary mismatch)"
        )

    # Rule 4: recorded re-verification cadence must match the taxonomy for the class.
    cadence = p5.get("reverification_cadence")
    if risk_class in CADENCE and cadence is not None and cadence != CADENCE[risk_class]:
        reasons.append(
            f"cross-property: re-verification cadence '{cadence}' does not match the "
            f"taxonomy cadence '{CADENCE[risk_class]}' for class {risk_class}"
        )

    return reasons


def check_certificate(cert: dict) -> tuple[bool, list[str]]:
    """Return (conforms, reasons). reasons is empty iff conforms is True."""
    reasons = _schema_errors(cert)
    # Cross-property rules are still meaningful even if some schema errors exist,
    # but we only run them when the basic shape is an object with the key blocks.
    if isinstance(cert, dict):
        reasons += _cross_property_errors(cert)
    return (len(reasons) == 0, reasons)


def main(argv=None) -> int:
    import argparse

    parser = argparse.ArgumentParser(description="Conformance-check a proof certificate.")
    parser.add_argument("certificate", help="path to a certificate JSON file")
    args = parser.parse_args(argv)

    with open(args.certificate) as fh:
        cert = json.load(fh)
    ok, reasons = check_certificate(cert)
    if ok:
        print(f"CONFORMS: {args.certificate}")
        return 0
    print(f"NON-CONFORMING: {args.certificate}")
    for r in reasons:
        print(f"  - {r}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
