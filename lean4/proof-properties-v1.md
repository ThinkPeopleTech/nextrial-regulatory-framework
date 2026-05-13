# Lean4 Proof Property Definitions v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** LEAN4-PROPS-001  
**Version:** 1.0  
**Status:** Published  
**Author:** Steven Thompson, NexTrial.ai  
**Date:** May 2026  
**AI-Assisted — Human Review Required**

---

## 1. Purpose

This specification defines the structural properties that a formal verification layer must prove for AI-generated regulatory outputs in clinical trials. It defines **what** must be proven — not **how** the proofs are constructed.

The verification layer uses Lean4, a formal proof assistant used by Google DeepMind (AlphaProof), Harmonic AI, and mathematical research communities. Lean4 was selected because its proofs are independently checkable by any party with the Lean4 proof checker — the verifier does not require trust in the prover.

This document is the contract between the open standard and any implementation. An implementation satisfies this specification if it can produce Lean4 proofs for each property listed here, against the input types defined in Section 4, within the performance bounds defined in Section 6.

---

## 2. Design Boundary

### What Lean4 Proves

Lean4 proves **structural correctness** of regulatory documents and submission packages. Structural properties are properties that can be determined from the document's architecture — its fields, references, versions, sections, and temporal ordering — without interpreting the semantic meaning of natural language content.

### What Lean4 Does Not Prove

Lean4 does not prove:
- Whether the *content* of a field is regulatory-accurate (Gate 1 scope)
- Whether a medical determination is clinically appropriate (Gate 3 scope)
- Whether natural language text is semantically consistent across documents (outside formal verification scope in v1.0)
- Whether a confidence score is calibrated (not applicable — the architecture does not use confidence scores)

### Why This Separation Exists

Collapsing structural verification and semantic verification into a single system eliminates the auditability of each. An inspector reviewing a proof certificate must be able to determine independently:

1. Was the document structurally sound? (Gate 2 — this specification)
2. Was the document content regulatory-compliant? (Gate 1 — ADAPTER-SPEC-001)
3. Did the qualified human agree? (Gate 3 — SAID-SPEC-001)

If structural and semantic verification are combined, the inspector cannot isolate which verification failed or why. The separation is not an implementation convenience — it is an audit architecture requirement.

---

## 3. Property Definitions

### 3.1 MVP Properties (v1.0)

These three properties are required for any implementation claiming conformance with this specification.

---

#### Property 1: Field Presence

**Formal Name:** `FieldPresence`

**Definition:** For a given document type and jurisdiction, every required field exists and is non-null in the document instance.

**Input:**
- A document instance (structured representation per Section 4)
- A field requirement specification for the document type and jurisdiction

**Property Statement:**  
For every field `f` in the required field set `R(document_type, jurisdiction)`, field `f` exists in the document instance `D` and `value(D, f) ≠ null`.

**Formal Expression:**
```
∀ f ∈ R(doc_type, jurisdiction),
  f ∈ fields(D) ∧ value(D, f) ≠ null
```

**Pass Condition:** All required fields present and non-null.

**Fail Condition:** Any required field absent or null. The proof failure identifies the specific missing field(s).

**Performance Bound:** < 50ms for documents with ≤ 500 required fields.

**Regulatory Basis:**
- 21 CFR 312.23 — IND submission must contain all required sections
- ANVISA RDC 945 Art. 8 — clinical trial dossier required components
- NDCTR 2019 Rule 9 — application required components
- EU AI Act Art. 11 / Annex IV — technical documentation required elements

**Example — PASS:**
```
Document: IRB Submission Package
Jurisdiction: US
Required Fields: [protocol_title, pi_name, pi_signature, irb_number, 
                  consent_form_version, sponsor_name, ...]
Result: All 47 required fields present and non-null.
Proof: FieldPresence ✓ (23ms)
```

