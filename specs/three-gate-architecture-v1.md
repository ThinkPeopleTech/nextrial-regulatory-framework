# Three-Gate Verification Architecture Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** TGA-SPEC-001  
**Version:** 1.0  
**Status:** Published  
**Author:** Steven Thompson, NexTrial.ai  
**Date:** May 2026  
**AI-Assisted — Human Review Required**

---

## 1. Purpose

This specification defines the three-gate verification architecture — the sequential verification structure that governs how AI-generated outputs reach human decision-makers in regulated clinical trial contexts.

The architecture establishes one non-negotiable principle:

> **No AI-generated output reaches a human decision-maker without passing through all three gates.**

This is not a quality guideline. It is an architectural constraint. The gates are not optional checkpoints — they are load-bearing structural elements. Bypassing any gate invalidates the compliance guarantee of the architecture.

---

## 2. Architecture Overview

```
                    AI SYSTEM OUTPUT
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  LAYER 0: RBQM PRE-VERIFICATION                         │
│  "Should this activation proceed?"                      │
│  Site risk · Protocol risk · Population risk            │
│  → See RBQM-SPEC-001                                    │
└─────────────────────────┬───────────────────────────────┘
                          │  [Gate 1 entry authorized]
                          ▼
┌─────────────────────────────────────────────────────────┐
│  GATE 1: REGULATORY COMPLIANCE VERIFICATION             │
│  "Is this output compliant with applicable regulation?" │
│                                                         │
│  Jurisdiction-specific adapter evaluation               │
│  Deterministic rule application                         │
│  Severity classification: CRITICAL / WARNING / INFO     │
│  Output: Gate 1 Certificate                             │
└─────────────────────────┬───────────────────────────────┘
                          │  [No CRITICAL findings]
                          ▼
┌─────────────────────────────────────────────────────────┐
│  GATE 2: FORMAL MATHEMATICAL PROOF                      │
│  "Can we prove structural correctness?"                 │
│                                                         │
│  Lean4 formal verification                              │
│  Binary pass/fail — no probabilities                    │
│  < 100ms execution                                      │
│  Output: Proof Certificate (PC-SPEC-001)                │
└─────────────────────────┬───────────────────────────────┘
                          │  [Proof passes]
                          ▼
┌─────────────────────────────────────────────────────────┐
│  GATE 3: HUMAN OVERSIGHT CHECKPOINT                     │
│  "Does the qualified human agree?"                      │
│                                                         │
│  Three-level attestation protocol                       │
│  Override capability at every level                     │
│  Immutable audit trail                                  │
│  Output: Attested Determination                         │
└─────────────────────────┬───────────────────────────────┘
                          │
                          ▼
                  COMPLIANT DETERMINATION
                  (Human decides. Always.)
```

---

## 3. Gate 1: Regulatory Compliance Verification

### 3.1 Purpose

Gate 1 answers one question: **Does this AI-generated output satisfy the regulatory requirements of the target jurisdiction?**

Gate 1 does not generate content. It does not reason about intent. It does not produce confidence scores. It evaluates a specific output against a specific rule set and returns a structured finding.

### 3.2 The Adapter Architecture

Gate 1 is implemented through jurisdiction-specific compliance adapters. Each adapter:
- Covers exactly one regulatory jurisdiction
- Is deterministic: same input + same adapter version = same output
- Is independently executable without the broader AI system
- Produces a structured Gate 1 certificate conforming to ADAPTER-SPEC-001
- Is version-controlled and independently auditable

The adapter architecture enables jurisdiction-specific verification without maintaining separate monolithic systems. The interface contract for adapters is defined in ADAPTER-SPEC-001.

### 3.3 Regulatory Coverage (v1.0)

| Jurisdiction | Adapter ID | Key Regulations |
|---|---|---|
| United States | US-CTA-1.x | 21 CFR Parts 11, 50, 54, 56, 312 |
| Brazil | BR-CTA-1.x | Lei 14.874/2024, RDC 945/2024, LGPD, CFM 2.454/2024 |
| India | IN-CTA-1.x | NDCTR 2019, DPDP Act 2023, ICMR Guidelines |
| European Union | EU-CTA-1.x | EU AI Act 2024/1689, EU CTR 536/2014, GDPR |
| ICH | ICH-GCP-1.x | E6(R2), E6(R3), Q9(R1) |

