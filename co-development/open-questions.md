# Open Questions — Active Co-Development

**Repository:** nextrial-regulatory-framework
**Document:** co-development/open-questions.md
**Version:** 3.0
**Last Updated:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §9
**AI-Assisted — Human Review Required**

---

## How this document works

These are the questions the framework cannot yet answer with confidence. They are
not oversights — they are the honest edges of the current specification. The most
important section of a framework offered for co-development is the one that states
honestly what it has not closed, and the first question below is the one the
framework most wants help with.

---

## Q1 — Who certifies the encoding (the central open question)

**Status:** Open — the framework's principal unsolved problem
**Origin:** Framework paper §9.1; Gate 2 scope (§3.2)
**Document:** [specs/proof-certificate-spec-v3.md](../specs/proof-certificate-spec-v3.md); [lean4/proof-properties-v3.md](../lean4/proof-properties-v3.md)

**The question.** A regulation is human-language prose. A verification operation is
a computable check. Between them sits a translation. When a regulation is encoded
into a computable check, **who certifies that the encoding is faithful, and who is
accountable when the check is structurally perfect and semantically wrong?** A
proof can be flawless and still certify an error, because the proof operates on the
encoding, not on the regulation the encoding was meant to capture.

**The risk takes three forms.**
1. **A threshold drifts from intent.** The encoded number stops matching what the
   regulation meant, while the check continues to pass.
2. **Rules correct in isolation interact wrongly.** Each encoded check is right on
   its own; together they produce a determination none of them intended.
3. **An encoding is outdated or jurisdictionally mismatched.** The rule has moved,
   or the wrong jurisdiction's encoding has been applied, and nothing in the
   structure reveals it.

**Current position.** Gate 2 does not eliminate this risk; it **concentrates** it
into one inspectable place — the encoding itself — rather than diffusing it through
a probabilistic system where it cannot be found. The encoding becomes the object
certification effort should focus on. A standard worth adopting is one whose hardest
question was named before it was set.

**One partial candidate answer.** The proof certificate can be bound to an
already-adopted data standard — represented as a native extension of the Unified
Study Definitions Model on a USDM ExtensionClass — so machine-interpretability
across jurisdictions becomes a consequence of the binding. This addresses
interpretability and binding; it does not by itself certify that the encoding
captured the regulation's intent, which remains open. (Contributed by Jessica
Stuyvenberg, Stuyvenberg Advisory Group, drawing on the ARCH Framework, CC BY 4.0.)

---

## Q2 — Cross-agency proof-certificate standardization

**Status:** Open
**Origin:** Framework paper §9.2

What minimum property set would regulators — beginning with the FDA, the EU,
ANVISA, and the CDSCO, and extending to any agency willing to participate — agree
to accept, and how should a certificate be presented to a reviewer without
formal-methods expertise? More than one multi-property schema now exists in the
field; identifying a common interoperability pathway among them, including at the
clinical-trial data-representation layer, is a standardization question, not a
settled one.

---

## Q3 — Risk taxonomy harmonization

**Status:** Open
**Origin:** Framework paper §9.3
**Document:** [reference/risk-taxonomy-v1.json](../reference/risk-taxonomy-v1.json) (`nxt-rbqm-risk-taxonomy@1.0`)

The four-class taxonomy is a proposed baseline. A shared taxonomy across the FDA,
the EU, ANVISA, and the CDSCO is the foundation the entire cross-jurisdictional
structure rests on, because if risk classification is the architectural primitive,
a harmonized taxonomy is what every jurisdiction's rigor and cadence index to. It
does not yet exist. What process should produce it, and which body should convene
that process, is open.

---

## Q4 — Patient equity at the architectural layer

**Status:** Open — most in need of biostatistical and fairness-research input
**Origin:** Framework paper §9.4

For predictive analysis bearing on eligibility, the procedural layer is addressable
through escalation and the boundary statement. The architectural layer is harder:
whether a demographic-accuracy disparity should be handled by disclosing it, by
defining formal bias boundaries (a verifiable boundary that no protected attribute
exerted undue influence on a specific prediction beyond clinically justified
thresholds), or — if the disparity proves structured rather than random — by a
conditional combination decided in advance. Where those thresholds are drawn should
be co-developed with regulatory affairs, bioethics review, and patient-community
engagement.

