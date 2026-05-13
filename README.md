# Regulatory Validation Framework for AI in Clinical Trials

**An open standard for how AI systems in clinical trials get verified.**

---

> *The standard is open. The implementation is NexTrial's.*

---

## What This Is

Clinical trial AI is being deployed faster than the regulatory guidance governing it. The result is inconsistent, undocumented, and often unauditable practice — varying by sponsor, CRO, site, and jurisdiction.

This repository publishes a formal specification for how AI outputs in clinical trial activation and execution should be verified. It defines the architecture, the proof artifacts, the human oversight protocol, and the regulatory mappings — as an open standard that any implementer can adopt, challenge, and extend.

The framework is built on one foundational principle:

**A regulated clinical decision must be reconstructible — source data, decision logic, and rule application — at the moment an inspector asks for it.**

Confidence scores cannot do this. Proof certificates can.

---

## The Framework at a Glance

### Four-Layer Verification Stack

```
┌──────────────────────────────────────────────────────┐
│  LAYER 0: RBQM Pre-Verification                      │
│  "Should this activation proceed?"                   │
│  Site risk · Protocol risk · Population risk         │
└──────────────────────────┬───────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────┐
│  GATE 1: Regulatory Compliance Verification          │
│  "Is this output compliant?"                         │
│  Jurisdiction-specific adapters · Deterministic      │
└──────────────────────────┬───────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────┐
│  GATE 2: Formal Mathematical Proof (Lean4)           │
│  "Can we prove structural correctness?"              │
│  Binary pass/fail · Under 100ms · Auditable          │
└──────────────────────────┬───────────────────────────┘
                           │
┌──────────────────────────▼───────────────────────────┐
│  GATE 3: Human Oversight                             │
│  "Does the qualified human agree?"                   │
│  Three attestation levels · Override protocol        │
└──────────────────────────────────────────────────────┘
```

### Proof Certificate

Every AI output subject to this framework produces a **proof certificate** — a structured, immutable artifact containing four properties:

1. **Rule Invoked** — which specific regulatory requirement was checked
2. **Observed Value** — what the system found in the source document
3. **Determination** — compliant / non-compliant / requires review
4. **Lineage Trace** — the complete path from source data to determination

The certificate is reconstructable under inspection. This is the difference between compliance-grade verification and a confidence score.

### The Three-Second Test

Hand the proof certificate to an inspector. Ask: *"Can you reconstruct this decision from this artifact alone?"*

If yes — it satisfies the framework.  
If no — it is not a compliance artifact. It is a metric.

---

## Repository Structure

```
nextrial-regulatory-framework/
│
├── README.md                          ← This file
├── BOUNDARY.md                        ← What is open vs. protected
├── CONTRIBUTING.md                    ← How to co-develop this standard
├── LICENSE                            ← Apache 2.0
│
├── /specs
│   ├── proof-certificate-spec-v1.md   ← Four-property proof certificate
│   ├── three-gate-architecture-v1.md  ← The canonical architecture
│   ├── rbqm-pre-verification-v1.md    ← Risk-based pre-verification layer
│   ├── site-ai-disclosure-v1.md       ← PI attestation and oversight
│   └── adapter-interface-v1.md        ← Regulatory adapter interface contract
│
├── /regulatory-mappings
│   ├── us-fda.json                    ← FDA: 21 CFR Parts 11, 50, 54, 56, 312
│   ├── brazil-anvisa.json             ← ANVISA: Lei 14.874, RDC 945, LGPD, CFM 2.454
│   ├── india-cdsco.json               ← CDSCO: NDCTR 2019, DPDP Act 2023
│   ├── eu-ai-act.json                 ← EU AI Act 2024/1689 Articles 9–17
│   └── adapter-registry.json          ← Registry of conforming adapters
│
├── /lean4
│   ├── proof-properties-v1.md         ← What gets proven (not how)
│   └── type-definitions-v1.lean       ← Lean4 type definitions
│
├── /validation
│   ├── test-harness-v1.md             ← Reference test cases
│   ├── /fixtures                      ← Test input/output pairs
│   └── /reference-adapter             ← Schema validator (not a compliance adapter)
│
├── /co-development
│   ├── open-questions.md              ← Six unresolved questions — input welcome
│   ├── dominique-critique-response.md ← Adversarial review: 8 points, 3+3+3 analysis
│   ├── working-session-findings.md    ← Practitioner working session output
│   └── contributors.md               ← With gratitude
│
└── /assets
    ├── four-layer-stack-diagram.svg
    ├── three-gate-architecture-diagram.svg
    └── proof-certificate-schema-diagram.svg
```

---

## What Is Open

Everything in this repository is open: the architecture specification, the proof certificate schema, the regulatory mapping tables, the attestation protocol, the adapter interface contract, the Lean4 property definitions, the validation test harness.

The standard belongs to the industry.

## What Is Protected

The production implementations that satisfy this standard — the functional regulatory compliance adapters, the physics-informed eligibility verification, the recursive memory architecture, the deployment infrastructure — are proprietary to NexTrial.ai.

