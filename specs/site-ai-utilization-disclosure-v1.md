# Site AI Utilization Disclosure Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** SAID-SPEC-001  
**Version:** 1.0  
**Status:** Published  
**Author:** Steven Thompson, NexTrial.ai  
**Date:** May 2026  
**AI-Assisted — Human Review Required**

---

## 1. Purpose

This specification defines what clinical trial sites must disclose when AI systems are used in trial activation or execution decisions. It establishes attestation levels, override protocols, and liability allocation frameworks that satisfy ICH E6(R3), EU AI Act (2024/1689), and CFM Resolution 2.454 requirements.

This document defines the **disclosure interface**. It does not specify how any AI system produces its outputs — that is the responsibility of the implementing system's boundary documentation.

---

## 2. Scope

This specification applies when an AI system:

- Contributes to protocol eligibility determinations
- Generates or validates regulatory submission documents
- Assesses site readiness or qualification status
- Produces activation timelines with predictive components
- Monitors execution variance against protocol plans

It does not apply to AI systems used solely for administrative scheduling, non-clinical logistics, or data entry assistance with no decision-relevant output.

---

## 3. The Three PI Attestation Levels

### Level 1 — Review Attestation

**Definition:** The qualified investigator has reviewed the AI system's output and found no reason to override it.

**Applicable When:**
- AI output concerns administrative or logistical determinations
- Determination has no direct patient safety implication
- Output is fully reconstructable from source documents without AI assistance

**PI Statement (canonical):**
> "I have reviewed the AI-generated output identified by [Certificate ID]. The output is consistent with my clinical assessment. I accept this output without modification."

**Documentation Requirement:**
- Certificate ID recorded in trial master file
- PI identity and credential verified
- Timestamp logged (UTC, immutable)
- No override documentation required if accepted as-is

---

### Level 2 — Independent Verification Attestation

**Definition:** The qualified investigator has independently verified the AI system's output against source documents and confirms its accuracy.

**Applicable When:**
- Output concerns regulatory document content
- Output concerns eligibility criteria application
- Output has a direct bearing on IRB submission content
- Jurisdiction-specific regulation requires independent verification (e.g., ANVISA submission workflows, FDA Form FDA 1572 content)

**PI Statement (canonical):**
> "I have independently verified the AI-generated output identified by [Certificate ID] against the source documents identified in the proof certificate lineage. The output accurately reflects the source materials. I attest to its regulatory accuracy."

**Documentation Requirement:**
- Certificate ID and lineage trace recorded
- Source documents cross-referenced by field path, not page number
- PI credential and delegation authority confirmed
- Independent verification log entry (separate from AI system audit trail)
- Timestamp logged (UTC, immutable)

---

### Level 3 — Clinical Judgment Attestation

**Definition:** The qualified investigator exercises clinical judgment that supersedes or supplements the AI system's output, accepting full clinical responsibility for the determination.

**Applicable When:**
- Patient eligibility determination involves clinical interpretation beyond protocol text
- AI output conflicts with investigator's clinical assessment
- Protocol ambiguity requires clinical interpretation
- Safety signal assessment requires medical judgment
- Any determination where the investigator's clinical knowledge is the primary basis for the decision

**PI Statement (canonical):**
> "I have reviewed the AI-generated output identified by [Certificate ID]. My clinical judgment [differs from / supplements] this output as documented in [Override Record ID]. My determination is [statement of determination]. I accept full clinical responsibility for this determination."

**Documentation Requirement:**
- Certificate ID and override reason documented
- Clinical basis for override stated (not required to be exhaustive, required to be substantive)
- Override Record ID generated and logged
- PI credential, license number, and jurisdiction confirmed
- Supervisor notification if protocol-required
- Timestamp logged (UTC, immutable)
- Override flagged in trial master file

---

## 4. Attestation Level Assignment

### Who Assigns Attestation Levels

Attestation levels are assigned by the **sponsor or principal investigator** at the time of protocol configuration. They are **not** assigned by the AI system.