### 3.4 Severity Classification

Gate 1 produces findings at three severity levels:

**CRITICAL**
- Represents a clear violation of a mandatory regulatory requirement
- Blocks Gate 2 progression — the output cannot advance
- Gate 1 overall result: FAIL
- Examples: Missing required informed consent element (21 CFR 50.25(a)); absent CONEP authorization where required; missing IRB membership documentation

**WARNING**
- Potential compliance issue requiring human judgment to resolve
- Does not block Gate 2 progression, but requires documentation
- Gate 1 overall result: WARNING
- Examples: Consent language above recommended reading level; protocol section potentially incomplete against guidance (not regulation); site qualification data approaching expiration

**INFO**
- Provides information relevant to compliance but not a violation
- Does not affect Gate 1 result
- Logged for audit trail completeness
- Examples: Optional guidance recommendation satisfied; prior submission precedent referenced

### 3.5 Gate 1 Pass Condition

Gate 1 is passed when:
- Zero CRITICAL findings are present
- All WARNING findings are documented
- The Gate 1 Certificate is sealed and available for Gate 2

Gate 1 fails when any CRITICAL finding is present. Failed Gate 1 outputs are returned for remediation — they do not advance to Gate 2.

### 3.6 Design Boundary

Gate 1 is a **verification engine**, not a generation engine. This boundary is architecturally enforced:

- A separate reasoning system generates content
- Gate 1 evaluates outputs against jurisdiction-specific rule sets
- Gate 1 does not modify, suggest edits to, or regenerate the content it evaluates

Crossing this boundary — allowing Gate 1 to generate corrected outputs — would collapse the separation between generation and verification that gives the architecture its compliance properties.

---

## 4. Gate 2: Formal Mathematical Proof

### 4.1 Purpose

Gate 2 answers one question: **Can we prove that this output is structurally correct?**

Gate 2 does not re-evaluate regulatory compliance — that is Gate 1's scope. Gate 2 verifies the mathematical structure of the output and the Gate 1 certificate: that required fields exist, references resolve, and no structural contradictions are present.

### 4.2 Why Lean4

The framework uses Lean4 for formal verification. Lean4 is a formal proof assistant used by Google DeepMind (AlphaProof), Harmonic AI, and mathematical research communities. Its properties that make it appropriate here:

- **Completeness:** A Lean4 proof that succeeds is a mathematical guarantee, not an estimate
- **Speed:** Structural property proofs execute in under 100 milliseconds per document
- **Auditability:** Lean4 proofs are independently checkable by any party with the Lean4 proof checker
- **Determinism:** Same input + same proof definition = same result, always

### 4.3 What Gate 2 Proves

Gate 2 verifies structural properties. It does not verify semantic accuracy — that is Gate 1's scope.

| Property | Verification Scope | v1.0 Status |
|---|---|---|
| Field Presence | All required fields exist for the document type and jurisdiction | Included |
| Version Consistency | All version references point to current document versions | Included |
| Reference Resolution | All cross-references resolve to existing documents | Included |
| Completeness | All required sections present per document type and protocol | Phase 2 |
| Non-Contradiction | No logical conflicts between documents in a submission package | Phase 2 |
| Temporal Ordering | All events and approvals occur in logically valid time sequence | Phase 2 |

### 4.4 Critical Design Boundary

**Lean4 proves structure, not semantics.**

Lean4 verifies that the document architecture is mathematically sound — that required fields exist, references resolve, and no structural contradictions are present. Whether the *content* of those fields is regulatory-accurate is Gate 1's responsibility.

This separation is architecturally intentional. It produces a verification chain where each gate's scope is defined and bounded — allowing Gate 1 findings and Gate 2 proofs to be audited independently.

### 4.5 The Proof Certificate

Gate 2 produces a **proof certificate** as defined in PC-SPEC-001. The proof certificate is:
- A mathematical artifact, not a confidence estimate
- Binary: it either proves or it does not
- Independently verifiable by any party with the Lean4 proof checker
- Sealed and immutable upon generation
- The primary artifact presented to the human at Gate 3

