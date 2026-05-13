# Proof Certificate Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** PC-SPEC-001  
**Version:** 1.0  
**Status:** Published  
**Author:** Steven Thompson, NexTrial.ai  
**Date:** May 2026  
**AI-Assisted — Human Review Required**

---

## 1. Purpose

This specification defines the **proof certificate** — the core artifact produced by any AI system operating under this framework. A proof certificate is the structured, immutable record of a single verified AI-assisted determination. It is the difference between a compliance artifact and a confidence score.

The proof certificate is not a log entry. It is not an audit trail export. It is not a dashboard visualization. It is a discrete, self-contained artifact that satisfies a single test:

> **The Three-Second Test:** Hand the certificate to an inspector. Ask: "Can you reconstruct this decision — source data, rule applied, verification operation, and boundary — from this artifact alone?"
> 
> If yes, it is a proof certificate.  
> If no, it is a metric.

---

## 2. Regulatory Basis

The proof certificate architecture satisfies the following regulatory requirements:

| Regulation | Requirement | How the Certificate Satisfies It |
|---|---|---|
| 21 CFR Part 11 | Electronic records must be attributable, legible, contemporaneous, original, and accurate (ALCOA) | All four certificate properties are recorded at decision time, attributed to source, and immutable |
| ICH E6(R3) | Documentation must support reconstruction of the trial | Lineage trace enables complete reconstruction |
| EU AI Act Art. 13 | High-risk AI outputs must be interpretable by deployers and users | Rule invoked + boundary statement satisfy Art. 13 transparency |
| EU AI Act Art. 14 | Human oversight must be meaningful, not perfunctory | Boundary statement defines exactly what the human must decide |
| EU AI Act Art. 17 | Technical documentation must include information about the verification performed | The certificate IS the technical documentation of the verification |
| CFM Resolution 2.454/2024 | AI use in patient encounters requires documented verification before clinical application | Certificate documents verification; human attestation satisfies the oversight requirement |
| ANVISA RDC 945/2024 | Regulatory submissions must be traceable to source documents | Lineage trace satisfies traceability requirement |
| ALCOA+ | Data must be Attributable, Legible, Contemporaneous, Original, Accurate, plus Complete, Consistent, Enduring, Available | All ALCOA+ properties are addressed by certificate structure |

---

## 3. The Four Properties

Every proof certificate must contain exactly these four properties. No certificate that omits any property satisfies this specification.

### Property 1: Rule Invoked

**Definition:** The specific regulatory citation and the specific protocol section applied to produce this determination.

**Requirements:**
- Must cite the specific regulatory provision at the section or subsection level — not the regulation title alone
- Must cite the specific protocol section — not "the protocol" generically
- Must be the rule actually applied, not a summary of applicable rules
- Must be current as of the verification timestamp — citation to a superseded rule version is non-compliant

**Compliant example:**
```
Rule Invoked:
  Regulatory: 21 CFR 50.25(a)(1) — Required element of informed consent: 
              statement that the study involves research
  Protocol:   Protocol AMG-301 v2.1, Section 7.3.2, Informed Consent 
              Requirement 1
```

**Non-compliant example:**
```
Rule Invoked: FDA informed consent requirements  ← too general; fails
```

---

### Property 2: Values Verified

**Definition:** The exact patient, protocol, site, and document values that were checked in producing this determination.

**Requirements:**
- Must list actual values, not describe them — "HbA1c = 7.2%" not "hemoglobin A1c within normal range"
- Must be attributable to source — each value must carry a field path reference to its origin document
- Must be contemporaneous — values recorded at time of verification, not reconstructed
- Must include observed value AND the threshold/condition it was checked against
- For absence checks (required field missing), must state what was absent and what was required

**Compliant example:**
```
Values Verified:
  Patient:   HbA1c = 7.2% [Source: patient.labs.hba1c, Lab Report 2026-04-15]
             Age = 54 years [Source: patient.demographics.dob, Medical Record]
  Threshold: Protocol requires HbA1c < 9.0% for inclusion
  Condition: PASS — 7.2% < 9.0% threshold
```

