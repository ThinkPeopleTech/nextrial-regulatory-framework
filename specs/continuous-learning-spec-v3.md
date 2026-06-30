# Validation Under Continuous Learning Specification v3.0

**Repository:** nextrial-regulatory-framework
**Document:** CL-SPEC-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §5
**AI-Assisted — Human Review Required**

> New in v3.0. This specification develops paper §5, "Validation Under Continuous
> Learning: Proof Binds to a State, Not a Model." It does not introduce any
> mechanism not in the paper.

---

## 1. The Principle

A validation framework for a system that keeps learning must be adaptive in the
same way the system is. The whole of this specification follows from one principle:
**proof binds to a state, not to a model.**

A verification certificate establishes what was true of a specific system state at a
specific time. The moment a system keeps learning after a human attests — through a
model or adapter update, a changed retrieval corpus, a drifted threshold, a revised
prompt or policy, or a new jurisdiction ruleset version — the deployed system
diverges from the certified one. The certificate does not become wrong; it becomes
**stale**, silently. The danger is not a visible error; it is the absence of one.

---

## 2. State and the State Fingerprint (state binding)

A **state** is the full configuration the gates depend on:

- the model or adapter version,
- the retrieval corpus version,
- the decision thresholds,
- the prompt or policy version, and
- the jurisdiction ruleset version.

A change to any of these is a **new state**. Each output is bound to the exact state
in force when it was produced, through a **signed state fingerprint** — a hash of
the certified configuration — recorded in a bi-temporal lineage entry.

**State binding and continuous divergence check.** The running state's fingerprint
is checked **continuously** against the certified fingerprint, and a mismatch
**halts use until re-certification**. Nothing runs uncertified, and nothing runs
against a certificate that does not match it. This is the concrete meaning of "drift
is detected rather than assumed absent." The state fingerprint is carried in the
certificate lineage (`lineage.state_fingerprint` in
[reference/proof-certificate.schema.json](../reference/proof-certificate.schema.json)).

---

## 3. Each Learned State Re-Earns Its Certificate

Learning does not invalidate a prior proof and does not require pretending the
system never changes. It creates a new state, and a new state is a new object that
must earn its own certificate. The prior state's certificate is **superseded, not
deleted**, consistent with the ALCOA+ requirement that records remain enduring and
available. The governing values are frozen into the certificate at decision time, so
an auditor reconstructing a historical decision retrieves the value that was
actually applied then, not whatever a live database holds at audit time. This is
what preserves non-repudiation across time.

---

## 4. The Predetermined Change Envelope

Re-attesting by hand on every state change does not scale, so the framework borrows
and extends the logic of the FDA's **Predetermined Change Control Plan** concept
(finalized December 2024 for AI-enabled device software functions; cited as a
portable analog, not a conformance claim, since the orchestration layer is not a
device). The sponsor pre-specifies the bounds within which a system may learn and
still be considered validated, together with the automated re-verification protocol
that runs within those bounds.

- Learning **inside** the envelope triggers automated re-certification and a lineage
  entry, so the system adapts without a human in the path for every change.
- Learning **outside** the envelope **halts use** pending human re-attestation.
- The certificate records whether a given modification stayed inside the authorized
  envelope, so the boundary itself is inspectable.

**Risk-indexed rigor.** Re-attestation rigor is indexed to the risk class the RBQM
pre-gate assigned and froze into Property 5, under the named, versioned taxonomy
**`nxt-rbqm-risk-taxonomy@1.0`** ([reference/risk-taxonomy-v1.json](../reference/risk-taxonomy-v1.json)).
High-risk (CRITICAL / HIGH) decisions force supersession and human re-attestation on
any material change; lower-risk (MODERATE / LOW) decisions permit wider automated
variance within the envelope. The floor is set by risk class, not by convenience —
this is what prevents alert fatigue without lowering the floor.

**Model/adapter updates.** A model or adapter update is the most consequential state
change and is never certified on inspection alone. A new model state must pass a full
re-verification and a **regression battery against a fixed evaluation set** before it
earns a certificate. That regression battery is a permanent floor: it runs on every
model change, and risk assessment can raise the bar above it but cannot waive it.

---

## 5. Context of Use

