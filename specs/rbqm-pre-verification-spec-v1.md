# Risk-Based Quality Management Pre-Verification Layer Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** RBQM-SPEC-001  
**Version:** 1.0  
**Status:** Published  
**Author:** Steven Thompson, NexTrial.ai  
**Date:** May 2026  
**AI-Assisted — Human Review Required**

---

## 1. Purpose

This specification defines the Risk-Based Quality Management (RBQM) pre-verification layer that sits above the three-gate verification architecture. It addresses the question the three gates do not answer: **"Should this trial activation happen at all, given what we know about site readiness, protocol complexity, and patient population fit?"**

The RBQM layer does not replace the three gates. It precedes them. It ensures that the inputs entering the verification architecture are risk-stratified before any AI output is generated.

This layer was added in response to the gap identified during adversarial review of the framework against EU AI Act Article 9 (risk management system) and ICH E6(R3) principles-based quality management requirements.

---

## 2. Regulatory Basis

| Regulation | Relevant Requirement |
|------------|---------------------|
| ICH E6(R3) | Principles-based quality management; risk-proportionate approach to monitoring and oversight |
| EU AI Act Art. 9 | High-risk AI systems must implement a risk management system throughout the lifecycle |
| EU AI Act Art. 9(e) | Risk management system must address risks that may emerge when the AI system is used as intended |
| FDA 21 CFR 312 | Sponsor responsibility for adequate monitoring based on risk |
| ISO 14971 | Risk management for medical devices (reference model for structured risk assessment) |
| ICH Q9(R1) | Quality risk management principles |

---

## 3. Architecture Position

```
┌─────────────────────────────────────────────────┐
│         RBQM PRE-VERIFICATION LAYER             │
│   "Should this activation proceed?"             │
│                                                  │
│  ┌──────────────┐  ┌────────────┐  ┌──────────┐ │
│  │  Site Risk   │  │ Protocol   │  │Population│ │
│  │  Assessment  │  │   Risk     │  │   Risk   │ │
│  └──────────────┘  └────────────┘  └──────────┘ │
│                                                  │
│  Output: Risk Classification (H/M/L) per dim.   │
│  Output: Mitigation Requirements before Gate 1  │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│         GATE 1: Regulatory Compliance           │
│   "Is this output compliant?"                   │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│         GATE 2: Formal Mathematical Proof       │
│   "Can we prove structural correctness?"        │
└─────────────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────┐
│         GATE 3: Human Oversight                 │
│   "Does the qualified human agree?"             │
└─────────────────────────────────────────────────┘
```

---

## 4. The Three Risk Dimensions

### Dimension 1: Site Risk

**Definition:** The risk that a specific site's operational characteristics will compromise protocol adherence, data quality, or patient safety during the trial.

**Assessment Components:**

| Component | Description | Data Source |
|-----------|-------------|-------------|
| Deviation History | Prior protocol deviation rate and severity classification | Site master file, prior trial records |
| PI Load | Active protocol count vs. site capacity | Site investigator profile |
| Infrastructure Readiness | Equipment, staffing, and system requirements vs. protocol demands | Site qualification checklist |
| CAPA Status | Open corrective and preventive actions from prior audits | QMS records |
| Regulatory History | Prior FDA/ANVISA/CDSCO inspection findings | Public databases + site disclosure |
| Staff Turnover | Key personnel changes since last activation | Site coordinator records |

**Classification Framework:**

| Risk Level | Criteria |
|------------|----------|
| HIGH | Any CRITICAL deviation in prior 24 months; open CAPA with unresolved root cause; PI load > threshold; active regulatory action |
| MEDIUM | Non-critical deviations in prior 24 months; CAPA closed < 6 months; PI load at threshold; infrastructure gaps with documented remediation |
| LOW | Clean deviation history; no open CAPAs; PI load within capacity; infrastructure confirmed |

**Mitigation Requirements by Risk Level:**

- **HIGH:** Sponsor pre-activation site visit required; CAPA resolution confirmation required; reduced activation timeline estimate; escalated monitoring plan
- **MEDIUM:** Site coordinator confirmation call required; CAPA status documented; monitoring plan reviewed
- **LOW:** Standard activation process; monitoring plan as designed

---

### Dimension 2: Protocol Risk

**Definition:** The risk that the protocol's complexity, amendment history, or operational demands will generate deviations that compromise data integrity or patient safety.

**Assessment Components:**

| Component | Description | Data Source |
|-----------|-------------|-------------|
| Complexity Score | Derived from visit burden, procedure count, biomarker requirements, and endpoint complexity | Protocol document (M11 structured) |
| Amendment Probability | Historical amendment rate for similar protocols in therapeutic area | Internal precedent database |
| Visit Burden vs. Capacity | Total visit-hours required vs. site's documented throughput capacity | Protocol SoA + site capacity data |
| Data Entry Burden | eCRF page count, query rate expectation, source data verification scope | Protocol + data management plan |
| Eligibility Criterion Complexity | Number of criteria, logical structure complexity, lab value precision requirements | Protocol eligibility section |
| Concurrent Enrollment Risk | Number of other protocols enrolling similar patient populations at same site | Site protocol portfolio |