**Example — FAIL:**
```
Document: IRB Submission Package
Jurisdiction: US
Required Fields: [protocol_title, pi_name, pi_signature, irb_number, ...]
Missing: [pi_signature, irb_number]
Result: 2 of 47 required fields absent.
Proof: FieldPresence ✗ — missing fields identified.
```

---

#### Property 2: Version Consistency

**Formal Name:** `VersionConsistency`

**Definition:** Every version reference within a document or submission package points to the current version of the referenced document. No stale version references exist.

**Input:**
- A document instance or submission package (structured representation)
- A version registry mapping document identifiers to their current versions

**Property Statement:**  
For every version reference `vref` in document instance `D`, the referenced version `vref.version` equals the current version `current_version(vref.document_id)` in the version registry `V`.

**Formal Expression:**
```
∀ vref ∈ version_references(D),
  vref.version = current_version(V, vref.document_id)
```

**Pass Condition:** All version references match the current version in the registry.

**Fail Condition:** Any version reference points to a superseded version. The proof failure identifies the specific stale reference(s) and the expected current version.

**Performance Bound:** < 30ms for packages with ≤ 100 version references.

**Regulatory Basis:**
- ICH E6(R3) — documentation must be current and consistent
- 21 CFR 312.60 — investigator must use current protocol version
- ANVISA RDC 945 Art. 19 — protocol version in dossier must match approved version

**Example — PASS:**
```
Package: Site Activation Package (SAP-2026-001)
Documents: [Protocol v3.1, IB v2.0, ICF v3.1, SOP-001 v1.2]
Version References: Protocol references IB v2.0 ✓, ICF references Protocol v3.1 ✓, ...
Result: All 12 version references current.
Proof: VersionConsistency ✓ (18ms)
```

**Example — FAIL:**
```
Package: Site Activation Package (SAP-2026-001)
Version References: ICF references Protocol v3.0 (current is v3.1)
Result: 1 stale reference detected.
Proof: VersionConsistency ✗ — ICF.protocol_reference = v3.0, expected v3.1.
```

---

#### Property 3: Reference Resolution

**Formal Name:** `ReferenceResolution`

**Definition:** Every cross-reference within a document or submission package resolves to an existing document in the package or in the document registry. No dangling references exist.

**Input:**
- A document instance or submission package (structured representation)
- A document registry listing all documents available for reference

**Property Statement:**  
For every cross-reference `ref` in document instance `D`, the referenced document `ref.target_id` exists in the document registry `Reg` or in the submission package `P`.

**Formal Expression:**
```
∀ ref ∈ cross_references(D),
  ref.target_id ∈ documents(Reg) ∪ documents(P)
```

**Pass Condition:** All cross-references resolve to existing documents.

**Fail Condition:** Any cross-reference points to a non-existent document. The proof failure identifies the specific dangling reference(s).

**Performance Bound:** < 30ms for packages with ≤ 200 cross-references.

**Regulatory Basis:**
- 21 CFR Part 11 — electronic records must be complete and accessible
- ICH E6(R3) — trial master file must contain all referenced documents
- ANVISA RDC 945 — dossier cross-references must be resolvable

**Example — PASS:**
```
Document: Protocol AMG-301 v3.1
Cross-References: [IB-AMG-301 v2.0, ICF-AMG-301 v3.1, SAE-Form-001]
Registry Contains: [IB-AMG-301 v2.0 ✓, ICF-AMG-301 v3.1 ✓, SAE-Form-001 ✓]
Result: All 3 references resolve.
Proof: ReferenceResolution ✓ (12ms)
```

**Example — FAIL:**
```
Document: Protocol AMG-301 v3.1
Cross-References: [IB-AMG-301 v2.0, DMP-AMG-301]
Registry: DMP-AMG-301 not found.
Result: 1 dangling reference.
Proof: ReferenceResolution ✗ — DMP-AMG-301 not in registry.
```

---

### 3.2 Phase 2 Properties (Target: v2.0)

These three properties are architecturally designed but not required for v1.0 conformance. They are included here to define the contract for future implementations.

---

#### Property 4: Regulatory Completeness