The AI system may recommend a minimum attestation level based on its output type classification. The sponsor or PI may increase but not decrease the recommended minimum without documented justification.

### Assignment Criteria

| Output Type | Minimum Attestation Level |
|-------------|--------------------------|
| Administrative determination | Level 1 |
| Regulatory document content | Level 2 |
| Eligibility criteria application | Level 2 |
| IRB submission content | Level 2 |
| Patient safety determination | Level 3 |
| Clinical eligibility judgment | Level 3 |
| Protocol deviation assessment | Level 3 |
| Safety signal classification | Level 3 |

### Jurisdiction-Specific Overrides

| Jurisdiction | Override Rule |
|-------------|---------------|
| Brazil (CFM 2.454) | Medical determinations require Level 3 regardless of protocol configuration |
| EU (AI Act Art. 14) | High-risk AI outputs require meaningful human oversight — Level 2 minimum |
| India (CDSCO NDCTR) | Investigator attestation required for all regulatory submissions — Level 2 minimum |
| US (21 CFR 312) | No statutory override beyond GCP; sponsor discretion governs |

---

## 5. Override Protocol

### 5.1 Initiating an Override

An override occurs when a qualified investigator determines that the AI system's output should not be used as generated. Overrides are not failures — they are the intended function of human oversight.

**Override Trigger Conditions:**
- AI output is factually incorrect against source documents
- AI output is clinically inappropriate given patient context
- AI output conflicts with investigator's regulatory interpretation
- Protocol ambiguity is resolved differently by the investigator than by the AI system
- New information known to the investigator was not available to the AI system at generation time

### 5.2 Override Documentation Requirements

Every override must document:

1. **Certificate ID** of the output being overridden
2. **Override Reason Category:** [Factual Error | Clinical Judgment | Regulatory Interpretation | New Information | Protocol Ambiguity]
3. **Override Basis:** Substantive statement of the investigator's basis (minimum 25 words)
4. **Replacement Determination:** The investigator's determination that replaces the AI output
5. **Source Documents Relied Upon:** If the override is based on documentary evidence, field paths to that evidence
6. **PI Identity:** Name, credential, license number, jurisdiction
7. **Override Timestamp:** UTC, immutable
8. **Supervisor Notification:** If required by protocol, record of notification

### 5.3 Override Audit Trail

Override records are:
- Immutable once created
- Bi-temporal (effective time + recording time)
- 21 CFR Part 11 compliant where US regulations apply
- LGPD compliant where Brazilian data is involved
- Linked to the original certificate via Certificate ID
- Retained for the duration required by the applicable jurisdiction's TMF regulation

### 5.4 Pattern Analysis

Sponsors and CROs should conduct periodic analysis of override patterns to identify:
- Systematic AI output errors requiring model correction
- Protocol language that consistently generates ambiguous AI outputs
- Sites with override rates significantly above or below network average
- Jurisdiction-specific interpretation differences

This analysis is a quality management function, not a retrospective audit. Override frequency alone is not a performance metric.

---

## 6. Liability Allocation Framework

### 6.1 Three Failure Modes

AI-assisted trial decisions can fail in three distinct ways. Each has a distinct liability profile.

**Failure Mode 1: System Verification Failure**

Definition: The AI system produced an output that was incorrect, and the verification architecture (Layers 1–3 of the three-gate stack) failed to detect the error.

Responsible Party: The AI system vendor, subject to the terms of the applicable services agreement and the system's documented specification.

Applicable Conditions:
- The verification architecture was implemented as specified
- The output was within the scope of the system's documented capabilities
- The error was not detectable through the attestation process reasonably applied

**Failure Mode 2: Attestation Scope Failure**

Definition: The AI system produced an output that was incorrect, the verification architecture flagged it or the error was detectable through the required attestation process, but the investigator attested without proper review.

Responsible Party: The attesting investigator and, depending on supervision structure, the sponsor.

