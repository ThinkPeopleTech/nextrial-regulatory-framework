# Working Session Findings

**Repository:** nextrial-regulatory-framework
**Document:** co-development/working-session-findings.md
**Version:** 3.0
**Session 1:** May 14, 2026 — 15 practitioners, 60 minutes
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), acknowledgments and §3.0, §4.3, §5
**AI-Assisted — Human Review Required**

---

## How to read this record

The framework was sharpened through public engagement with regulatory-affairs,
ethics, and clinical-operations practitioners in mid-2026. This record captures the
working session's substantive signals and the polling that prioritized them. The
four signals below are the practitioner contributions the framework paper credits
in its acknowledgments; the risk-stratified validation approach in the paper's
Sections 3.0, 4.3, and 5 reflects them directly. The polling figures are the
session's recorded tallies among the 15 participants.

---

## The four signals

### Signal 1 — The gate that runs on every change is what makes validation real

**Contributor:** Gourav Pandey (Principal Manager, R&D GMP Quality).
**What it changed.** The distinction between an organization that *has* a validation
strategy and one that *has a validated system*: the golden evaluation set is the
artifact, but the continuous-integration gate that runs it on every change, with no
bypass path, is what makes validation real. In the framework this became the rule
that **a certificate the system cannot emit an output without first producing** is
the difference between describing the discipline and being bound by it
([proof-certificate-spec-v3.md](../specs/proof-certificate-spec-v3.md) §4.4 of the
paper; the regression-battery floor in
[continuous-learning-spec-v3.md](../specs/continuous-learning-spec-v3.md) §4).

### Signal 2 — Validation must be commensurate to patient risk

**Contributor:** Paul Hanson (change-control practice).
**What it changed.** Change control and validation rigor should be scaled to patient
risk rather than applied uniformly. This reinforced placing risk classification at
the **design layer** and indexing gate rigor, re-verification cadence, and
attestation to a frozen risk class
([rbqm-pre-verification-spec-v3.md](../specs/rbqm-pre-verification-spec-v3.md) §4).

### Signal 3 — Scope re-test rigor to the risk assessment itself

**Contributor:** Jim Taylor.
**What it changed.** The rigor of re-testing under change should be a function of the
decision's risk class, not a flat policy. This shaped the risk-indexed
re-attestation threshold under continuous learning: high-risk decisions force
supersession and human re-attestation on any material change; lower-risk decisions
permit wider automated variance within the predetermined change envelope
([continuous-learning-spec-v3.md](../specs/continuous-learning-spec-v3.md) §4).

### Signal 4 — Mandatory regression testing as a permanent floor

**Contributor:** Thane Carson.
**What it changed.** A model or adapter update must pass a regression battery against
a fixed evaluation set before it earns a certificate, and that battery is a
permanent floor: risk assessment can raise the bar above it but cannot waive it,
because a small change can alter behavior far from where it was made
([continuous-learning-spec-v3.md](../specs/continuous-learning-spec-v3.md) §4).

---

## Polling (Mentimeter, n = 15)

Quantitative results recorded during the session. Counts sum to the 15
participants; where a question allowed abstention, abstentions are shown.

### Poll 1 — Which open question is the most important to resolve first?

| Option | Votes |
|---|---|
| Who certifies the encoding (Q1) | 8 |
| Risk-taxonomy harmonization (Q3) | 3 |
| Cross-agency standardization (Q2) | 2 |
| Patient equity at the architectural layer (Q4) | 2 |

*Consensus signal:* the encoding-certification question was ranked first by a
majority and now **leads** [open-questions.md](open-questions.md).

### Poll 2 — Is "evidence, not substitution" the right default for the certificate?

| Option | Votes |
|---|---|
| Yes — substitution should be the exception, never the default | 13 |
| Only for lower-risk classes | 2 |
| No | 0 |

*Outcome:* Property 8 defaults to EVIDENCE; substitution is prohibited by
construction for CRITICAL and HIGH.

### Poll 3 — Should attestation collapse to two levels (drop the v1 third level)?

| Option | Votes |
|---|---|
| Yes — two levels (qualified reviewer; responsible PI / delegated equivalent) | 11 |
| Keep three levels | 3 |
| Undecided | 1 |

*Outcome:* attestation resolved to **two** levels in v3.0.

### Poll 4 — How soon is broader cross-jurisdictional acceptance plausible, given a shared framework?

| Option | Votes |
|---|---|
| Plausible within a few years | 9 |
| Longer than a few years | 4 |
| Not foreseeable | 2 |

*Signal:* practitioners rated broader acceptance plausible within a few years,
conditional on a shared framework, and named **standardization itself** as the
single biggest barrier (carried into open question Q5).

---

## Qualitative themes

- **Provenance is where trust lives**, not data readiness — the bi-temporal lineage
  was seen as the operational core, not a footnote.
- **The human-oversight platitude trap** — a signature attests to nothing unless the
  boundary statement says what was and was not checked.
- **Jurisdiction as a first-class dimension** — a new jurisdiction is a new scoped
  ruleset, not a new platform.

---

## New questions surfaced by practitioners

These were raised in discussion and folded into [open-questions.md](open-questions.md):
escalation enforcement and arbitration (Q6), and re-correlation of verification
substrates under co-evolution (Q8).

---

*Acknowledgment reflects participation in the work and does not imply institutional
endorsement. See [contributors.md](contributors.md).*
