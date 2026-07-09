# Regulatory Adapter Interface Specification v3.0

**Repository:** nextrial-regulatory-framework
**Document:** ADAPTER-SPEC-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §3.1; [specs/proof-certificate-spec-v3.md](proof-certificate-spec-v3.md)
**AI-Assisted — Human Review Required**

> Supersedes [adapter-interface-spec-v1.md](adapter-interface-spec-v1.md). The v1.0
> interface returned a v1 four-property certificate shape with a three-level
> attestation recommendation. This v3.0 revision aligns the adapter to the v3
> eight-property proof certificate ([proof-certificate-spec-v3.md](proof-certificate-spec-v3.md),
> [reference/proof-certificate.schema.json](../reference/proof-certificate.schema.json)):
> a Gate 1 determination that supplies Properties 1–3, a PASS/FAIL/REQUIRES_REVIEW
> result, and two attestation levels.

---

## 1. Purpose

This specification defines the **interface contract** for the jurisdiction-specific,
deterministic regulatory-compliance adapters that perform **Gate 1** of the
verification architecture (the deterministic compliance foundation model, designated
`CFM-1`; see [three-gate-architecture-v3.md](three-gate-architecture-v3.md) §3). It
defines what an adapter must expose, what it accepts as input, and what it returns.

It defines the **interface only**, not how any adapter implements compliance
checking. An adapter **verifies; it does not generate.** Consistent with the
architecture, an adapter is:

- **Deterministic** — same input + same adapter version = same result.
- **Version-controlled** — every adapter version is independently auditable.
- **Independently executable** — runnable standalone, with no access to any model,
  weights, training data, or the broader system.
- **Jurisdiction-specific** — each adapter covers exactly one jurisdiction; a rule is
  a rule regardless of source (regulation, protocol, SOP, jurisdictional requirement).

---

## 2. Adapter Identity

Every adapter declares an identity block:

```json
{
  "adapter_identity": {
    "adapter_id": "string — unique identifier, format: JURISDICTION-DOMAIN-VERSION",
    "jurisdiction": "string — ISO 3166-1 alpha-2 country code or regional code",
    "regulatory_domain": "string — e.g., 'clinical_trial_activation', 'informed_consent'",
    "version": "string — semantic versioning (MAJOR.MINOR.PATCH)",
    "effective_date": "string — ISO 8601 date this version became authoritative",
    "ruleset_snapshot_version": "string — snapshot version of the ruleset applied",
    "supersedes": "string | null — adapter_id this supersedes, or null",
    "regulatory_references": [
      {
        "citation": "string — e.g., '21 CFR 50.25(a)(1)'",
        "description": "string — human-readable description of the cited requirement",
        "effective_date": "string — ISO 8601 date the cited version became effective",
        "last_verified": "string — ISO 8601 date this citation was last confirmed accurate"
      }
    ],
    "developer": "string — organization developing this adapter",
    "contact": "string — contact for questions about this adapter",
    "audit_hash": "string — FIPS-approved hash (e.g. SHA-256) of this adapter's rule set at publication"
  }
}
```

The `ruleset_snapshot_version` and each reference's `citation` + `effective_date`
supply **Property 1 (rule invoked)** of the proof certificate.

---

## 3. Input Schema

Every adapter receives a standardized input object and must not require fields
outside it:

```json
{
  "input": {
    "input_id": "string — UUID, unique per verification request",
    "input_timestamp": "string — ISO 8601 UTC",
    "source_document_type": "string — controlled vocabulary (see 3.1)",
    "structured_content": "object — document content in USDM or equivalent structured representation",
    "protocol_metadata": {
      "protocol_id": "string",
      "version": "string",
      "therapeutic_area": "string",
      "phase": "string — I | II | III | IV | Other",
      "sponsor_id": "string — anonymized identifier"
    },
    "site_metadata": {
      "site_id": "string — anonymized identifier",
      "jurisdiction": "string — ISO 3166-1 alpha-2",
      "site_type": "string — Academic | Community | Network | Other"
    },
    "evaluation_date": "string — ISO 8601 date; fixed date for any expiry checks (never the system clock)",
    "prior_verification_results": [
      { "adapter_id": "string", "result_summary": "string — PASS | FAIL | REQUIRES_REVIEW" }
    ]
  }
}
```

