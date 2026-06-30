# Lean4 Proof Property Definitions v3.0

**Repository:** nextrial-regulatory-framework
**Document:** LEAN4-PROPS-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §3.2, §4
**AI-Assisted — Human Review Required**

> Supersedes [proof-properties-v1.md](proof-properties-v1.md). The MVP and Phase-2
> structural properties below are carried forward and are now implemented as
> buildable Lean 4 definitions in [`ProofCertificate.lean`](ProofCertificate.lean).

---

## 1. What Lean proves

Gate 2 is a formal, machine-checkable proof of the **structural** integrity and
logical form of a determination (paper §3.2). It verifies that required elements
are present, references resolve, no structural contradiction exists, and defined
boundaries hold. It does **not** prove that an output is semantically correct — that
the rule it applied captures what the regulation intends. A proof can be flawless
while the encoding is wrong; Gate 2 concentrates that risk into one inspectable
place, the encoding itself. This is the framework's central open question (paper §9.1).

## 2. The build

`ProofCertificate.lean` builds with Lake against the toolchain pinned in
[`lean-toolchain`](lean-toolchain) (`leanprover/lean4:v4.31.0`); it is pure Lean 4
core, no Mathlib.

```bash
cd lean4
lake build
```

## 3. The eight-property certificate type

`ProofCertificate.lean` defines:

- the controlled vocabularies for the eight properties — `RuleSource`,
  `OperationResult`, `RiskClass` (the four taxonomy classes), `AttestationLevel`
  (`l1`/`l2`; **no Level 3**), `Outcome` (`accept`/`reject`/`ask`), `Mode`
  (`evidence`/`substitution`);
- the four-part `BoundaryStatement` and its completeness predicate (Property 4);
- the `Certificate` structure carrying all eight properties; and
- `Certificate.wellFormed`, the cross-property conditions the JSON Schema and the
  conformance checker also enforce.

### Theorems (carried by the build)

| Theorem | Statement |
|---|---|
| `critical_no_substitution`, `high_no_substitution` | substitution is not allowed for CRITICAL / HIGH |
| `critical_requires_l2`, `high_requires_l2` | CRITICAL / HIGH require attestation Level 2 |
| `critical_substitution_illformed` | a CRITICAL certificate in SUBSTITUTION mode is never well-formed |
| `l1_under_attests_l2` | Level 1 does not meet a Level 2 minimum |

## 4. Structural properties (carried from v1.0)

Implemented as decidable predicates over a structural `Document`, each with a
worked example that the build checks:

| # | Property | Lean definition |
|---|---|---|
| 1 (MVP) | Field Presence | `fieldPresence` |
| 2 (MVP) | Version Consistency | `versionConsistency` |
| 3 (MVP) | Reference Resolution | `referenceResolution` |
| 4 (Phase 2) | Regulatory Completeness | `regulatoryCompleteness` |
| 5 (Phase 2) | Non-Contradiction | `nonContradiction` |
| 6 (Phase 2) | Temporal Ordering | `temporalOrdering` |

The Phase-2 properties were design intent in v1.0; in v3.0 they are present as
buildable definitions with passing examples.

## 5. Relationship to the certificate

The structural proof result becomes **Property 3 (Verification operation)** of the
proof certificate (PC-SPEC-001 v3). The `wellFormed` conditions mirror the schema's
cross-property constraints, so the Lean layer and the JSON Schema agree.

---

## 6. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | Eight-property certificate type in Lean 4; cross-property well-formedness theorems; MVP + Phase-2 structural properties implemented as buildable decidable predicates; Lake project pinned to v4.31.0. |
| 1.0 | May 2026 | MVP properties defined; Phase-2 documented as design intent (superseded). |

---

*This specification is published under Apache 2.0.*
