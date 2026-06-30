# Papers

## The framework paper (source of truth)

- **[Toward a Regulatory Validation Framework for AI-Assisted Clinical Trial Activation](regulatory-validation-framework-v3.md)**
  — Version 3.0, FDA-Filing-Aligned Revision, June 2026.
  Companion to NexTrial.ai's public comment on FDA Docket No. FDA-2026-N-4390
  (AI-Enabled Optimization of Early-Phase Clinical Trials Pilot Program,
  91 FR 23100, April 29, 2026).

This paper is the canonical source of truth for everything else in the
repository. The specifications, schema, reference implementation, validation
harness, and Lean4 definitions all derive from it and must not contradict it.

### Figures

All four figures are embedded and resolve to assets in [`../assets/`](../assets/):

- Figure 1 — the verification pipeline — `four_layer_verification_stack.svg`
- Figure 2 — uncorrelated evidence — `figure-2-uncorrelated-evidence.svg`
- Figure 3 — worked proof certificate — `figure-3-worked-proof-certificate.svg`
  (illustrative values sourced from `../reference/examples/evidence-example.json`)
- Figure 4 — the change cascade and the two clocks — `figure-4-two-clocks-change-cascade.svg`

The two v1.0 orphan diagrams (`three-gate-architecture-diagram.svg`,
`proof-certificate-schema-diagram.svg`) were removed in PR-9: they depicted the
superseded four-property certificate and three attestation levels with no RBQM
pre-gate, so they contradicted the v3.0 model rather than illustrating it.

## Conference material

- **DIA 2026 Poster** — Abstract ID 116114, Poster Session II, June 16, 2026.
  Abstract: [`../DIA_POSTER_ABSTRACT116114-THOMPSON-STEVEN.pdf`](../DIA_POSTER_ABSTRACT116114-THOMPSON-STEVEN.pdf).

- **CAISc 2026 Submission** — July 24–25, 2026. Pending.

## Published companion writing

- Substack: "Toward a Regulatory Validation Framework for AI-Assisted Clinical Trial Activation and Execution"
  https://open.substack.com/pub/steventhompsonai/p/toward-a-regulatory-validation-framework

- Substack: "Confidence Is Not a Compliance Artifact"
  https://open.substack.com/pub/steventhompsonai/p/confidence-is-not-a-compliance-artifact