### 4.6 Gate 2 Pass Condition

Gate 2 is passed when the Lean4 proof succeeds for all in-scope structural properties. The pass condition is binary — there is no partial pass.

Gate 2 fails when any structural property cannot be proven. Failed Gate 2 outputs are returned for structural remediation — they do not advance to Gate 3.

---

## 5. Gate 3: Human Oversight Checkpoint

### 5.1 Purpose

Gate 3 enforces mandatory human oversight consistent with ICH E6(R3), EU AI Act Article 14, and CFM Resolution 2.454/2024.

Gate 3 answers one question: **Does the qualified human decision-maker agree with this determination, having reviewed the proof certificate?**

The principle is unambiguous: **the human always decides.** The gates prove what was verified before the human decided.

### 5.2 What Gate 3 Presents to the Human

At Gate 3, the qualified investigator receives:
1. The AI-generated output
2. The Gate 1 Certificate (regulatory compliance findings)
3. The Proof Certificate (Property 4: Boundary Statement — what is outside the system's scope)
4. The recommended attestation level (1, 2, or 3)

The human decides. The proof certificate tells the human exactly what has been verified and exactly what has not.

### 5.3 Three Attestation Levels

Gate 3 operates through three attestation levels defined in SAID-SPEC-001:

**Level 1 — Review Attestation**  
The investigator has reviewed the output and found no reason to override. Applicable for administrative and logistical determinations with no direct patient safety implication.

**Level 2 — Independent Verification Attestation**  
The investigator has independently verified the output against source documents. Applicable for regulatory document content, eligibility criteria application, and IRB submission content.

**Level 3 — Clinical Judgment Attestation**  
The investigator exercises clinical judgment that supersedes or supplements the output, accepting full clinical responsibility. Applicable for patient safety determinations, clinical eligibility judgments, and any determination where clinical expertise is the primary basis.

### 5.4 The Override Protocol

An investigator may override any AI output at any time, at any attestation level. The override:
- Does not constitute a system failure — it is the intended function of human oversight
- Is documented with the investigator's basis and the replacement determination
- Produces an immutable Override Record linked to the original certificate
- Is retained in the audit trail

Override patterns are analyzed as quality management, not as failure metrics. See SAID-SPEC-001 §5 for the full override protocol.

### 5.5 Gate 3 Pass Condition

Gate 3 is passed when:
- A qualified investigator completes the attestation at the required level
- The attestation is documented with the required fields
- The immutable attestation record is sealed

There is no automated Gate 3 pass. Human attestation is required every time.

---

## 6. Cross-Gate Properties

### 6.1 Sequential Enforcement

The gates are sequential. No output may skip a gate. No output may reach a later gate without passing the prior gate. This is an architectural constraint, not a process guideline.

### 6.2 Gate-Level Audit Trails

Each gate produces its own audit trail entry, linked by the certificate chain:
- Gate 1: Adapter certificate with findings and severities
- Gate 2: Lean4 proof certificate with structural verification results
- Gate 3: Human attestation record with identity, level, and timestamp

Together, these constitute the complete compliance chain for a single determination.

### 6.3 Failure Handling

| Failure Point | Outcome | Return Path |
|---|---|---|
| RBQM Layer 0 | Gate 1 entry blocked | Mitigation documentation required |
| Gate 1 CRITICAL finding | Gate 2 blocked | Output returned for regulatory remediation |
| Gate 1 WARNING finding | Gate 2 proceeds with warning logged | Human notified at Gate 3 |
| Gate 2 proof failure | Gate 3 blocked | Output returned for structural remediation |
| Gate 3 override | New determination created | Override record sealed; original certificate SUPERSEDED |

### 6.4 The Separation Principle

Each gate has a defined, bounded scope. The separation between scopes is architecturally enforced:

| Gate | Scope | Not in Scope |
|---|---|---|
| Gate 1 | Regulatory compliance of content | Structural correctness; clinical judgment |
| Gate 2 | Structural mathematical correctness | Regulatory compliance; clinical judgment |
| Gate 3 | Human clinical and regulatory judgment | Automated verification (already done by Gates 1–2) |

Collapsing gate scopes — for example, allowing Gate 2 to re-evaluate regulatory compliance — eliminates the auditability of the individual gates.

---

## 7. Architecture Constraints (Non-Negotiable)

The following constraints define the architecture. They are not implementation recommendations — they are the properties that give the architecture its compliance guarantees.

1. **Sequential gates:** All three gates must be traversed in order. No output bypasses any gate.

2. **Deterministic Gates 1 and 2:** Gates 1 and 2 must be deterministic. Probabilistic or statistical outputs are not compliant verification.

3. **Human Gate 3:** Gate 3 requires human attestation. No automated system may perform Gate 3.

4. **Immutable certificates:** Certificates at each gate are sealed and immutable. Superseded certificates are archived, never deleted.

5. **Boundary separation:** Each gate's scope is bounded. Gates do not perform each other's functions.

6. **Zero PHI in the open standard:** This specification contains no patient data, no personal health information, and no individually identifiable information. PHI handling is a concern of the implementing system, not this framework.

---

## 8. Relationship to the RBQM Pre-Verification Layer

The RBQM Pre-Verification Layer (RBQM-SPEC-001) sits above Gate 1. It asks a different question than the three gates:

- **RBQM Layer 0:** "Should this activation proceed, given what we know about site, protocol, and population risk?"
- **Gate 1:** "Is this specific output compliant?"
- **Gate 2:** "Is this specific output structurally correct?"
- **Gate 3:** "Does the qualified human agree?"

The RBQM layer may block Gate 1 entry by requiring mitigation documentation before any output enters the verification chain. It does not replace any gate.

---

## 9. Compliance Mapping

### EU AI Act Article 14 (Human Oversight)

Article 14 requires that high-risk AI systems be designed to allow human oversight, including the ability to intervene, override, and stop the system. The three-gate architecture satisfies Article 14 by:
- Making human oversight (Gate 3) structurally mandatory, not optional
- Providing the human with the complete verification evidence (Gates 1 and 2 certificates) before they decide
- Enabling override at any level with documented basis
- Ensuring the boundary statement (Property 4 of the proof certificate) defines exactly what requires human judgment

### ICH E6(R3) Principles-Based Quality Management

ICH E6(R3) requires quality management proportionate to the risks to trial participants and data reliability. The three-gate architecture satisfies this by:
- Calibrating Gate 1 coverage to the risk profile of the determination type
- Making risk classification (RBQM layer) explicit and documented
- Ensuring human oversight is required regardless of AI output confidence

### 21 CFR Part 11 (Electronic Records)

21 CFR Part 11 requires that electronic records be attributable, legible, contemporaneous, original, and accurate. The proof certificate satisfies Part 11 by:
- Recording source attribution in Property 2 (Values Verified)
- Generating records contemporaneously with the determination
- Sealing certificates to prevent post-hoc modification
- Retaining superseded records rather than deleting them

---

## 10. Open Questions

1. **Gate 2 Scope Expansion:** The v1.0 Lean4 properties cover structural verification. Phase 2 adds non-contradiction and temporal ordering proofs. What are the implementation prerequisites for Phase 2, and what is the validation standard for new Lean4 property definitions?

2. **Multi-Jurisdiction Gate 1:** When an output must satisfy multiple jurisdictions simultaneously (global trial), does it pass through Gate 1 once with a multi-jurisdiction adapter, or once per jurisdiction? What is the audit trail structure?

3. **Gate 3 Delegation:** Can Gate 3 attestation be delegated to sub-investigators? Under what conditions? How is delegation authority documented in the attestation record?

4. **Asynchronous Determinations:** In some workflows, Gate 3 attestation occurs hours or days after Gate 2. What is the maximum permissible gap? Does the proof certificate require re-verification if significant time has elapsed?

5. **Architecture Versioning:** As the three-gate architecture evolves (Phase 2 Gate 2 properties, TEI scope expansion), how are determinations made under prior architecture versions treated? Is there a re-verification requirement?

---

## 11. Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | May 2026 | Initial specification. Phase 2 Gate 2 properties noted as forthcoming. |

---

*This specification is published under Apache 2.0.*  
*For the boundary between this open standard and the NexTrial.ai production implementation, see BOUNDARY.md.*
