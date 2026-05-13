# Validation Test Harness — Reference Test Cases v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** validation/TEST-HARNESS-001  
**Version:** 1.0  
**Status:** Published  
**Author:** Steven Thompson, NexTrial.ai  
**Date:** May 2026  
**AI-Assisted — Human Review Required**

---

## 1. Purpose

This test harness provides reference test cases for validating that implementations of the framework specifications behave as specified. It covers:

- Proof Certificate schema validation
- Adapter input/output schema validation
- RBQM risk classification logic
- Attestation level assignment rules
- Severity escalation behavior

These test cases are **structural and logical validators**, not functional compliance tests. They test whether an implementation correctly follows the framework's rules — not whether it correctly identifies regulatory violations in real documents.

---

## 2. How to Use This Harness

### 2.1 Reference Adapter

A reference implementation of the adapter interface is provided in `/validation/reference-adapter/`. It:
- Validates input objects against the ADAPTER-SPEC-001 input schema
- Validates output objects against the ADAPTER-SPEC-001 output schema
- Runs all test cases in this harness against expected outputs
- Does NOT make regulatory compliance determinations

### 2.2 Running the Test Cases

```bash
# Clone the repository
git clone https://github.com/nextrial-ai/nextrial-regulatory-framework.git

# Navigate to validation directory
cd nextrial-regulatory-framework/validation

# Install dependencies (Python 3.10+)
pip install -r requirements.txt

# Run full test harness
python run_tests.py --all

# Run specific test suite
python run_tests.py --suite proof-certificate
python run_tests.py --suite adapter-schema
python run_tests.py --suite rbqm-classification
python run_tests.py --suite attestation-level
```

### 2.3 Conformance Reporting

```bash
# Generate conformance report
python run_tests.py --all --report conformance-report.json
```

A conformance report documents which test cases pass, which fail, and which are not applicable to the implementation under test.

---

## 3. Proof Certificate Test Cases

### PC-001: Valid Certificate — PASS Result

**Scenario:** A valid proof certificate with a PASS result, no findings, minimal required fields.

**Input:**
```json
{
  "certificate_id": "550e8400-e29b-41d4-a716-446655440000",
  "input_id": "550e8400-e29b-41d4-a716-446655440001",
  "adapter_id": "US-CTA-1.2.0",
  "adapter_version": "1.2.0",
  "verification_timestamp": "2026-05-01T14:30:00Z",
  "result": "PASS",
  "findings": [],
  "summary": {
    "total_rules_checked": 47,
    "critical_findings": 0,
    "warning_findings": 0,
    "info_findings": 0,
    "compliant_findings": 47
  },
  "lineage": {
    "source_document_hash": "sha256:abc123...",
    "adapter_rule_hash": "sha256:def456...",
    "verification_environment": "reference-adapter-v1.0"
  },
  "human_review_required": false,
  "recommended_attestation_level": 2
}
```

**Expected Validation Result:** VALID  
**Expected Schema Errors:** None

---

### PC-002: Invalid Certificate — Missing Required Field

**Scenario:** A certificate missing the required `certificate_id` field.

**Input:**
```json
{
  "input_id": "550e8400-e29b-41d4-a716-446655440001",
  "adapter_id": "US-CTA-1.2.0",
  "result": "PASS",
  "findings": [],
  "summary": {
    "total_rules_checked": 47,
    "critical_findings": 0,
    "warning_findings": 0,
    "info_findings": 0,
    "compliant_findings": 47
  },
  "lineage": {
    "source_document_hash": "sha256:abc123...",
    "adapter_rule_hash": "sha256:def456...",
    "verification_environment": "reference-adapter-v1.0"
  },
  "human_review_required": false,
  "recommended_attestation_level": 2
}
```

**Expected Validation Result:** INVALID  
**Expected Schema Error:** `certificate_id` is required but missing

---

### PC-003: Invalid Certificate — PASS with CRITICAL Findings

**Scenario:** A certificate with result PASS but one or more CRITICAL findings. This is logically invalid — CRITICAL findings must produce a FAIL result.