**Classification Framework:**

| Risk Level | Criteria |
|------------|----------|
| HIGH | Complexity score > threshold; amendment probability > 40%; visit burden > 125% of capacity; > 5 eligibility criteria with lab value precision requirements |
| MEDIUM | Complexity score at threshold; amendment probability 20–40%; visit burden 100–125% of capacity; 3–5 complex eligibility criteria |
| LOW | Below-threshold complexity; amendment probability < 20%; visit burden < 100% of capacity; straightforward eligibility structure |

**Mitigation Requirements by Risk Level:**

- **HIGH:** Protocol feasibility review with medical monitor required; eligibility criteria clarification memo required before activation; site capacity confirmed by sponsor medical team
- **MEDIUM:** Eligibility criteria FAQ developed for site staff; capacity confirmation documented
- **LOW:** Standard activation process

---

### Dimension 3: Population Risk

**Definition:** The risk that the target patient population's characteristics will create enrollment challenges, safety signals, or eligibility determination errors that compromise trial integrity.

**Assessment Components:**

| Component | Description | Data Source |
|-----------|-------------|-------------|
| Catchment Alignment | Site's accessible patient population vs. protocol target population | Site patient registry + protocol inclusion criteria |
| Screen-Fail Patterns | Historical screen-fail rate for similar populations at site | Prior trial data |
| Dropout Trajectory | Historical dropout/withdrawal rate for similar protocols | Prior trial data |
| Comorbidity Prevalence | Prevalence of protocol exclusion criteria comorbidities in catchment population | Epidemiological data |
| Competing Trial Enrollment | Active competing trials enrolling from same catchment | ClinicalTrials.gov + site trial portfolio |
| Vulnerable Population Indicators | Age, cognitive capacity, language, socioeconomic factors affecting informed consent | Protocol + site demographics |

**Classification Framework:**

| Risk Level | Criteria |
|------------|----------|
| HIGH | Catchment alignment < 60% of required population; screen-fail rate > 50% in prior similar trials; competing trial enrollment > 30% overlap; vulnerable population indicators requiring enhanced consent process |
| MEDIUM | Catchment alignment 60–80%; screen-fail rate 25–50%; competing trial overlap 15–30%; some vulnerable population considerations |
| LOW | Catchment alignment > 80%; screen-fail rate < 25%; limited competing trial overlap; standard consent process sufficient |

**Mitigation Requirements by Risk Level:**

- **HIGH:** Pre-enrollment patient identification exercise required; competing trial coordination agreement required; enhanced consent protocol documented; enrollment projection revised downward
- **MEDIUM:** Patient identification feasibility documented; competing trial awareness confirmed; consent process reviewed
- **LOW:** Standard enrollment projection; standard consent process

---

## 5. Combined Risk Classification

### Composite Risk Matrix

The RBQM layer produces a **composite risk classification** from the three dimensions. This classification determines the overall pre-verification risk posture for the activation.

| Site Risk | Protocol Risk | Population Risk | Composite |
|-----------|---------------|-----------------|-----------|
| HIGH | any | any | HIGH |
| any | HIGH | any | HIGH |
| any | any | HIGH | HIGH |
| MEDIUM | MEDIUM | MEDIUM | MEDIUM |
| MEDIUM | MEDIUM | LOW | MEDIUM |
| MEDIUM | LOW | LOW | MEDIUM |
| LOW | LOW | LOW | LOW |

**Any HIGH dimension produces a composite HIGH classification.**

### Composite Risk Actions

| Composite | Gate 1 Entry Condition |
|-----------|----------------------|
| HIGH | Mitigation documentation for all HIGH dimensions required and verified before Gate 1 entry |
| MEDIUM | Mitigation documentation for all MEDIUM dimensions required and logged before Gate 1 entry |
| LOW | Standard Gate 1 entry; no additional pre-conditions |

---

## 6. The Cold-Start Problem

### Problem Statement

The RBQM pre-verification layer requires historical data to classify risk accurately. New sites, rare disease protocols, and first-in-class therapeutic areas may have insufficient historical data for reliable risk classification.

This is an **open problem in v1.0**. The following interim approaches are documented:

### Interim Approaches

**New Site (no prior trial history):**
- Default to MEDIUM for Site Risk dimension
- Require pre-activation site qualification visit regardless of composite classification
- Document the cold-start condition in the RBQM record
- Increase monitoring frequency in the execution phase

**Novel Protocol (no prior similar protocols in therapeutic area):**
- Default to MEDIUM for Protocol Risk dimension
- Require protocol feasibility review with medical monitor
- Engage sponsor's medical team for complexity assessment
- Document therapeutic area novelty in RBQM record

