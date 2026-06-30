# Validation Test Harness — Reference Test Cases v3.0

**Repository:** nextrial-regulatory-framework
**Document:** validation/TEST-HARNESS-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §4; [specs/proof-certificate-spec-v3.md](../specs/proof-certificate-spec-v3.md)
**AI-Assisted — Human Review Required**

> Supersedes [test-harness-v1.md](test-harness-v1.md).

---

## 1. What this harness is (FDA artifact C)

This is the **architecture-neutral conformance checker**. It validates a *claimed*
proof certificate against (1) the normative JSON Schema and (2) the cross-property
rules the schema cannot express — **with no access to any model, weights, training
data, retrieval corpus, or architectural internal**. A third party can run it
against a certificate without the system that produced it. That is the property
that lets one authority examine another's decision (paper §6.2, §8.1).

| File | Role |
|---|---|
| [`validate.py`](validate.py) | The conformance checker. `check_certificate(cert) -> (ok, reasons)`. |
| [`run_tests.py`](run_tests.py) | The runner. Executes every fixture and compares actual to expected. |
| [`fixtures/`](fixtures/) | 14 real fixtures: conforming and intentionally non-conforming. |
| [`requirements.txt`](requirements.txt) | `jsonschema`, `referencing`. |

It validates against [`../reference/proof-certificate.schema.json`](../reference/proof-certificate.schema.json)
(artifact A) and resolves the risk-class `$ref` to
[`../reference/risk-taxonomy-v1.json`](../reference/risk-taxonomy-v1.json).

## 2. Run it

```bash
pip install -r requirements.txt
python run_tests.py --all
# or check a single certificate:
python validate.py ../reference/examples/evidence-example.json
```

## 3. The checks

**Schema (JSON Schema 2020-12).** All eight properties present, per-property
required fields, enums (P7 outcome ACCEPT/REJECT/ASK; P8 mode EVIDENCE/SUBSTITUTION;
attestation level 1/2), the four boundary sub-objects, and the conditional that
`CRITICAL`/`HIGH` ⇒ mode `EVIDENCE`.

**Cross-property rules (beyond the schema).**
1. Substitution prohibited by construction for CRITICAL/HIGH (Property 8).
2. Minimum attestation level for the frozen class: CRITICAL/HIGH require Level 2
   (an under-attested certificate is rejected).
3. Top-level `result` must agree with the verification-operation result
   (Property 3) — a summary mismatch is rejected.
4. Recorded re-verification cadence (Property 5) must match the taxonomy cadence
   for the frozen class.

## 4. The fixtures

| Fixture | Expect | Exercises |
|---|---|---|
| `valid-certificate-pass` | PASS | Conforming MODERATE/EVIDENCE, operation PASS |
| `valid-certificate-warning` | PASS | REQUIRES_REVIEW determination |
| `valid-certificate-fail` | PASS | FAIL determination (valid certificate of a failed check) |
| `valid-adapter-input-complete` | PASS | Full optional lineage block |
| `valid-adapter-input-minimal` | PASS | Required fields only |
| `rbqm-all-high` | PASS | HIGH, Level 2, daily cadence |
| `rbqm-all-low` | PASS | LOW, Level 1 |
| `rbqm-mixed-high-medium` | PASS | HIGH |
| `rbqm-cold-start-site` | PASS | MODERATE, cold-start sized |
| `invalid-certificate-missing-id` | REJECT | **Missing property** (`certificate_id`) |
| `invalid-certificate-pass-with-critical` | REJECT | **CRITICAL + SUBSTITUTION** (prohibited) |
| `attestation-level-assignments` | REJECT | **Under-attested** (HIGH at Level 1) |
| `invalid-certificate-summary-mismatch` | REJECT | Top-level result ≠ operation result |
| `invalid-adapter-input-unknown-doctype` | REJECT | Unknown enum value (`rule_source`) |

Each fixture is a wrapper `{ "_fixture", "_expect", "_exercises", "certificate" }`.
No real patient data, real protocol content, or anything confidential is included.

## 5. Observed run (verbatim)

```
Running 14 fixtures against the proof-certificate conformance checker

[ok ] attestation-level-assignments              expect=REJECT actual=REJECT  reason: cross-property: HIGH requires attestation level >= 2 but the certificate is attested at level 1 (under-attested)
[ok ] invalid-adapter-input-unknown-doctype      expect=REJECT actual=REJECT  reason: schema: 'UNKNOWN_DOCTYPE' is not one of ['REGULATION', 'PROTOCOL', 'SOP', 'JURISDICTION']
[ok ] invalid-certificate-missing-id             expect=REJECT actual=REJECT  reason: schema: 'certificate_id' is a required property
[ok ] invalid-certificate-pass-with-critical     expect=REJECT actual=REJECT  reason: schema: 'EVIDENCE' was expected
[ok ] invalid-certificate-summary-mismatch       expect=REJECT actual=REJECT  reason: cross-property: top-level result 'PASS' does not match verification-operation result 'FAIL' (summary mismatch)
[ok ] rbqm-all-high                              expect=PASS   actual=PASS
[ok ] rbqm-all-low                               expect=PASS   actual=PASS
[ok ] rbqm-cold-start-site                       expect=PASS   actual=PASS
[ok ] rbqm-mixed-high-medium                     expect=PASS   actual=PASS
[ok ] valid-adapter-input-complete               expect=PASS   actual=PASS
[ok ] valid-adapter-input-minimal                expect=PASS   actual=PASS
[ok ] valid-certificate-fail                     expect=PASS   actual=PASS
[ok ] valid-certificate-pass                     expect=PASS   actual=PASS
[ok ] valid-certificate-warning                  expect=PASS   actual=PASS

Summary: 14/14 fixtures matched their expected outcome
ALL FIXTURES MATCHED EXPECTED OUTCOMES
```

## 6. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | Runnable conformance checker for the eight-property certificate: JSON Schema 2020-12 + cross-property rules; 14 real fixtures replacing the v1 stubs, including the CRITICAL+SUBSTITUTION, under-attested, and missing-property non-conforming cases. |
| 1.0 | May 2026 | Initial harness (superseded). |

---

*This test harness is published under Apache 2.0.*
