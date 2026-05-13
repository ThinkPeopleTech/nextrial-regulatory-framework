# Regulatory Adapter Interface Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** ADAPTER-SPEC-001  
**Version:** 1.0  
**Status:** Published  
**Author:** Steven Thompson, NexTrial.ai  
**Date:** May 2026  
**AI-Assisted — Human Review Required**

---

## 1. Purpose

This specification defines the **interface contract** for regulatory compliance adapters used in Gate 1 of the three-gate verification architecture. It defines what an adapter must expose, what it must accept as input, and what it must return as output.

This specification defines the **interface only**. It does not define how any adapter implements compliance checking. Implementation is the responsibility of the adapter developer and is governed by the adapter's own documentation.

The interface is designed to be:
- **Deterministic:** Same input + same adapter version = same result
- **Version-controlled:** Every adapter version is independently auditable
- **Independently executable:** Adapters can be run without the broader AI system
- **Jurisdiction-specific:** Each adapter covers exactly one regulatory jurisdiction

---

## 2. Adapter Identity

Every adapter must declare an identity block conforming to this schema:

```json
{
  "adapter_identity": {
    "adapter_id": "string — unique identifier, format: JURISDICTION-DOMAIN-VERSION",
    "jurisdiction": "string — ISO 3166-1 alpha-2 country code or regional code",
    "regulatory_domain": "string — e.g., 'clinical_trial_activation', 'informed_consent', 'data_privacy'",
    "version": "string — semantic versioning (MAJOR.MINOR.PATCH)",
    "effective_date": "string — ISO 8601 date when this version became authoritative",
    "supersedes": "string | null — adapter_id of the version this supersedes, or null",
    "regulatory_references": [
      {
        "citation": "string — e.g., '21 CFR 50.25(a)(1)'",
        "description": "string — human-readable description of the cited requirement",
        "last_verified": "string — ISO 8601 date this citation was last confirmed accurate"
      }
    ],
    "developer": "string — organization developing this adapter",
    "contact": "string — contact for questions about this adapter",
    "audit_hash": "string — SHA-256 hash of this adapter's rule set at publication"
  }
}
```

**Example:**

```json
{
  "adapter_identity": {
    "adapter_id": "US-CTA-1.2.0",
    "jurisdiction": "US",
    "regulatory_domain": "clinical_trial_activation",
    "version": "1.2.0",
    "effective_date": "2025-01-15",
    "supersedes": "US-CTA-1.1.0",
    "regulatory_references": [
      {
        "citation": "21 CFR 50.25(a)(1)",
        "description": "Required element of informed consent — statement of research",
        "last_verified": "2025-01-10"
      }
    ],
    "developer": "NexTrial.ai",
    "contact": "framework@nextrial.ai",
    "audit_hash": "sha256:a3f4..."
  }
}
```

---

## 3. Input Schema

### 3.1 Adapter Input Object

Every adapter receives a standardized input object. The adapter may use all or a subset of the fields, but must not require fields outside this schema.

```json
{
  "input": {
    "input_id": "string — UUID v4, unique per verification request",
    "input_timestamp": "string — ISO 8601 UTC",
    "source_document_type": "string — controlled vocabulary (see Section 3.2)",
    "structured_content": "object — the document content in USDM 3.0 format or equivalent structured representation",
    "protocol_metadata": {
      "protocol_id": "string",
      "version": "string",
      "therapeutic_area": "string — MedDRA therapeutic area code",
      "phase": "string — I | II | III | IV | Other",
      "sponsor_id": "string — anonymized identifier"
    },
    "site_metadata": {
      "site_id": "string — anonymized identifier",
      "jurisdiction": "string — ISO 3166-1 alpha-2",
      "site_type": "string — Academic | Community | Network | Other"
    },
    "prior_verification_results": [
      {
        "adapter_id": "string",
        "result_summary": "string — PASS | FAIL | WARNING"
      }
    ]
  }
}
```

### 3.2 Source Document Type Vocabulary

Adapters must use the following controlled vocabulary for `source_document_type`:

| Value | Description |
|-------|-------------|
| `protocol` | Clinical trial protocol |
| `informed_consent_form` | Patient informed consent document |
| `investigator_brochure` | Investigator brochure |
| `site_qualification_report` | Site qualification or feasibility report |
| `regulatory_submission_package` | Complete regulatory submission package |
| `irb_application` | IRB / Ethics committee application |
| `clinical_study_report` | Clinical study report |
| `site_activation_checklist` | Site activation readiness checklist |

