# Three-Gate Verification Architecture Specification v3.0

**Repository:** nextrial-regulatory-framework
**Document:** TGA-SPEC-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §3 (and §3.0)
**Companion to:** NexTrial.ai public comment to FDA Docket No. FDA-2026-N-4390
**AI-Assisted — Human Review Required**

> Supersedes [three-gate-architecture-v1.md](three-gate-architecture-v1.md). The
> v1.0 specification predates the v3.0 certificate model and is retained for
> historical reference. This v3.0 revision aligns the architecture to the framework
> paper and to [proof-certificate-spec-v3.md](proof-certificate-spec-v3.md): an RBQM
> pre-gate that freezes the risk class into Property 5, Gate 3 recording
> ACCEPT/REJECT/ASK, and two attestation levels (no Level 3).

---

## 1. Purpose

This specification describes the verification architecture that produces the proof
certificate: a risk-classification **pre-gate** followed by **three uncorrelated
gates**. It is one architectural choice among possible verification architectures —
an existence proof that a conforming certificate is buildable and runs in practice.
What the framework asks of any system is the **artifact**
([proof-certificate-spec-v3.md](proof-certificate-spec-v3.md)), not this particular
arrangement of components. Any system that emits a conforming certificate satisfies
the standard.

A proposal flows through the pre-gate and the three gates and emerges as a signed
regulated record with a proof certificate attached:

```
AI-assisted proposal
        │
        ▼
┌───────────────────────────────────────────────┐
│ RBQM PRE-GATE  — assigns & freezes the risk    │
│ class (model influence × decision consequence) │
│ → certificate Property 5                       │
└───────────────────────────────────────────────┘
        │
        ▼  Gate 1 — Deterministic compliance verification  → Property 1
        ▼  Gate 2 — Formal structural proof                → Property 3
        ▼  Gate 3 — Human oversight & attestation          → Properties 4, 6, 7, 8
        │
        ▼
Signed regulated record + proof certificate
```

The illustrated pipeline is [Figure 1 of the paper](../assets/four_layer_verification_stack.svg).

---

## 2. The RBQM Pre-Gate: Risk Before Verification

Before a proposal reaches the gates it passes through a risk-based quality
management **pre-gate** (paper §3.0). The pre-gate does not check conformance — it is
not a fourth gate. It **classifies the decision's risk** and freezes that class into
the certificate at decision time, where it becomes **Property 5**.

Classification is two-factor — **model influence × decision consequence**, each
scored high/medium/low — placing the decision into one of four classes (CRITICAL,
HIGH, MODERATE, LOW). The class is recorded under the **named, versioned taxonomy
`nxt-rbqm-risk-taxonomy@1.0`** ([reference/risk-taxonomy-v1.json](../reference/risk-taxonomy-v1.json)),
the same identifier the schema and the Lean type use. Full detail:
[rbqm-pre-verification-spec-v3.md](rbqm-pre-verification-spec-v3.md).

The frozen class **parameterizes** the rest of the pipeline: the rigor applied at
each gate, the re-verification cadence (CRITICAL every certificate; HIGH daily;
MODERATE weekly; LOW at deployment then monthly), and the minimum Gate 3 attestation
level. Because the class is assigned before verification and carried in the
certificate, risk-proportionality is structural, not procedural — a reviewer cannot
accidentally apply low-risk handling to a high-risk decision.

---

## 3. Gate 1 — Deterministic Compliance Verification

The first gate applies the applicable rules, in force at the relevant snapshot
version, to the named source values, and returns a pass/fail determination with
citation precision sufficient for **Property 1**. It is deterministic and is
constrained to compliance verification; its determination is gated by the formal
proof of Gate 2 before it is carried forward.

The gate is **rule-type-agnostic** — a rule is a rule regardless of its source — and
the same operation applies across four sources (paper §3.1):

- **Regulation** — a statutory/regulatory provision, cited to section/subsection.
- **Protocol** — a protocol provision (e.g. an inclusion/exclusion criterion).
- **SOP** — a standard-operating-procedure step.
- **Jurisdiction** — a jurisdiction-specific requirement, applied through the
  jurisdiction-scoped ruleset in force.

What the values are checked against is a composite **standard of record** — the
regulation, the protocol, the data, and the site's capability, taken together — so a
single trustworthiness artifact spans all four sources without a separate evidentiary
regime for each.

---

## 4. Gate 2 — Formal Structural Proof

The second gate is a formal, machine-checkable proof of the structural integrity and
logical form of the determination, deterministic and reproducible, producing a proof
artifact sufficient for **Property 3** (the Lean encoding is
[lean4/ProofCertificate.lean](../lean4/ProofCertificate.lean)).

The honest scope is the source of its strength and the location of its hardest open
question. The proof verifies **structural** properties — required elements present,
references resolve, no structural contradiction, defined boundaries hold — but does
**not** prove that an output is **semantically** correct, that the rule it applied
captures what the regulation intends. A proof can be flawless while the encoding is
wrong, and it will certify the encoded error with complete confidence. Gate 2 does
not eliminate that risk; it **concentrates** it into one inspectable place — the
encoding itself. This is the framework's central open question
([co-development/open-questions.md](../co-development/open-questions.md), Q1).

