# Open Questions — Active Co-Development

**Repository:** nextrial-regulatory-framework  
**Document:** co-development/open-questions.md  
**Version:** 1.0  
**Last Updated:** May 2026  
**AI-Assisted — Human Review Required**

---

## How This Document Works

These are the questions the framework cannot yet answer with confidence. They are not oversights — they are the honest edges of the current specification. Each question is tracked with:

- **Origin:** Where the question came from
- **Stakes:** Why getting it wrong matters
- **Current Position:** What the spec says now (if anything)
- **Working Session Status:** What the community has said
- **Target:** Which version of the framework this question must be resolved for

---

## Q1 — The Cold-Start Problem in RBQM Risk Classification

**Status:** Open — Priority for v2  
**Origin:** Internal specification development  
**Document:** RBQM-SPEC-001 §6  

**The Question:**  
What is the minimum site data required for a meaningful RBQM risk classification? When a site has no prior trial history, or when a protocol is in a novel therapeutic area with no comparable precedents, the three-dimension risk classification cannot be reliably computed from historical data.

**Stakes:**  
If the cold-start default (MEDIUM for insufficient dimensions) is too conservative, it creates operational friction that incentivizes gaming the data. If it's too permissive, it creates unchecked activation risk at exactly the sites and protocols where risk is highest.

**Current Position:**  
Default to MEDIUM for any dimension where data is below threshold. Require pre-activation site visit and document the cold-start condition. Proposed minimum thresholds:
- Site Risk: ≥ 1 prior completed trial at site
- Protocol Risk: ≥ 3 prior trials in same therapeutic area
- Population Risk: ≥ 10 screened patients matching target profile at site

**These thresholds are proposed, not validated.**

**Working Session Input:**  
*To be populated after May 14, 2026 working session.*

**Target Version:** v2.0

---

## Q2 — Dynamic Risk Reassessment Under EU AI Act Article 9(e)

**Status:** Open — Priority for v2  
**Origin:** Dominique Chesnais adversarial review; EU AI Act Article 9(e)  
**Document:** RBQM-SPEC-001 §7  

**The Question:**  
Article 9(e) of the EU AI Act requires that the risk management system address risks that emerge when the AI system is used as intended — including during active deployment. The RBQM pre-verification layer classifies risk at activation. It does not reassess risk dynamically during execution.

What triggers a mid-trial risk reclassification? Who has authority to initiate it? What happens to verification outputs generated under the prior risk classification?

**Stakes:**  
Without dynamic reassessment, a HIGH-risk condition that emerges after activation (e.g., a CRITICAL deviation, an unexpected PI departure, a safety signal) may not trigger the appropriate escalation in the verification architecture. The system remains technically operational but is no longer calibrated to actual risk.

**Current Position:**  
The following reassessment triggers are proposed for v2:
- Site deviation classified as CRITICAL
- Protocol amendment issued
- Screen-fail rate exceeds baseline by > 25%
- PI or study coordinator personnel change
- Inspection finding at site
- Enrollment pause > 30 days

**These triggers are design intent, not validated practice.**

**Working Session Input:**  
*To be populated after May 14, 2026 working session.*

**Target Version:** v2.0

---

## Q3 — Rubber-Stamp Prevention in Attestation

**Status:** Open — Active  
**Origin:** Dominique Chesnais adversarial review  
**Document:** SAID-SPEC-001 §5.2  

**The Question:**  
Level 2 Independent Verification Attestation requires that the PI independently verify the AI output against source documents. But the audit trail only records that attestation occurred — not whether the review was substantive.

How do we distinguish a genuine independent verification (30+ minutes of cross-referencing) from a perfunctory sign-off (3 seconds of scrolling)?

**Stakes:**  
If rubber-stamp attestation is indistinguishable in the audit trail from substantive review, the Level 2 attestation requirement becomes nominal. The human oversight guarantee that satisfies EU AI Act Article 14 is compromised.

**Current Position:**  
The specification requires that attestation documentation include evidence of review (certificate ID, lineage trace, cross-referenced source documents). But it does not specify a minimum review duration or a way to verify that the cross-references were actually examined.

**Proposed Approaches (for community debate):**
1. Require a minimum review time to be logged (problematic — trivially gamed)
2. Require the reviewer to resolve at least one flagged field path in the certificate (requires at least engagement with content)
3. Require a structured checklist confirming specific review steps were completed
4. Accept that procedural compliance is the boundary of what the specification can enforce, and that substantive review is a governance responsibility beyond the spec

**Working Session Input:**  
*To be populated after May 14, 2026 working session.*

**Target Version:** v1.1 — important enough for near-term resolution

---

## Q4 — Composite Risk Matrix Logic: Threshold vs. Additive Scoring

**Status:** Open  
**Origin:** Internal specification development  
**Document:** RBQM-SPEC-001 §5  

**The Question:**  
The current composite risk matrix uses a threshold rule: any HIGH dimension produces a composite HIGH classification. An alternative approach would use additive scoring: three LOW dimensions might score 3, three HIGH dimensions might score 9, and the composite threshold could be set at a calibrated level.

Which approach is more defensible? What are the failure modes of each?