**Input:**
```json
{
  "certificate_id": "550e8400-e29b-41d4-a716-446655440002",
  "input_id": "550e8400-e29b-41d4-a716-446655440001",
  "adapter_id": "US-CTA-1.2.0",
  "adapter_version": "1.2.0",
  "verification_timestamp": "2026-05-01T14:30:00Z",
  "result": "PASS",
  "findings": [
    {
      "finding_id": "550e8400-e29b-41d4-a716-446655440003",
      "severity": "CRITICAL",
      "rule_invoked": {
        "citation": "21 CFR 50.25(a)(1)",
        "description": "Required element of informed consent"
      },
      "determination": "NON_COMPLIANT",
      "field_path": "protocol.informed_consent.required_elements",
      "observed_value": null,
      "expected_condition": "Field must be present and contain all required elements",
      "rationale": "Required informed consent element is absent",
      "human_review_required": true
    }
  ],
  "summary": {
    "total_rules_checked": 47,
    "critical_findings": 1,
    "warning_findings": 0,
    "info_findings": 0,
    "compliant_findings": 46
  },
  "lineage": {
    "source_document_hash": "sha256:abc123...",
    "adapter_rule_hash": "sha256:def456...",
    "verification_environment": "reference-adapter-v1.0"
  },
  "human_review_required": true,
  "recommended_attestation_level": 3
}
```

**Expected Validation Result:** INVALID  
**Expected Logic Error:** `result` is PASS but `summary.critical_findings` is 1. CRITICAL findings require FAIL result.

---

### PC-004: Valid Certificate — WARNING Result

**Scenario:** A valid certificate with WARNING result and one warning finding.

**Expected Validation Result:** VALID  
**Validation Note:** WARNING result with only warning findings (no critical) is valid.

---

### PC-005: Invalid Certificate — Summary Count Mismatch

**Scenario:** A certificate where `summary.critical_findings` (2) does not match the actual count of CRITICAL findings in the `findings` array (1).

**Expected Validation Result:** INVALID  
**Expected Logic Error:** Summary counts do not match findings array contents.

---

## 4. Adapter Schema Test Cases

### AS-001: Valid Input — Complete

**Scenario:** A complete, valid adapter input object with all optional fields populated.

**Expected Validation Result:** VALID

---

### AS-002: Valid Input — Minimal (Required Fields Only)

**Scenario:** A valid adapter input with only required fields. Optional fields absent.

**Expected Validation Result:** VALID  
**Note:** Adapters must function with minimal input — they cannot require optional fields.

---

### AS-003: Invalid Input — Unknown Document Type

**Scenario:** An input with `source_document_type` set to a value not in the controlled vocabulary.

**Input Fragment:**
```json
{
  "source_document_type": "executive_summary"
}
```

**Expected Validation Result:** INVALID  
**Expected Error:** `source_document_type` value not in controlled vocabulary.

---

### AS-004: Valid Output — FAIL with Multiple Findings

**Scenario:** A valid adapter output with FAIL result and multiple findings of mixed severity.

**Validation Checks:**
- `result` is FAIL ✓ (because critical_findings > 0)
- `human_review_required` is true ✓ (because at least one finding has human_review_required: true)
- Summary counts match findings array ✓

**Expected Validation Result:** VALID

---

### AS-005: Determinism Check

**Scenario:** The same input submitted twice produces byte-identical output (excluding timestamp).

**Test Method:**
1. Submit input A to adapter → record output O1
2. Submit input A to adapter again → record output O2
3. Compare O1 and O2 excluding `verification_timestamp`

**Expected Result:** O1 == O2 (excluding timestamp)  
**If not equal:** Adapter fails determinism requirement — non-deterministic logic is present.

---

## 5. RBQM Classification Test Cases

### RC-001: Composite HIGH — Single HIGH Dimension

**Scenario:** Site Risk is HIGH, Protocol Risk is LOW, Population Risk is LOW.

**Input:**
```json
{
  "site_risk": "HIGH",
  "protocol_risk": "LOW",
  "population_risk": "LOW"
}
```

**Expected Composite:** HIGH  
**Rule Applied:** Any HIGH dimension = composite HIGH

---