---

## 5. Gate 3 — Human Oversight and Attestation

The third gate is a qualified human reviewer who evaluates the proposed
determination, the certificate, and the boundary statement. The final regulated
decision is the human's; the certificate is **evidence the reviewer consumes**, not a
decision the reviewer ratifies.

The gate is **interactive**, not a single yes/no. The reviewer records one of exactly
three outcomes in **Property 7**:

- **`ACCEPT`** — accepts the determination.
- **`REJECT`** — rejects the determination.
- **`ASK`** — asks for revision (challenges how a rule was applied, questions a
  value, or sends the decision back).

A REJECT or ASK can drive a **mitigate-and-rerun** loop: the issue is mitigated, the
verification re-run, and the determination converges or escalates. The challenge and
its resolution, any override and its rationale, and any escalation and its
destination are all recorded in Property 7, so the record carries not only what was
decided but why.

### 5.1 Two attestation levels

What the reviewer signs is bound to a defined set of reviewer obligations (the
boundary statement's third part), so the signature is an account of what was checked,
not a checkbox. There are **two** attestation levels (see
[site-ai-utilization-disclosure-v3.md](site-ai-utilization-disclosure-v3.md)):

- **Level 1 — qualified reviewer.** Permitted for MODERATE; sufficient for LOW.
- **Level 2 — responsible principal investigator or delegated equivalent of
  equivalent standing.** Required for CRITICAL and HIGH.

There is **no Level 3**. The output of this gate is a signed regulated record;
Properties 6 through 8 are completed here, with the responsible principal
investigator primary in the allocation of accountability.

---

## 6. Uncorrelated by Design

The three gates are uncorrelated by design — a deterministic rule check, a formal
structural proof, and a human attestation are three substrates whose errors are
unlikely to share a common cause. A rule check can be wrong in a way a structural
proof would catch; a structural proof can pass on a determination a human would
reject; a human can catch what neither machine was scoped to see. A **confidence
score** is the opposite: generated by the same model whose output it scores, it
inherits that output's blind spots — correlated evidence wearing the label of a
check. Under continuous learning, substrates retrained on a common corpus can
silently re-correlate, so the independence of the gates must be actively preserved
and tested over time (paper §5.6).

---

## 7. Structural Boundaries, Not Bolt-On Filters

Governance and anti-manipulation are structural, not added after the fact. The model
in the proposing layer is constrained to non-creative, verifiable operations, so
manipulation sits outside the operating envelope rather than being filtered out
afterward. Three named risks map to three structural controls (paper §3.5):

- **Bad actors** → tamper-evident, cryptographically signed, append-only lineage
  (FIPS-approved hash), independently verifiable.
- **Bad training and drift** → every output verified against jurisdiction ground
  truth, and each output bound to a signed fingerprint of the exact system state;
  divergence halts use until re-certification (see
  [continuous-learning-spec-v3.md](continuous-learning-spec-v3.md)).
- **Overconfidence and hallucination** → a deterministic check rather than model
  confidence; a hallucinated output fails Gate 1 or Gate 2, or is caught at Gate 3,
  and Property 4 declares what was not checked.

A further boundary keeps the attack surface small: the architecture **stores no
documents and captures no patient data beyond what a verification operation
requires.**

---

## 8. What Passes Through the Gates: Site-Triggered Verification and the Multi-Way Match

The gates verify the documents and decisions of a trial across its lifecycle — from
protocol and activation paperwork through consent events and closeout — each checked
at the moment it is produced. Verification is **triggered by the jurisdiction of the
site** an output governs: an output governing a São Paulo site is checked against the
Brazilian ruleset; one governing sites in more than one jurisdiction is checked
against each. A new jurisdiction is a new scoped ruleset, not a new platform.

What each output meets at the gate is a **multi-way match** against the composite
standard of record — the regulation, the protocol, the data, and the site's
capability — all checked together. The **context of use** bounds what the match
warrants, so the certificate carries not only a result but the scope within which it
holds.

---

## 9. The Enforcement Principle: the Certificate Is the Precondition of the Output

What makes each property a control rather than an aspiration is that the architecture
**cannot operate without producing the certificate** (paper §4.4). A specification a
system can decline to honor is a strategy, not a control. A certificate the system
cannot emit an output without first producing is the difference between describing
the discipline and being bound by it. The certificate is not retrieved on request; it
is the precondition of the output. Decisions carry their certificates.

---

## 10. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | RBQM pre-gate freezing the risk class into Property 5 under `nxt-rbqm-risk-taxonomy@1.0`; Gate 3 records ACCEPT/REJECT/ASK with challenge and mitigate-and-rerun; two attestation levels (no Level 3); multi-way match, decisions-carry-certificates, and the enforcement principle aligned to the paper. |
| 1.0 | May 2026 | Initial three-gate specification (superseded). |

---

*This specification is published under Apache 2.0. For the boundary between this open
standard and the NexTrial.ai production implementation, see [BOUNDARY.md](../BOUNDARY.md).*