**Non-compliant example:**
```
Values Verified: Patient lab values within acceptable ranges  ← not values; fails
```

---

### Property 3: Verification Operation

**Definition:** The deterministic procedure that returned PASS or FAIL on this specific determination. Inspectable, reproducible, and re-runnable.

**Requirements:**
- Must describe the operation at sufficient detail to reproduce it
- Must be deterministic — same inputs + same operation = same result
- Must return a binary result: PASS, FAIL, or REQUIRES_REVIEW (not a probability)
- Must not contain probabilistic reasoning — no confidence scores, no similarity thresholds presented as verification
- Must be re-runnable in front of an inspector on the original inputs

**Compliant example:**
```
Verification Operation:
  Operation: THRESHOLD_COMPARISON
  Input A:   patient.labs.hba1c = 7.2
  Operator:  LESS_THAN
  Input B:   protocol.eligibility.inclusion_criterion_3.threshold = 9.0
  Result:    PASS (7.2 < 9.0 = TRUE)
  Operation ID: OP-2026-04-15-001 [reproducible on original inputs]
```

**Non-compliant example:**
```
Verification Operation: AI model assessed eligibility with 94% confidence  ← not an operation; fails
```

---

### Property 4: Boundary Statement

**Definition:** An explicit, specific statement of what this verification did NOT check — the determinations deliberately assigned to the human decision-maker.

**Requirements:**
- Must state what is explicitly outside the scope of this certificate
- Must name the human judgment factors that require clinical, legal, or regulatory expertise
- Must not be generic ("AI may make errors") — must be specific to this determination
- Directly informs the attestation level required under the Site AI Utilization Disclosure Specification (SAID-SPEC-001)

**Compliant example:**
```
Boundary Statement:
  This certificate verifies that the patient's recorded HbA1c value meets 
  the protocol threshold as documented. It does NOT verify:
  - Whether the lab result is clinically accurate given the patient's 
    specific medical context
  - Whether a concurrent medication may affect HbA1c interpretation
  - Whether the investigator's clinical judgment identifies contraindications 
    not captured in the eligibility criteria
  These determinations require Level 3 Clinical Judgment Attestation 
  under SAID-SPEC-001.
```

**Non-compliant example:**
```
Boundary Statement: AI systems may produce errors; human review recommended  ← generic; fails
```

---

## 4. Certificate Schema

### 4.1 Full Schema