---

## Q5 — Cross-jurisdictional mutual recognition

**Status:** Open
**Origin:** Framework paper §8.1, §9.5

The reliance pathway shows the mechanism exists in at least one corridor, where one
authority can rely on another's assessment rather than duplicate it. Practitioners
have rated broader cross-jurisdictional acceptance as plausible within a few years,
conditional on a shared framework, while identifying standardization itself as the
single biggest barrier. The open question is concrete: what standardization steps
move mutual recognition from plausible-in-principle to operational-in-practice, and
which body convenes them.

---

## Q6 — Escalation enforcement and arbitration

**Status:** Open
**Origin:** Framework paper §9.6
**Document:** [specs/site-ai-utilization-disclosure-v3.md](../specs/site-ai-utilization-disclosure-v3.md) §5 (Property 7)

Property 7 records escalation, and a real-time service-level agreement is one
mechanism for enforcing it. Making that real raises questions the framework does
not resolve: who arbitrates a breach when a sponsor and a site disagree on whether
the agreement was met, and what aggregate signal — how many breaches, of what
severity, over what window — should rise from a private contractual matter to one
that warrants regulatory attention.

---

## Q7 — Mapping to the Predetermined Change Control Plan

**Status:** Open
**Origin:** Framework paper §9.7
**Document:** [specs/continuous-learning-spec-v3.md](../specs/continuous-learning-spec-v3.md) §4

The Predetermined Change Control Plan framework governs change to AI-enabled device
software functions. How proof certificates should map onto it is open: when a model
or adapter is updated, what proof-certificate evidence the plan should require from
the prior and the updated state, and how the change's risk class determines that
requirement. The continuous-learning spec proposes the envelope-and-regression
structure; its formal mapping to the plan is co-development work.

---

## Q8 — Re-correlation of verification substrates under co-evolution

**Status:** Open
**Origin:** Framework paper §5.6
**Document:** [specs/continuous-learning-spec-v3.md](../specs/continuous-learning-spec-v3.md) §8

The gates work because their substrates fail differently, and continuous learning
is precisely what can erode that. If a proposing model and a verifier are retrained
on the same updated corpus, their failure modes can silently re-correlate, and the
uncorrelated-by-design property degrades with no visible signal. Evidencing the
independence of verification substrates over time is, as far as we know, an open
problem — as are how a state is best defined for divergence detection and how a
change envelope should be specified and approved.

---

## Carried-forward implementation questions (v1.0)

These narrower questions from the v1.0 specifications remain active and feed the
questions above:

- **Cold-start in RBQM** ([rbqm-pre-verification-spec-v3.md](../specs/rbqm-pre-verification-spec-v3.md) §6) — the minimum data for confident model-influence / decision-consequence scoring at new sites, novel protocols, and rare populations.
- **Rubber-stamp prevention** ([site-ai-utilization-disclosure-v3.md](../specs/site-ai-utilization-disclosure-v3.md) §6) — distinguishing substantive review from a perfunctory sign-off in the audit trail.
- **Adapter certification** ([adapter-interface-spec-v1.md](../specs/adapter-interface-spec-v1.md)) — whether and how third-party adapters are certified for conformance.

---

## Resolved in v3.0

- **Proof-certificate property count.** The four-property / eight-property
  inconsistency between the README and the spec is resolved: the certificate has
  **eight** properties, numbered to match the paper and the filing.
- **Attestation levels.** Resolved to **two** (Level 1 qualified reviewer; Level 2
  responsible PI or delegated equivalent); the v1.0 third level is superseded.
- **Validation under continuous learning.** Specified in
  [continuous-learning-spec-v3.md](../specs/continuous-learning-spec-v3.md):
  proof binds to a state, not a model.

---

*Open questions are the honest edge of what we know. Contributing your expertise
here is how the standard gets stronger.*
