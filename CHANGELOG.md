# Changelog

All notable changes to the Regulatory Validation Framework are documented here.
The framework paper, [`papers/regulatory-validation-framework-v3.md`](papers/regulatory-validation-framework-v3.md),
is the source of truth; this changelog tracks the repository artifacts derived from it.

## [3.0.0] — June 2026

FDA-Filing-Aligned Revision. Companion to NexTrial.ai's public comment on FDA
Docket No. FDA-2026-N-4390 (91 FR 23100). This release aligns the repository to
the v3.0 framework paper and the filing.

### Added
- **Framework paper** committed at `papers/regulatory-validation-framework-v3.md`
  as the canonical source of truth (`papers/README.md` points to it).
- **`specs/proof-certificate-spec-v3.md`** — the eight-property proof certificate,
  each property with its admissibility test; Property 4 four-part boundary
  statement; Property 5 named/versioned risk taxonomy; Property 7 ACCEPT/REJECT/ASK
  with challenge, mitigate-and-rerun, override rationale, and escalation
  destination; Property 8 evidence-not-substitution.
- **`specs/site-ai-utilization-disclosure-v3.md`** — two attestation levels.
- **`specs/rbqm-pre-verification-spec-v3.md`** — two-factor pre-gate binding the
  frozen class into Property 5 by taxonomy identifier `nxt-rbqm-risk-taxonomy@1.0`.
- **`specs/continuous-learning-spec-v3.md`** — state binding, predetermined change
  envelope, context of use, two-clocks model, and bi-temporal lineage (paper §5).
- **`reference/proof-certificate.schema.json`** — JSON Schema 2020-12 (artifact A),
  model-architecture-neutral, with the cross-property constraints encoded.
- **`reference/risk-taxonomy-v1.json`** — named, versioned taxonomy.
- **`reference/generate_certificate.py`** + `examples/` — runnable, clean-room
  certificate generator (artifact B).
- **`validation/validate.py`, `run_tests.py`, real fixtures, `test-harness-v3.md`**
  — architecture-neutral conformance checker (artifact C).
- **`lean4/ProofCertificate.lean`** + Lake project — the eight-property certificate
  type and structural properties; `lake build` succeeds.
- **`CODE_OF_CONDUCT.md`**, this `CHANGELOG.md`, and an EU AI Act Articles 9–14
  mapping section in the certificate spec.

### Changed
- **Proof certificate: four properties → eight**, numbered to match the paper and
  the filing exactly.
- **Attestation: three levels → two** (Level 1 qualified reviewer; Level 2
  responsible PI or delegated equivalent). No Level 3.
- **README.md** rewritten to the single v3 eight-property model; three spec
  filename mismatches fixed; README↔spec contradiction resolved.
- **Open questions** restructured and led by the encoding-certification question.

### Security / boundary
- Function-only redactions applied to `BOUNDARY.md`, `setup.sh`, `README.md`, and
  `regulatory-mappings/eu-ai-act.json`; the DRAFT / "do not publish" banner removed
  from `BOUNDARY.md`. A full-tree boundary scan returns zero hits.

### Superseded (retained for historical reference)
- `specs/proof-certificate-spec-v1.md`, `specs/site-ai-utilization-disclosure-v1.md`,
  `specs/rbqm-pre-verification-spec-v1.md`, `validation/test-harness-v1.md`,
  `lean4/proof-properties-v1.md`.

## [1.0.0] — May 2026
- Initial specification set: four-property proof certificate, three-gate
  architecture, RBQM pre-verification, site AI utilization disclosure, adapter
  interface, regulatory mappings, Lean4 type definitions, validation harness.