**Formal Name:** `RegulatoryCompleteness`

**Definition:** For a given document type, jurisdiction, and protocol, all required sections are present per the applicable regulatory template. Section presence is determined by section identifier matching, not by content analysis.

**Status:** Design complete. Implementation requires validated regulatory section templates per document type per jurisdiction. Template development is in progress.

**Prerequisite:** Validated section templates for each `(document_type, jurisdiction)` pair.

---

#### Property 5: Non-Contradiction

**Formal Name:** `NonContradiction`

**Definition:** No logical contradictions exist between structured fields across documents within a submission package. For example: a protocol stating "18-65 years" for age eligibility and an ICF stating "21 years and older" is a structural contradiction detectable from field values without semantic analysis.

**Status:** Design complete. Implementation requires a contradiction rule set defining which field pairs across which document types must be consistent.

**Scope Limitation:** Non-contradiction applies to structured fields only. Detecting semantic contradictions in narrative text is outside the scope of formal verification and is Gate 1's responsibility.

**Prerequisite:** Contradiction rule set defining cross-document field consistency requirements.

---

#### Property 6: Temporal Ordering

**Formal Name:** `TemporalOrdering`

**Definition:** All events, approvals, and dependencies within a submission package occur in a logically valid time sequence. For example: IRB approval date must precede first patient enrollment date. Ethics committee review must precede regulatory submission.

**Status:** Design complete. Implementation requires a temporal dependency graph per jurisdiction defining which events must precede which.

**Prerequisite:** Temporal dependency graph per jurisdiction.

---

## 4. Input Type Definitions

### 4.1 Document Instance

The Lean4 verification layer receives a **structured document representation** — not a raw PDF, not unstructured text. The structured representation is produced by the upstream ingestion pipeline (outside the scope of this specification) and conforms to the following type structure:

```
DocumentInstance:
  document_id     : String            -- globally unique identifier
  document_type   : DocumentType      -- controlled vocabulary
  jurisdiction    : Jurisdiction      -- ISO 3166-1 alpha-2
  version         : SemanticVersion   -- MAJOR.MINOR.PATCH
  fields          : Map<FieldPath, FieldValue>
  sections        : List<Section>
  version_refs    : List<VersionReference>
  cross_refs      : List<CrossReference>
  timestamps      : TemporalRecord
```

### 4.2 Submission Package

```
SubmissionPackage:
  package_id      : String
  documents       : List<DocumentInstance>
  jurisdiction    : Jurisdiction
  protocol_id     : String
  protocol_version: SemanticVersion
```

### 4.3 Field Requirement Specification

```
FieldRequirement:
  document_type   : DocumentType
  jurisdiction    : Jurisdiction
  required_fields : Set<FieldPath>
```

### 4.4 Version Registry

```
VersionRegistry:
  entries         : Map<DocumentId, SemanticVersion>
```

### 4.5 Document Registry

```
DocumentRegistry:
  documents       : Set<DocumentId>
```

### 4.6 Controlled Vocabularies

**DocumentType:**
```
protocol | informed_consent_form | investigator_brochure | 
site_qualification_report | regulatory_submission_package | 
irb_application | clinical_study_report | site_activation_checklist
```

**Jurisdiction:**
```
US | BR | IN | EU | DE | MX | CO | AR
```

**FieldPath:** Dot-notation path to a field within a structured document (e.g., `protocol.eligibility.inclusion_criterion_3.threshold`).

**FieldValue:** String, Number, Boolean, Date, or Null.

---

## 5. Output: The Proof Result

Each property verification produces a **proof result** conforming to this structure:

```
ProofResult:
  property_name       : String         -- e.g., "FieldPresence"
  input_document_id   : String         -- which document was verified
  input_package_id    : String | Null  -- if part of a package verification
  jurisdiction        : Jurisdiction
  result              : PASS | FAIL
  proof_duration_ms   : Natural        -- wall-clock milliseconds
  failure_details     : List<FailureDetail> | Null
  lean4_proof_hash    : String         -- SHA-256 of the Lean4 proof term
  verifier_version    : String         -- Lean4 version used
```