**Rare Disease Population (population size < threshold for reliable screen-fail estimation):**
- Default to MEDIUM for Population Risk dimension
- Require patient identification exercise before enrollment opens
- Consult patient advocacy organizations for catchment alignment assessment
- Document population size constraint in RBQM record

### Minimum Data Thresholds

*The following thresholds are proposed for community review. They are not validated in v1.0.*

| Dimension | Recommended Minimum Data for Classification |
|-----------|---------------------------------------------|
| Site Risk | ≥ 1 prior completed trial at site (any therapeutic area) |
| Protocol Risk | ≥ 3 prior trials in same therapeutic area (any sponsor) |
| Population Risk | ≥ 10 screened patients matching target population profile at site |

If data falls below these thresholds, the cold-start default applies.

---

## 7. Dynamic Risk Reassessment

### The Article 9(e) Requirement

EU AI Act Article 9(e) requires that the risk management system address risks that may emerge when the AI system is used as intended — including during deployment. Static pre-activation risk classification does not satisfy this requirement.

This is an **open problem in v1.0** for the execution phase. The following is the design intent for framework v2:

### Reassessment Triggers (Proposed for v2)

| Trigger | Reassessment Scope |
|---------|-------------------|
| Site deviation classified as CRITICAL | Full three-dimension reassessment |
| Protocol amendment issued | Protocol Risk dimension reassessment |
| Screen-fail rate exceeds baseline by > 25% | Population Risk dimension reassessment |
| PI or study coordinator personnel change | Site Risk dimension reassessment |
| Inspection finding at site | Site Risk dimension reassessment |
| Enrollment pause > 30 days | Full three-dimension reassessment |

### v1.0 Limitation

v1.0 of this specification addresses risk classification at activation only. Continuous risk reassessment during execution is a design intent for v2, dependent on the Trial Execution Intelligence scope described in the three-gate architecture specification.

---

## 8. RBQM Record Schema

Every RBQM assessment must produce a structured record with the following fields:

```json
{
  "rbqm_record_id": "UUID v4",
  "assessment_timestamp": "ISO 8601 UTC",
  "protocol_identifier": "string",
  "site_identifier": "string",
  "jurisdiction": "ISO country code",
  "dimensions": {
    "site_risk": {
      "classification": "HIGH | MEDIUM | LOW",
      "components_assessed": ["array of component names"],
      "data_sufficient": true,
      "cold_start_applied": false,
      "mitigation_required": true,
      "mitigation_documented": false
    },
    "protocol_risk": {
      "classification": "HIGH | MEDIUM | LOW",
      "components_assessed": ["array of component names"],
      "data_sufficient": true,
      "cold_start_applied": false,
      "mitigation_required": false,
      "mitigation_documented": null
    },
    "population_risk": {
      "classification": "MEDIUM",
      "components_assessed": ["array of component names"],
      "data_sufficient": false,
      "cold_start_applied": true,
      "cold_start_reason": "New site — insufficient prior enrollment data",
      "mitigation_required": true,
      "mitigation_documented": false
    }
  },
  "composite_classification": "HIGH | MEDIUM | LOW",
  "gate_1_entry_authorized": false,
  "gate_1_entry_condition": "Mitigation documentation required for HIGH dimensions",
  "assessed_by": "system | qualified_reviewer",
  "reviewer_identity": "null | name + credential",
  "review_timestamp": "null | ISO 8601 UTC"
}
```

---

## 9. Open Questions

1. **Cold-Start Thresholds:** Are the minimum data thresholds in Section 6 defensible? What does the industry use in practice? (Active in co-development working session)

2. **Dynamic Reassessment Triggers:** Are the proposed Article 9(e) reassessment triggers in Section 7 sufficient? Are there triggers not listed that should be included?

3. **Composite Matrix Logic:** Should the composite matrix use additive scoring rather than the "any HIGH = composite HIGH" rule? What are the failure modes of each approach?

4. **Mitigation Verification:** Who verifies that mitigation documentation is adequate before Gate 1 entry? Should this be the AI system, a human reviewer, or both?

5. **Cross-Jurisdiction Differences:** Do the risk classification thresholds apply uniformly across US/EU/Brazil/India, or should jurisdiction-specific calibration be allowed?

---

## 10. Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | May 2026 | Initial specification — added in response to Article 9 gap identified in adversarial review |

---

## 11. Contributing

This specification is developed through the open co-development process described in [CONTRIBUTING.md](../CONTRIBUTING.md). The cold-start thresholds and dynamic reassessment triggers are explicit targets for community input before v2.

---

*This specification is published under Apache 2.0. It defines a framework for risk classification — not an implementation. For the boundary between this open standard and the NexTrial.ai production implementation, see [BOUNDARY.md](../BOUNDARY.md).*