The boundary is explicit. See [BOUNDARY.md](BOUNDARY.md) for the complete delineation.

---

## Regulatory Coverage

| Jurisdiction | Regulations Mapped | Status |
|---|---|---|
| United States | 21 CFR Parts 11, 50, 54, 56, 312 | v1.0 |
| Brazil | Lei 14.874/2024, RDC 945/2024, LGPD, CFM 2.454/2024 | v1.0 |
| India | NDCTR 2019, DPDP Act 2023, ICMR Guidelines | v1.0 |
| European Union | EU AI Act 2024/1689, EU CTR 536/2014 | v1.0 |
| ICH | E6(R2), E6(R3), Q9(R1) | v1.0 |
| Canada | — | Contributions welcome |
| Japan | — | Contributions welcome |
| Australia | — | Contributions welcome |

---

## How This Framework Was Built

The framework was developed through a process that is itself a proof of concept for the open standard model.

**Published:** March 2026. "Toward a Regulatory Validation Framework for AI-Assisted Clinical Trial Activation and Execution." [Available on NexTrial Dispatch](https://open.substack.com/pub/steventhompsonai/p/toward-a-regulatory-validation-framework).

**Challenged:** Dominique Chesnais, senior GCP/GVP consultant, publicly challenged 8 specific points against the EU AI Act and GxP principles. Three gaps were acknowledged (Article 9 risk management, Article 10 data governance, rubber-stamp concern). Three were addressed in the architecture (binary logic, self-healing loop, empirical validation). Three required specification updates. The challenge made the framework stronger. The full response is in [/co-development/dominique-critique-response.md](co-development/dominique-critique-response.md).

**Confirmed:** Brian Burke, inventor of the ALIGN-AI Framework for EU AI Act conformity assessment, reviewed the proof certificate specification and noted its operational precision in addressing Articles 11/13/14. ALIGN-AI operates as upstream governance to the three-gate architecture — complementary, not competitive.

**Co-developed:** Gourav Pandey, Lead AI Researcher at Takeda R&D Quality, engaged on GxP validation integration. Working session with 15 practitioners held May 2026. Findings are in [/co-development/working-session-findings.md](co-development/working-session-findings.md).

**Presented:** DIA 2026 Global Annual Meeting. Abstract ID 116114. Poster Session II, Tuesday June 16, 11:30 AM–1:30 PM. Pennsylvania Convention Center, Philadelphia.

---

## Lifecycle Scope

The framework governs AI verification across the clinical trial lifecycle:

**Trial Activation (Pre-IRB → First Patient In)**  
Protocol ingestion, regulatory document generation, IRB submission, site qualification, activation timeline prediction.

**Trial Execution (First Patient In → First Patient Out)**  
Plan-vs-actual tracking, deviation detection, enrollment velocity monitoring, continuous verification. [Execution scope specification: forthcoming v2]

One verification architecture. Two phases. The proof obligation is the same in both.

---

## Open Questions

Six questions are explicitly unresolved in v1.0 and are active for community input:

1. **Cold-start problem** — minimum data for RBQM risk classification at new sites
2. **Dynamic risk reassessment** — Article 9(e) triggers during execution
3. **Rubber-stamp prevention** — distinguishing substantive attestation in the audit trail
4. **Composite risk matrix logic** — threshold rule vs. additive scoring
5. **Adapter certification** — third-party conformance process
6. **Multi-jurisdiction documents** — per-jurisdiction calls vs. rollup certificate

Details and current positions: [/co-development/open-questions.md](co-development/open-questions.md)

---

## Contributing

This standard improves through adversarial engagement. Challenge a claim. Add a regulatory mapping. Propose a test case. Submit a working session finding.

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full process.

The next co-development working session is open to any practitioner. Register via GitHub Discussions.

---

## Citation

If you use this framework in research, regulatory submissions, or published work:

```
Thompson, S. (2026). Regulatory Validation Framework for AI in Clinical Trials (v1.0).
NexTrial.ai. https://github.com/nextrial-ai/nextrial-regulatory-framework
DOI: [pending]
```

A preprint is registered at SSRN (ID 6339698). The framework was presented at DIA 2026 (Abstract 116114). The co-development process with AI assistance is documented and acknowledged.

---

## License

Apache 2.0. See [LICENSE](LICENSE).

This license includes a patent grant. Contributors grant all users of this repository a license under their patent claims that are necessarily infringed by their contribution. See [BOUNDARY.md](BOUNDARY.md) for the relationship between this open standard and NexTrial.ai's patent portfolio.

---

## Contact

**Framework questions:** Open a GitHub Issue.  
**Co-development:** Open a GitHub Discussion.  
**Implementation questions:** framework@nextrial.ai  

---

*AI-Assisted — Human Review Required*  
*NexTrial.ai · nextrial.ai · DIA 2026 Abstract 116114*

---

**Provably right, not probably right.**