**FailureDetail:**
```
FailureDetail:
  field_or_reference  : String         -- which field, version ref, or cross-ref failed
  expected            : String         -- what was expected
  observed            : String | Null  -- what was found (null if absent)
  remediation_hint    : String         -- human-readable suggestion
```

---

## 6. Performance Requirements

| Property | Max Documents | Max Fields/Refs | Time Bound |
|---|---|---|---|
| FieldPresence | 1 | 500 fields | < 50ms |
| VersionConsistency | 20 (package) | 100 version refs | < 30ms |
| ReferenceResolution | 20 (package) | 200 cross-refs | < 30ms |
| All MVP properties (combined) | 20 (package) | Combined | < 100ms |

Performance is measured as wall-clock time on a single-core execution. The < 100ms combined bound ensures that formal verification does not introduce perceptible latency into the activation workflow.

---

## 7. Determinism Guarantee

Lean4 proofs are deterministic by construction. The same input + the same property definition + the same Lean4 version = the same proof result, always. This is not a design goal — it is a mathematical property of the proof system.

This determinism guarantee is what makes the proof certificate admissible as a compliance artifact under 21 CFR Part 11. A statistical test that might produce a different result on re-execution is not a compliance artifact. A formal proof that succeeds is a guarantee.

---

## 8. Independent Verifiability

Any party with access to:
1. The Lean4 proof checker (open source, freely available)
2. The property definitions (this specification)
3. The input types (Section 4)
4. The proof term (referenced by `lean4_proof_hash` in the proof result)

...can independently verify that the proof is valid. No trust in the prover is required. No access to the production system is required. No proprietary software is required.

This is the property that distinguishes formal verification from any other form of validation. An inspector does not need to trust the AI vendor. The inspector can check the math.

---

## 9. Relationship to Other Specifications

| Specification | Relationship |
|---|---|
| PC-SPEC-001 (Proof Certificate) | The proof result from this specification becomes Property 3 (Verification Operation) of the proof certificate |
| TGA-SPEC-001 (Three-Gate Architecture) | This specification defines Gate 2's scope and pass conditions |
| ADAPTER-SPEC-001 (Adapter Interface) | Gate 1 adapter output feeds into Gate 2 as an additional input for version and reference verification |
| SAID-SPEC-001 (Site AI Disclosure) | The proof result informs the recommended attestation level at Gate 3 |
| RBQM-SPEC-001 (RBQM Pre-Verification) | The RBQM layer classifies risk before Gate 2 is invoked; risk classification does not affect proof logic |

---

## 10. Open Questions

1. **Phase 2 Prerequisites:** The Phase 2 properties (completeness, non-contradiction, temporal ordering) each require validated reference data (section templates, contradiction rules, temporal graphs). What is the validation standard for this reference data? Who validates it?

2. **Schema Evolution:** When the input type definitions change (new document types, new fields), how are existing proofs treated? Is re-verification required for documents proven under a prior schema version?

3. **Lean4 Version Pinning:** Should the specification pin a specific Lean4 version, or accept any version that can verify the proofs? What happens when Lean4 itself is updated?

4. **Cross-Jurisdiction Properties:** Some properties (especially version consistency and reference resolution) may need to verify references across jurisdiction boundaries in global trials. Should cross-jurisdiction verification be a separate property or an extension of the existing three?

5. **Performance Scaling:** The < 100ms bound assumes packages of ≤ 20 documents. What is the expected behavior for larger packages? Should the bound scale linearly, or is a fixed bound required regardless of package size?

---

## 11. Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | May 2026 | Initial specification — MVP properties defined, Phase 2 properties documented as design intent |

---

*This specification is published under Apache 2.0. It defines what must be proven — not how. The Lean4 implementation is part of the NexTrial.ai production system. See BOUNDARY.md for the explicit boundary.*