```json
{
  "certificate_id": "string — UUID v4, globally unique, immutable",
  "certificate_version": "string — schema version, e.g., '1.0'",
  "generation_timestamp": "string — ISO 8601 UTC, set at generation time, immutable",
  
  "determination_context": {
    "determination_type": "string — controlled vocabulary (see Section 4.2)",
    "protocol_id": "string — protocol identifier",
    "protocol_version": "string — protocol version at time of determination",
    "site_id": "string — anonymized site identifier",
    "jurisdiction": "string — ISO 3166-1 alpha-2",
    "phase": "string — ACTIVATION | EXECUTION"
  },

  "property_1_rule_invoked": {
    "regulatory_citation": {
      "regulation": "string — e.g., '21 CFR 50.25(a)(1)'",
      "description": "string — human-readable description of the requirement",
      "jurisdiction": "string — ISO 3166-1 alpha-2",
      "version_effective": "string — ISO 8601 date this version became effective",
      "last_verified": "string — ISO 8601 date citation was last confirmed current"
    },
    "protocol_citation": {
      "section": "string — e.g., 'Section 7.3.2'",
      "requirement_id": "string — e.g., 'Informed Consent Requirement 1'",
      "protocol_version": "string"
    }
  },

  "property_2_values_verified": {
    "values": [
      {
        "value_id": "string — UUID v4",
        "label": "string — human-readable label",
        "observed_value": "string | number | boolean | null",
        "value_type": "string — PATIENT | PROTOCOL | SITE | DOCUMENT",
        "source_field_path": "string — dot-notation path e.g., 'patient.labs.hba1c'",
        "source_document": "string — document identifier",
        "source_document_date": "string — ISO 8601 date",
        "threshold_or_condition": "string — what the value was checked against",
        "unit": "string | null — e.g., '%', 'years', null for boolean"
      }
    ],
    "absence_checks": [
      {
        "check_id": "string — UUID v4",
        "required_field": "string — field path that was required",
        "result": "string — PRESENT | ABSENT"
      }
    ]
  },

  "property_3_verification_operation": {
    "operation_id": "string — unique operation identifier",
    "operation_type": "string — controlled vocabulary (see Section 4.3)",
    "inputs": [
      {
        "input_label": "string",
        "input_value": "string | number | boolean",
        "source_value_id": "string — references property_2_values_verified value_id"
      }
    ],
    "operator": "string — LESS_THAN | GREATER_THAN | EQUALS | CONTAINS | PRESENT | ABSENT | etc.",
    "result": "string — PASS | FAIL | REQUIRES_REVIEW",
    "result_rationale": "string — why this result was returned",
    "deterministic": true,
    "reproducible": true
  },

  "property_4_boundary_statement": {
    "scope_of_this_certificate": "string — what this certificate verifies",
    "explicitly_out_of_scope": [
      "string — specific item not verified by this certificate"
    ],
    "human_judgment_required_for": [
      "string — specific determination requiring human clinical/legal/regulatory judgment"
    ],
    "recommended_attestation_level": "integer — 1 | 2 | 3 per SAID-SPEC-001"
  },

  "result": "string — PASS | FAIL | REQUIRES_REVIEW",
  
  "lineage": {
    "source_document_hashes": [
      {
        "document_id": "string",
        "hash": "string — SHA-256",
        "hash_timestamp": "string — ISO 8601 UTC"
      }
    ],
    "gate_1_certificate_id": "string | null — Gate 1 adapter certificate that preceded this",
    "gate_2_proof_id": "string | null — Lean4 proof identifier if Gate 2 applied",
    "generation_system": "string — system that generated this certificate",
    "generation_system_version": "string"
  },

  "immutability": {
    "certificate_hash": "string — SHA-256 of the complete certificate content",
    "sealed": true,
    "sealed_timestamp": "string — ISO 8601 UTC"
  }
}
```

### 4.2 Determination Type Vocabulary

| Value | Description |
|---|---|
| `eligibility_criterion` | Patient eligibility criterion application |
| `informed_consent_element` | Informed consent required element check |
| `regulatory_document_completeness` | Required field/section presence in regulatory document |
| `site_qualification` | Site qualification status determination |
| `irb_submission_completeness` | IRB submission package completeness |
| `protocol_deviation_classification` | Protocol deviation severity classification |
| `activation_timeline_prediction` | Site activation timeline estimate |
| `enrollment_velocity_assessment` | Enrollment rate vs. plan assessment |

### 4.3 Verification Operation Type Vocabulary

| Value | Description |
|---|---|
| `THRESHOLD_COMPARISON` | Numeric value compared against a threshold |
| `PRESENCE_CHECK` | Required field or section presence verified |
| `REFERENCE_RESOLUTION` | Cross-reference resolves to existing document |
| `VERSION_CONSISTENCY` | Version references are internally consistent |
| `PATTERN_MATCH` | Value matches required format or pattern |
| `ENUMERATION_MEMBERSHIP` | Value is a member of a required set |
| `TEMPORAL_ORDERING` | Events occur in required chronological sequence |
| `COMPOSITE` | Multiple operation types combined |

---

## 5. Immutability Requirements

### 5.1 What "Immutable" Means

A proof certificate is immutable once sealed. Immutability means:
- No field may be modified after sealing
- The certificate hash must match the content at any future verification
- If a determination changes, a new certificate is generated — the original is retained with SUPERSEDED status
- Deletion is not permitted — superseded certificates are archived, not deleted (21 CFR Part 11 compliance)

### 5.2 Supersession