### RC-002: Composite MEDIUM — All MEDIUM

**Scenario:** All three dimensions are MEDIUM.

**Expected Composite:** MEDIUM

---

### RC-003: Composite LOW — All LOW

**Scenario:** All three dimensions are LOW.

**Expected Composite:** LOW

---

### RC-004: Composite HIGH — Multiple HIGH Dimensions

**Scenario:** Site Risk is HIGH, Protocol Risk is HIGH, Population Risk is MEDIUM.

**Expected Composite:** HIGH  
**Gate 1 Entry Condition:** Mitigation documentation required for Site Risk and Protocol Risk dimensions.

---

### RC-005: Gate Entry Authorization — Unmitigated HIGH

**Scenario:** Composite HIGH, mitigation documentation NOT complete.

**Expected Gate 1 Entry Authorized:** false

---

### RC-006: Gate Entry Authorization — Mitigated HIGH

**Scenario:** Composite HIGH, mitigation documentation complete for all HIGH dimensions.

**Expected Gate 1 Entry Authorized:** true

---

### RC-007: Cold-Start Default — Insufficient Site Data

**Scenario:** Site Risk dimension has `data_sufficient: false`, `cold_start_applied: true`.

**Expected Classification:** MEDIUM (cold-start default)  
**Expected Documentation:** `cold_start_reason` must be present and non-empty.

---

## 6. Attestation Level Assignment Test Cases

### AL-001: Administrative Determination → Level 1

**Scenario:** Output type is `administrative`, no patient safety implication.

**Expected Minimum Attestation Level:** 1

---

### AL-002: Regulatory Document Content → Level 2

**Scenario:** Output type is `regulatory_document_content`.

**Expected Minimum Attestation Level:** 2

---

### AL-003: Patient Safety Determination → Level 3

**Scenario:** Output type is `patient_safety_determination`.

**Expected Minimum Attestation Level:** 3

---

### AL-004: Brazil Medical Determination Override

**Scenario:** Output type is `eligibility_determination`, jurisdiction is Brazil (CFM 2.454 applies).

**Expected Minimum Attestation Level:** 3 (jurisdiction override from Level 2 default)

---

### AL-005: EU High-Risk AI Output → Level 2 Minimum

**Scenario:** Output from a system classified as high-risk AI under EU AI Act, jurisdiction is EU.

**Expected Minimum Attestation Level:** 2 (cannot be assigned Level 1 for EU high-risk AI outputs)

---

## 7. Test Fixtures

Reference test fixtures are provided in `/validation/fixtures/`:

```
/validation/fixtures/
├── valid-certificate-pass.json
├── valid-certificate-warning.json
├── valid-certificate-fail.json
├── invalid-certificate-missing-id.json
├── invalid-certificate-pass-with-critical.json
├── invalid-certificate-summary-mismatch.json
├── valid-adapter-input-complete.json
├── valid-adapter-input-minimal.json
├── invalid-adapter-input-unknown-doctype.json
├── rbqm-all-high.json
├── rbqm-all-low.json
├── rbqm-mixed-high-medium.json
├── rbqm-cold-start-site.json
└── attestation-level-assignments.json
```

Each fixture file includes:
- The input object
- The expected validation result
- The expected output (where applicable)
- Notes on the specific behavior being tested

---

## 8. Reporting Conformance

When implementing this framework, implementers are encouraged to run this test harness and report their conformance results. The conformance report should be included in any regulatory validation documentation for the implementing system.

**Conformance Statement Template:**
> "This implementation was tested against the nextrial-regulatory-framework validation test harness v[X.X]. [N] of [N] test cases pass. The following test cases are not applicable: [list with rationale]. The following test cases fail: [list with issue log reference]."

---

## 9. Adding Test Cases

Community contributions of additional test cases are welcomed via pull request. New test cases should:

- Cover a specific edge case or failure mode not already in the harness
- Include a clear scenario description
- Include expected inputs and expected results
- Reference the specification section being tested
- Not include real patient data, real protocol content, or anything confidential

---

## 10. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | May 2026 | Initial test harness |

---

*This test harness is published under Apache 2.0.*