Each proof is bounded within a declared **context of use** — the description of
where and for what a given capability is trusted. The context of use bounds what a
verification warrants, so the certificate carries not only a result but the scope
within which that result holds. The validation tier required scales with the stakes
of the context of use (paper §8.3): a low-stakes context carries a lighter tier; the
highest-stakes contexts, including predictive analysis bearing on eligibility, carry
the most demanding tier and the tightest human-oversight requirements.

---

## 6. Two Clocks: Proof and Legitimacy

Proof establishes what was true of a state at a time. It is necessary, and over time
it is not sufficient: even when a running state still matches its certificate, the
rules and standards the certificate referenced can change underneath it. The
framework therefore tracks **two clocks** for any AI-assisted decision.

- **State currency.** Whether the running state still matches its certificate.
  Driven by the system changing; caught by the continuous fingerprint check (§2).
- **Reference currency.** Whether the rules and standards the certificate referenced
  are still in force. Driven by the world changing (a regulation amended, a protocol
  amended, an SOP updated, a standard superseded, a jurisdiction ruleset re-versioned);
  caught by continuous monitoring of the rulesets, protocol provisions, and SOPs each
  certificate referenced.

**Both must hold for an output to be defensible today.** A reference change does not
make the original proof wrong — the certificate remains a valid proof against the
rules in force when the decision was made (which §3 preserves). What a reference
change puts in question is **legitimacy**: whether a decision still in execution
remains compliant under the current rules.

### 6.1 The change cascade

A change of either kind resolves to the same cascade: it propagates to the decisions
that depend on it, re-runs their verification, re-assesses their risk class, and
surfaces re-certification and principal-investigator re-attestation as it happens —
in real time, not at the next scheduled review. From an automatic re-verification
against a changed rule, three things follow:

- **Re-classify.** The re-verification may move the decision into a higher risk class
  under `nxt-rbqm-risk-taxonomy@1.0`, raising the rigor and the attestation level
  required from that point forward.
- **Notify.** Every in-force decision flagged as out of alignment with the current
  rules is surfaced, and the responsible principal investigator is alerted.
- **Request re-certification at a point in time.** A re-certification under the new
  rule is requested, and for high-risk decisions it is forced before execution
  continues. The prior certificate is superseded, not deleted, so both proofs remain
  in the lineage.

---

## 7. Bi-Temporal Lineage

Every entry in the lineage carries **two timestamps**, not one.

- **Valid-time.** When a fact was true, or when a state was in force, in the world.
- **Transaction-time.** When the entry was written to the store.

A single-timeline log conflates the two and cannot distinguish a value recorded at
the time from one inserted or corrected later. Two axes separate them, and that
separation is what lets the lineage answer an **as-of query**: reconstruct a decision
exactly as it stood when made, against the values and rules in force then, regardless
of what the live system holds at audit time.

**Append-only, signed, supersede-not-delete.** Entries are never overwritten. A
correction is a new entry at a new transaction-time, so the prior value remains and
the change is visible as a change. Each entry is signed with a FIPS-approved hash
(SHA-256 under FIPS 180-4 or HMAC-SHA-256 under FIPS 198-1), so any party can verify
independently that a retained record has not been altered, without trusting the
system that produced it. The certificate schema carries `lineage.valid_time`,
`lineage.transaction_time`, `lineage.supersedes_certificate_id`, and
`lineage.certificate_hash`.

---

## 8. The Open Problem: Re-Correlation Under Co-Evolution

The gates work because their substrates fail differently, and continuous learning is
precisely what can erode that. If a proposing model and a verifier are retrained on
the same updated corpus, their failure modes can silently **re-correlate**, and the
uncorrelated-by-design property degrades with no visible signal. Re-certification
under learning must therefore **test explicitly for re-correlation**, not merely
confirm that each gate still passes on its own.

Evidencing the independence of verification substrates over time is, as far as we
know, an open problem — as are how a state is best defined for divergence detection,
and how a change envelope should be specified and approved. These are presented as
open (paper §5.6, §9.1) rather than quietly relied upon.

---

## 9. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | New. State fingerprint / state binding, predetermined change envelope, context of use, two-clocks model (state currency + reference currency), bi-temporal lineage, and the re-correlation open problem — all from paper §5; re-attestation rigor indexed to `nxt-rbqm-risk-taxonomy@1.0`. |

---

*This specification is published under Apache 2.0. For the boundary between this open
standard and the NexTrial.ai production implementation, see [BOUNDARY.md](../BOUNDARY.md).*