The named values the adapter checks, each attributable to a `field_path` in
`structured_content`, supply **Property 2 (values verified)**.

### 3.1 Source Document Type Vocabulary

`protocol` · `informed_consent_form` · `investigator_brochure` ·
`site_qualification_report` · `regulatory_submission_package` · `irb_application` ·
`clinical_study_report` · `site_activation_checklist`.

---

## 4. Output Schema

An adapter's Gate 1 output is **not** the full proof certificate on its own. It is the
deterministic verification determination that supplies **Properties 1, 2, and 3** of
the eight-property proof certificate; the risk class (**Property 5**) is assigned by
the RBQM pre-gate under the named, versioned taxonomy `nxt-rbqm-risk-taxonomy@1.0`
([reference/risk-taxonomy-v1.json](../reference/risk-taxonomy-v1.json)), and the
human-oversight properties (**4, 6, 7, 8**) are completed at Gate 3. The assembled
certificate conforms to
[reference/proof-certificate.schema.json](../reference/proof-certificate.schema.json).

```json
{
  "output": {
    "adapter_id": "string — matches adapter_identity.adapter_id",
    "adapter_version": "string — matches adapter_identity.version",
    "input_id": "string — matches input_id from the input object",
    "verification_timestamp": "string — ISO 8601 UTC",
    "result": "string — PASS | FAIL | REQUIRES_REVIEW",
    "findings": [
      {
        "finding_id": "string — UUID",
        "severity": "string — CRITICAL | WARNING | INFO",
        "rule_invoked": {
          "rule_source": "string — REGULATION | PROTOCOL | SOP | JURISDICTION",
          "citation": "string — specific provision, section/subsection or criterion",
          "ruleset_snapshot_version": "string",
          "effective_date": "string — ISO 8601 date"
        },
        "predicate": "string — the deterministic predicate evaluated (Property 3)",
        "determination": "string — PASS | FAIL | REQUIRES_REVIEW",
        "field_path": "string — dot-notation path into structured_content (Property 2)",
        "observed_value": "string | number | boolean | null",
        "expected_condition": "string — what the rule requires",
        "rationale": "string — why this determination was reached"
      }
    ],
    "summary": {
      "total_rules_checked": "integer",
      "fail_findings": "integer",
      "review_findings": "integer",
      "pass_findings": "integer"
    },
    "lineage": {
      "source_document_hash": "string — FIPS-approved hash of the input structured content",
      "adapter_rule_hash": "string — hash of the adapter rule set used",
      "verification_environment": "string — description of execution environment"
    },
    "recommended_attestation_level": "integer — 1 | 2 (see SAID-SPEC-001 v3; no Level 3)"
  }
}
```

> **Result mapping.** `result` is `FAIL` if any finding is `FAIL`; otherwise
> `REQUIRES_REVIEW` if any finding is `REQUIRES_REVIEW`; otherwise `PASS`. This is the
> same enum the certificate's Property 3 (`property_3_verification_operation.result`)
> and top-level `result` use, and the conformance checker
> ([validation/validate.py](../validation/validate.py)) enforces top-level/operation
> agreement.

### 4.1 Finding severity

`CRITICAL` and `WARNING` and `INFO` describe the *finding*'s weight for triage. They
do **not** set the certificate's risk class — that is the RBQM pre-gate's role
(Property 5). The adapter never declares a substitution; Property 8 defaults to
EVIDENCE and substitution is prohibited by construction for CRITICAL/HIGH risk
classes at Gate 3.

---

## 5. Determinism Requirements