---

## 4. Output Schema

### 4.1 Adapter Output Object

Every adapter must return a structured output conforming to this schema. The output is a **proof certificate** as defined in the Proof Certificate Specification v1.0.

```json
{
  "output": {
    "certificate_id": "string — UUID v4, globally unique",
    "input_id": "string — UUID v4, matches input_id from input object",
    "adapter_id": "string — matches adapter_identity.adapter_id",
    "adapter_version": "string — matches adapter_identity.version",
    "verification_timestamp": "string — ISO 8601 UTC",
    "result": "string — PASS | FAIL | WARNING",
    "findings": [
      {
        "finding_id": "string — UUID v4",
        "severity": "string — CRITICAL | WARNING | INFO",
        "rule_invoked": {
          "citation": "string — regulatory citation",
          "description": "string — what was checked"
        },
        "determination": "string — COMPLIANT | NON_COMPLIANT | REQUIRES_REVIEW",
        "field_path": "string — dot-notation path to the field in the structured content",
        "observed_value": "string | null — what the adapter found (null if absence is the issue)",
        "expected_condition": "string — what the rule requires",
        "rationale": "string — why this determination was reached",
        "human_review_required": "boolean"
      }
    ],
    "summary": {
      "total_rules_checked": "integer",
      "critical_findings": "integer",
      "warning_findings": "integer",
      "info_findings": "integer",
      "compliant_findings": "integer"
    },
    "lineage": {
      "source_document_hash": "string — SHA-256 hash of the input structured content",
      "adapter_rule_hash": "string — SHA-256 hash of the adapter rule set used",
      "verification_environment": "string — description of execution environment"
    },
    "human_review_required": "boolean — true if any finding has human_review_required: true",
    "recommended_attestation_level": "integer — 1 | 2 | 3 (see SAID-SPEC-001)"
  }
}
```

---

## 5. Severity Classification

### 5.1 CRITICAL

**Definition:** A finding that represents a clear violation of a mandatory regulatory requirement. Regulatory submissions containing a CRITICAL finding are not compliant.

**Gate Behavior:** CRITICAL findings block Gate 1 progression. The overall adapter result is FAIL.

**Examples:**
- Missing required element of informed consent (21 CFR 50.25(a))
- Protocol lacks required sections specified in applicable regulation
- IRB membership does not satisfy composition requirements
- Missing CONEP/CEP authorization where required (Brazil)

### 5.2 WARNING

**Definition:** A finding that indicates a potential compliance issue requiring human judgment to resolve. The issue may or may not constitute a violation depending on context.

**Gate Behavior:** WARNING findings do not block Gate 1 progression but require documentation. The overall adapter result is WARNING (not FAIL, not PASS).

**Examples:**
- Informed consent language may be above recommended reading level
- Protocol section present but potentially incomplete against regulation guidance
- Site qualification data is current but approaching expiration
- Jurisdiction-specific guidance document (not regulation) recommends a practice that is absent

### 5.3 INFO

**Definition:** A finding that provides information relevant to compliance but does not represent a violation or potential violation.

**Gate Behavior:** INFO findings do not affect Gate 1 result. Logged for audit trail completeness.

**Examples:**
- Field present and compliant — noting the regulatory citation for audit trail
- Optional regulatory guidance recommendation satisfied
- Prior submission precedent referenced

---

## 6. Determinism Requirements

### 6.1 The Core Requirement

An adapter must be deterministic: given the same input and the same adapter version, it must always produce the same output.

This requirement is non-negotiable. It is what makes the verification architecture auditable and reproducible.

### 6.2 What "Same" Means

- **Same input:** Identical structured content, byte-for-byte
- **Same adapter version:** The same `adapter_id` including version, with the same `audit_hash`
- **Same output:** Identical `result`, identical `findings` array (including order), identical `summary`

### 6.3 Sources of Non-Determinism to Avoid

Adapters must not:
- Make external API calls that can return different results
- Use probabilistic or statistical reasoning to classify findings
- Incorporate model outputs (LLM, classifier) in the determination logic
- Use timestamp-dependent logic that changes the classification of findings over time (timestamps are logged, not used in logic)
- Use random seeds in any part of the rule evaluation

### 6.4 Permitted Sources of Time-Dependence