Applicable Conditions:
- The attestation was performed but was not substantive (e.g., rubber-stamp)
- The error was detectable through the attestation level assigned
- Documentation shows attestation occurred but evidence of actual review is absent

**Failure Mode 3: Clinical Judgment Failure**

Definition: The investigator exercised Level 3 clinical judgment, overrode or modified the AI output, and the resulting clinical determination caused harm.

Responsible Party: The attesting investigator, with standard medical liability principles applying.

Applicable Conditions:
- Level 3 attestation was properly documented
- The AI system output was accurately produced and verified
- The investigator's clinical judgment departed from the AI output
- The harm resulted from the departure, not from the AI output

### 6.2 Shared Liability Conditions

Shared liability applies when:
- Attestation level assignment was misconfigured (sponsor responsibility)
- Override documentation was incomplete but override was clinically appropriate (investigator + sponsor)
- System specification was misrepresented at procurement (vendor responsibility)
- Training on the attestation protocol was inadequate (sponsor responsibility)

### 6.3 Limitations

This framework provides a conceptual structure for liability analysis. It does not constitute legal advice. Applicable law, jurisdiction, and contract terms govern actual liability. This framework should be reviewed by qualified legal counsel before incorporation into any agreement or protocol.

---

## 7. Audit Trail Requirements

### 7.1 Minimum Audit Trail Elements

For every AI-assisted determination subject to this specification, the following must be logged:

| Field | Description | Format |
|-------|-------------|--------|
| `certificate_id` | Unique identifier for the AI output | UUID v4 |
| `output_type` | Classification of the output | Controlled vocabulary |
| `attestation_level` | Level assigned and level performed | 1 / 2 / 3 |
| `pi_identity` | Attesting investigator | Name + credential + license |
| `attestation_timestamp` | When attestation occurred | ISO 8601 UTC |
| `override_flag` | Whether an override was initiated | Boolean |
| `override_record_id` | If override, the override record ID | UUID v4 or null |
| `jurisdiction` | Applicable regulatory jurisdiction | ISO country code |
| `retention_period` | Required retention duration | ISO 8601 duration |

### 7.2 Immutability Requirements

Audit trail records must be:
- Write-once after creation
- Tamper-evident (cryptographic hash recommended)
- Bi-temporal where the difference between effective time and recording time is material
- Reconstructable from the original certificate and override records

### 7.3 Retention

| Jurisdiction | Minimum Retention |
|-------------|-------------------|
| US (FDA) | 2 years post-study completion or 2 years post-approval, whichever is later |
| EU | Per EU Clinical Trials Regulation 536/2014 |
| Brazil | 5 years post-study completion (ANVISA/RDC 945) |
| India | Per CDSCO NDCTR 2019 requirements |

---

## 8. Open Questions

The following questions are not resolved in v1.0 and are active in co-development:

1. **Rubber-Stamp Risk:** How do we distinguish substantive Level 2 review from rubber-stamp attestation in the audit trail? (Raised by Dominique Chesnais critique)

2. **Remote Attestation:** Does the attestation protocol change when the PI is remote (DCT context)? Does jurisdiction matter?

3. **Delegation:** Can attestation be delegated to sub-investigators? Under what conditions? How is delegation documented?

4. **Protocol-Specific Minimums:** Should sponsors be required to document their attestation level assignment rationale in the protocol, or is post-hoc documentation sufficient?

5. **Override Frequency Thresholds:** What override rate triggers a required systemic review? Is there a defensible threshold, or is this always judgment-based?

---

## 9. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | May 2026 | Initial specification |

---

## 10. Contributing

This specification is developed through the open co-development process described in [CONTRIBUTING.md](../CONTRIBUTING.md). To propose changes, see the pull request process and the open questions tracked in [/co-development/open-questions.md](../co-development/open-questions.md).

---

*This specification is published under Apache 2.0. It defines an interface and a framework — not an implementation. For the boundary between this open standard and the NexTrial.ai production implementation, see [BOUNDARY.md](../BOUNDARY.md).*