When a determination changes after a certificate has been sealed:
1. The original certificate status is set to `SUPERSEDED`
2. A new certificate is generated with a new `certificate_id`
3. The new certificate references the superseded certificate in its lineage
4. Both certificates are retained in the audit trail

A superseded certificate is never deleted. It is the evidence of what was believed at a prior point in time.

### 5.3 Bi-Temporal Recording

Certificates record two time dimensions:
- **Effective time:** When the determination was clinically effective
- **Recording time:** When the certificate was generated

These may differ (e.g., a retrospective determination). Both must be recorded. Where they differ by more than 24 hours, the reason for the gap must be documented.

---

## 6. Retention Requirements

| Jurisdiction | Minimum Retention Period |
|---|---|
| US (FDA) | 2 years post-study completion or 2 years post-approval, whichever is later |
| EU (EU CTR 536/2014) | 25 years post-study completion for drug trials |
| Brazil (ANVISA RDC 945) | 5 years post-study completion |
| India (CDSCO NDCTR) | Per Schedule Y requirements |

Certificates must remain accessible (not merely archived) for the duration of any regulatory inspection window.

---

## 7. What a Proof Certificate Is Not

### Not a Confidence Score

A confidence score says: "The model is 94% confident this patient is eligible."

A proof certificate says: "The patient's HbA1c of 7.2% satisfies Inclusion Criterion 3 (threshold: < 9.0%) per 21 CFR 50.25(a)(1) and Protocol AMG-301 Section 7.3.2. The following clinical factors are outside this certificate's scope and require Level 3 attestation."

These are not the same class of evidence. A confidence score cannot be entered into evidence. A proof certificate can.

### Not an Audit Log Export

An audit log records that something happened. A proof certificate proves what was verified before a decision was made. The audit log answers "what occurred?" The proof certificate answers "what was proven before the human decided?"

### Not an Explainability Report

Post-hoc explainability (SHAP values, attention weights, feature importance) describes why a model produced an output. A proof certificate documents what was verified against a regulatory standard before a human acted on that output. Explainability is retrospective. A proof certificate is contemporaneous.

### Not a Dashboard

A dashboard presents information. A proof certificate is an artifact. You cannot hand a dashboard to an inspector. You can hand a proof certificate to an inspector.

---

## 8. The Proof Certificate in the Three-Gate Architecture

The proof certificate is produced at Gate 2 of the three-gate verification architecture. Its relationship to the other gates:

**Gate 1 (Regulatory Compliance Verification):** The adapter produces a Gate 1 certificate documenting which rules were checked and at what severity. This certificate feeds into the Gate 2 proof.

**Gate 2 (Formal Mathematical Proof):** Lean4 verifies the structural properties of the Gate 1 certificate and the underlying determination. The Gate 2 proof is referenced in the lineage of the final proof certificate.

**Gate 3 (Human Oversight):** The proof certificate is presented to the qualified human for attestation. The boundary statement in Property 4 defines exactly what the human must decide. The human's attestation is recorded and linked to the certificate — completing the compliance chain.

---

## 9. Open Questions

1. **Certificate Composition:** When a complex determination depends on multiple sub-determinations (e.g., eligibility requires passing 12 inclusion criteria), should one composite certificate be issued or one certificate per criterion? What are the audit trail implications of each?

2. **Retroactive Certificates:** When a determination was made without a proof certificate (legacy system or process failure), what is the remediation path? Can a retrospective certificate satisfy regulatory requirements?

3. **Certificate Versioning:** As the certificate schema evolves, how are certificates produced under prior schema versions treated? What is the backward compatibility requirement?

4. **Cross-Jurisdiction Certificates:** A global trial requires the same determination to satisfy multiple jurisdictions simultaneously. Does one certificate serve multiple jurisdictions, or is a separate certificate required per jurisdiction?

---

## 10. Version History

| Version | Date | Changes |
|---|---|---|
| 1.0 | May 2026 | Initial specification |

---

*This specification is published under Apache 2.0.*  
*For the boundary between this open standard and the NexTrial.ai production implementation, see BOUNDARY.md.*