**Stakes:**  
The threshold approach is conservative — a single HIGH dimension regardless of severity triggers maximum caution. The additive approach allows nuanced risk profiles but introduces calibration complexity. The wrong choice either creates unnecessary activation friction or under-detects genuine high-risk combinations.

**Current Position:**  
Threshold rule is v1.0 default. It is deliberately conservative. The specification notes that this is subject to community review.

**Arguments for Threshold (current):**
- Fails safe — a single HIGH is a genuine warning signal
- Simpler to explain to regulators
- Harder to manipulate
- Consistent with ICH Q9 risk management principles

**Arguments for Additive Scoring:**
- More granular — a site with HIGH deviation history but LOW protocol complexity and LOW population risk may not need the same response as three HIGH dimensions
- Better mirrors how experienced CRAs actually assess risk
- Allows sponsor-specific calibration

**Working Session Input:**  
*To be populated after May 14, 2026 working session.*

**Target Version:** v2.0

---

## Q5 — Adapter Certification for Third-Party Implementations

**Status:** Open  
**Origin:** Adapter Interface Specification development  
**Document:** ADAPTER-SPEC-001 §11  

**The Question:**  
Should the framework define a certification process for third-party adapters that claim conformance with this specification? If so: who certifies? What does certification require? How is conformance maintained as regulations change?

**Stakes:**  
Without certification, any party can claim their adapter conforms to this specification without independent verification. This creates liability risk for organizations that adopt a non-conforming adapter believing it satisfies the specification. It also creates reputational risk for the framework.

**Current Position:**  
No certification process is defined in v1.0. Conformance is voluntary and self-declared. The reference test harness in `/validation/` provides a baseline for self-testing.

**Proposed Approaches:**
1. No certification — the reference test harness is sufficient; buyer/implementer responsibility
2. Conformance attestation — self-declaration against a structured checklist, no third-party audit
3. Community peer review — PRs to the adapter registry require review by at least two independent practitioners
4. Third-party audit — formal certification by an independent body (which body? at what cost? how updated?)

**Working Session Input:**  
*To be populated after May 14, 2026 working session.*

**Target Version:** v2.0

---

## Q6 — Multi-Jurisdiction Document Handling

**Status:** Open  
**Origin:** Adapter Interface Specification development  
**Document:** ADAPTER-SPEC-001 §11  

**The Question:**  
Some clinical trial documents — particularly global protocols and master informed consent frameworks — must simultaneously satisfy multiple regulatory jurisdictions. The current adapter interface requires separate per-jurisdiction calls, producing separate proof certificates. 

Is this sufficient, or does the framework need a "multi-jurisdiction rollup" concept — a composite certificate that aggregates results across jurisdictions?

**Stakes:**  
Sponsors running global trials need to understand their complete compliance posture, not manage a collection of jurisdiction-specific certificates. Without a rollup concept, the framework creates an administrative burden that may make multi-jurisdiction trials operationally harder.

On the other hand, a rollup certificate risks obscuring jurisdiction-specific failures — a document that is PASS in three jurisdictions but FAIL in a fourth might be misread as broadly compliant.

**Current Position:**  
Separate per-jurisdiction calls. No rollup concept in v1.0.

**Proposed Approaches:**
1. Keep separate calls; require the implementing system to aggregate (current)
2. Define a rollup certificate schema as a fourth specification, separate from the adapter output
3. Allow multi-jurisdiction input in a single call, but produce separate findings per jurisdiction
4. Treat multi-jurisdiction compliance as out of scope for this specification

**Working Session Input:**  
*To be populated after May 14, 2026 working session.*

**Target Version:** v2.0

---

## Working Session Findings

**Session 1:** May 14, 2026 — 15 practitioners, 60 minutes  
*Findings to be populated after the session.*

Results will include:
- Mentimeter polling data for quantitative questions
- Qualitative themes from discussion
- Priority ranking of open questions
- New questions surfaced by practitioners
- Any consensus positions reached

---

## Resolved Questions

Questions resolved in prior versions of the framework are archived here for historical reference.

**Resolved: Three-Gate vs. Single-Gate Architecture** (resolved in v1.0)  
Early framework drafts considered a single verification gate. The three-gate architecture was adopted based on the principle that verification, formal proof, and human oversight serve distinct functions that cannot be collapsed without losing the property that makes each gate valuable.

**Resolved: Binary vs. Probabilistic Verification** (resolved in v1.0)  
The framework considered whether Gate 1 should produce a confidence score rather than a binary determination. Binary was adopted on the principle that regulatory compliance is a binary condition — a document either satisfies a requirement or it does not. Probabilistic outputs create audit trail problems that outweigh their precision benefits.

**Resolved: RBQM Layer Position** (resolved in v1.0 in response to Dominique critique)  
The original framework had a three-gate architecture with no pre-verification layer. The RBQM layer was added above Gate 1 in response to the EU AI Act Article 9 gap identified in adversarial review. It sits above, not inside, the three gates because it addresses a different question: "Should this activation proceed?" vs. "Is this output compliant?"

---

*Open questions are the honest edge of what we know. Contributing your expertise here is how the standard gets stronger.*