An adapter must be deterministic: same input + same adapter version ⇒ identical
`result`, identical `findings` (including order), identical `summary`. Adapters must
not make external API calls, use probabilistic/statistical reasoning to classify
findings, incorporate model outputs in the determination logic, or use random seeds.
Time-dependence is permitted for one purpose only — expiry checks against the
`evaluation_date` passed in the input (never the system clock) — with a deterministic
expiration rule and the evaluation date recorded in lineage.

---

## 6. Version Control

Semantic versioning (MAJOR = breaking regulatory change; MINOR = additive rules;
PATCH = clarification/fix with no determination change). Every version is
independently retrievable, carries an `audit_hash` and `effective_date`, and has a
change log. Concurrent version support is required so a past decision can be
re-verified against the ruleset in force when it was made (the certificate lineage
records the version used), consistent with reference-currency tracking in
[continuous-learning-spec-v3.md](continuous-learning-spec-v3.md).

---

## 7. Independence Requirements

- **Structural independence.** Each adapter covers exactly one jurisdiction; it must
  not make determinations for another jurisdiction, reference another adapter's
  ruleset, or combine requirements across jurisdictions. Cross-jurisdiction analysis
  is separate per-jurisdiction invocations.
- **Operational independence.** An adapter runs standalone — without the broader
  system, without any model (LLM, classifier, neural network), without network
  access (regulatory reference data is embedded), and without a UI. An adapter that
  cannot run as a standalone command-line tool against a test input does not satisfy
  this requirement. This is the same architecture-neutrality the conformance harness
  relies on ([validation/validate.py](../validation/validate.py) needs no model
  access to check a certificate).
- **Verification of independence.** Publish a test input set with known expected
  outputs, standalone run instructions, and a hash of the expected outputs per version.

---

## 8. Adapter Registry

Conforming adapters should be registered in
[../regulatory-mappings/adapter-registry.json](../regulatory-mappings/adapter-registry.json)
with `adapter_id`, `jurisdiction`, `regulatory_domain`, `version`, `status`
(Active | Superseded | Deprecated), `repository_path`, `developer`, and `last_verified`.

---

## 9. Reference Implementation and Conformance

The v3 reference layer for this interface lives under
[../reference/](../reference/) and [../validation/](../validation/):

- [reference/proof-certificate.schema.json](../reference/proof-certificate.schema.json)
  — the schema the assembled certificate must satisfy.
- [reference/generate_certificate.py](../reference/generate_certificate.py) — a
  runnable, architecture-neutral generator that emits a conforming certificate from a
  decision descriptor.
- [validation/validate.py](../validation/validate.py) +
  [validation/run_tests.py](../validation/run_tests.py) — the conformance checker that
  validates a claimed certificate against the schema and the cross-property rules,
  with no model access.

Functional compliance adapters for FDA, ANVISA, CDSCO, EU AI Act, and CFM 2.454/2026
are part of the NexTrial.ai production implementation and are out of scope here; see
[BOUNDARY.md](../BOUNDARY.md).

---

## 10. Open Questions

Carried to [co-development/open-questions.md](../co-development/open-questions.md):
third-party **adapter certification** (who certifies conformance), **multi-jurisdiction**
document handling (per-jurisdiction calls vs a rollup), and **regulatory-change lag**
(the interval between a rule changing and an adapter version being updated) — the last
a facet of reference currency (Q8, and continuous-learning §6).

---

## 11. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | Aligned to the eight-property proof certificate: Gate 1 output supplies Properties 1–3; result enum PASS/FAIL/REQUIRES_REVIEW; risk class deferred to the RBQM pre-gate under `nxt-rbqm-risk-taxonomy@1.0`; two attestation levels (no Level 3); rule_source and ruleset snapshot on each finding. |
| 1.0 | May 2026 | Initial interface contract (superseded). |

---

*This specification is published under Apache 2.0. It defines an interface contract —
not an implementation. See [BOUNDARY.md](../BOUNDARY.md) for the boundary between this
open standard and the NexTrial.ai production implementation.*