Adapters **may** use current date for one purpose only: determining whether a site qualification document, PI CV, or other time-bounded document has expired. These checks must:
- Use a fixed evaluation date passed as part of the input (not the adapter's system clock)
- Document the evaluation date in the output lineage
- Have a deterministic expiration rule (e.g., "valid for 24 months from issuance")

---

## 7. Version Control Requirements

### 7.1 Versioning Scheme

Adapters must use semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR:** Regulatory requirement change that produces different results for previously-compliant documents (breaking change)
- **MINOR:** New rules added; existing rules unchanged (additive change)
- **PATCH:** Clarification, documentation, or bug fix that does not change compliance determinations

### 7.2 Version Audit Requirements

Every version of an adapter must:
- Be independently retrievable by version number
- Have an `audit_hash` that uniquely identifies its rule set
- Have an `effective_date` from which its determinations are authoritative
- Have a documented change log from the prior version

### 7.3 Concurrent Version Support

Adapters must support concurrent verification against multiple versions when:
- A regulatory change is in a transition period
- A prior study's records need to be verified against the rules in effect at time of activation
- A sponsor is choosing between regulatory strategies

Concurrent version support requires that the version used for each determination be recorded in the proof certificate lineage.

---

## 8. Independence Requirements

### 8.1 Structural Independence

Each adapter covers exactly one jurisdiction. An adapter must not:
- Make compliance determinations for a jurisdiction other than its declared jurisdiction
- Reference rules from another adapter's rule set
- Produce findings that combine requirements from multiple jurisdictions

Cross-jurisdiction analysis (e.g., "this document must satisfy both FDA and ANVISA requirements") requires two separate adapter invocations, one per jurisdiction.

### 8.2 Operational Independence

Adapters must be executable:
- Without access to the broader AI system that may invoke them
- Without access to any AI model (LLM, classifier, neural network)
- Without network access (all required regulatory reference data is embedded in the adapter)
- Without a user interface

An adapter that cannot be run as a standalone command-line tool against a test input does not satisfy the independence requirement.

### 8.3 Verification of Independence

Adapter developers are expected to publish:
- A test input set with known expected outputs
- Instructions for running the adapter standalone
- A hash of the expected test outputs for each adapter version

---

## 9. Adapter Registry

Adapters conforming to this specification should be registered in the adapter registry at `/regulatory-mappings/adapter-registry.json`. The registry entry for each adapter includes:

```json
{
  "adapter_id": "string",
  "jurisdiction": "string",
  "regulatory_domain": "string",
  "version": "string",
  "status": "string — Active | Superseded | Deprecated",
  "repository_path": "string — relative path to adapter source",
  "developer": "string",
  "last_verified": "string — ISO 8601 date"
}
```

---

## 10. Reference Implementation

A reference implementation of this adapter interface is provided at `/validation/reference-adapter/` for testing purposes. The reference implementation:

- Validates input objects against the input schema
- Validates output objects against the output schema
- Includes test fixtures for each field
- Is not a functional regulatory compliance adapter — it validates structure, not compliance

Functional compliance adapters for FDA, ANVISA, CDSCO, and EU AI Act are part of the NexTrial.ai production implementation and are documented in the BOUNDARY.md document.

---

## 11. Open Questions

1. **Schema Evolution:** How should the input and output schemas evolve as regulatory requirements change? What is the deprecation process for fields?

2. **Partial Input Handling:** How should an adapter handle inputs where only a subset of fields are available (e.g., early-stage protocol before site selection)?

3. **Third-Party Adapter Certification:** Should the framework define a certification process for third-party adapters? Who certifies? What does certification require?

4. **Multi-Jurisdiction Documents:** Some documents (e.g., global protocols) are simultaneously submitted to multiple jurisdictions. Should the interface support a "multi-jurisdiction" invocation mode, or require separate per-jurisdiction calls?

5. **Regulatory Change Lag:** Regulations change. How should an adapter handle the period between a regulatory change being announced and the adapter version being updated? Who is responsible for monitoring regulatory changes?

---

## 12. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | May 2026 | Initial specification |

---

## 13. Contributing

This specification is developed through the open co-development process described in [CONTRIBUTING.md](../CONTRIBUTING.md). The open questions in Section 11 are explicit targets for community input.

---

*This specification is published under Apache 2.0. It defines an interface contract — not an implementation. Functional adapters for FDA, ANVISA, CDSCO, EU AI Act, and CFM 2.454 are part of the NexTrial.ai production implementation. See [BOUNDARY.md](../BOUNDARY.md) for the explicit boundary.*
