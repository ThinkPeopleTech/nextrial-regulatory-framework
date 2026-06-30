# For Engineers: How to Read This Repository

This repository is the open standard for AI-assisted clinical trial activation verification (Apache 2.0). It is the companion to a comment filed on FDA Docket FDA-2026-N-4390. This guide is the fastest path to understanding it well enough to reason about, critique, and extend it.

## What this repository is (and is not)

This repository is a **standard**, not a product.

- It defines **what must be true** of an AI-assisted verification: the proof certificate a decision must carry, the gates a decision must pass, and the formal properties that can be proven about it.
- It does **not** contain a production system. Any orchestration layer or predictive eligibility layer that implements this standard is a separate concern; what lives here is the contract those implementations must satisfy.

Read it as a specification with a runnable reference implementation, a conformance harness, and a formal model — not as an application.

## The mental model

An AI-assisted proposal is never the final word. It flows through a pre-gate that assigns and freezes a risk class, then through three independent verification gates, and the human decides. Every decision emits a **proof certificate**: a deterministic, independently checkable record of what was verified, against which authority, by whom, and what the human reserved.

The certificate is **evidence presented to a human reviewer, not a substitute for the reviewer's judgment.** That single commitment shapes the entire design.

## Reading order

1. **`papers/regulatory-validation-framework-v3.md`** — the framework paper. The why, the full argument, and the four figures. Start here.
2. **`specs/proof-certificate-spec-v3.md`** — the eight-property proof certificate, each property with an admissibility test, and the four-part boundary statement. This is the keystone.
3. **`specs/three-gate-architecture-v3.md`** — the RBQM pre-gate and the three gates: regulatory verification, formal structural proof, and human attestation (ACCEPT / REJECT / ASK).
4. **`specs/rbqm-pre-verification-spec-v3.md`** — how the risk class is assigned and frozen, and how it parameterizes verification rigor and re-verification cadence.
5. **`specs/continuous-learning-spec-v3.md`** — state binding, the two-clocks model, and the predetermined change envelope: why a once-defensible decision can stop being defensible.
6. **`specs/site-ai-utilization-disclosure-v3.md`** — the two attestation levels and what each reviewer owes.
7. **`reference/proof-certificate.schema.json`** and **`reference/risk-taxonomy-v1.json`** — the machine-readable schema and the named, versioned risk taxonomy it references.
8. **`reference/generate_certificate.py`** with **`reference/examples/`** — a runnable reference generator and worked EVIDENCE and SUBSTITUTION certificates.
9. **`validation/validate.py`**, **`validation/run_tests.py`**, **`validation/fixtures/`** — the architecture-neutral conformance harness. Run `python validation/run_tests.py --all` and watch it accept conforming certificates and reject the ones that break the rules.
10. **`lean4/ProofCertificate.lean`** and **`lean4/proof-properties-v3.md`** — the formal model. The eight-property certificate type, the cross-property well-formedness theorems, and the structural properties as decidable predicates.
11. **`co-development/open-questions.md`** — the live frontier. Question 1 (who certifies the encoding) is the framework's central unsolved problem; this is where the interesting work is.

A productive first pass is items 1–3 for the model, then 7–10 to see the model made runnable and provable.

## The three gates, briefly

- **Gate 1 — regulatory verification.** A jurisdiction-specific, deterministic check (designated `CFM-1`) answering one question: does this output satisfy the target jurisdiction's regulatory requirements? It verifies; it does not generate.
- **Gate 2 — formal structural proof.** A `Lean4` proof of structural properties (field presence, version consistency, reference resolution, and more). A proof that succeeds or fails — not a confidence score.
- **Gate 3 — human oversight.** A qualified reviewer or the responsible principal investigator records ACCEPT, REJECT, or ASK, with any challenge and its resolution. The upstream gates inform this decision; they never replace it.

A risk class assigned by the RBQM pre-gate, frozen at decision time, governs how much rigor each gate applies and how often the decision is re-verified.

## The proof certificate

Eight properties, each independently testable: rule invoked, values verified, verification operation, boundary statement (in four parts: verified scope, reserved scope, reviewer obligations, escalation criteria), risk classification, human reviewer identity, override and escalation record, and the explicit declaration that the certificate is evidence and not a substitution. Figure 3 in the paper is a worked example; `reference/examples/evidence-example.json` is the same thing in machine-readable form.

A structural invariant worth internalizing early: a `CRITICAL` or `HIGH` risk decision **cannot** be declared a substitution. The schema rejects it, the reference generator cannot produce it, and the Lean model proves it ill-formed.

## The formal layer, and where it goes

What is proven today: the certificate type is well-formed, the cross-property invariants hold (a critical decision cannot substitute; attestation floors are enforced), and the MVP and Phase-2 structural properties are implemented as buildable decidable predicates, with no admitted proofs.

What is open: the structural and well-formedness layer is settled; the frontier is formalizing a wider range of verification operations and richer regulatory-completeness properties, and connecting the formal model to the artifacts real decisions actually produce. If you came here to push formal verification forward, this is the surface to push on. Build the Lake project (`lean4/`, toolchain pinned) and start from the existing theorems.

## The boundary

Everything in this repository is open under Apache 2.0. Proprietary implementations — orchestration internals, the predictive eligibility layer's implementation, functional adapter internals, and model artifacts — are out of scope here by design; see `BOUNDARY.md`. When you reason about the standard, reason about the contract, not any one implementation of it.

## Contributing

See `CONTRIBUTING.md` and `co-development/open-questions.md`. The most valuable contributions sharpen the open questions, strengthen the formal model, or stress-test the conformance harness with certificates that should not pass.
