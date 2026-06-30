# BOUNDARY.md — Open Standard vs. Protected Implementation

**Status:** Published  
**Document:** BOUNDARY-001  
**Version:** 3.0  

---

## Purpose

This document defines the explicit boundary between:
- What is published as open standard in this repository (Apache 2.0)
- What is proprietary to NexTrial.ai and protected as trade secret or patent

---

## What Is Open (This Repository)

The following are published as open standard:

- Proof Certificate Specification (eight-property schema)
- Three-Gate Verification Architecture Specification
- RBQM Pre-Verification Layer Specification
- Site AI Utilization Disclosure Specification
- Regulatory Adapter Interface Contract
- Regulatory Mapping Tables (FDA, ANVISA, CDSCO, EU AI Act)
- Lean4 Proof Property Definitions (what gets proven, not how)
- Validation Test Harness and Reference Test Cases

---

## What Is Protected (NexTrial.ai Proprietary)

The following are NOT included in this repository and are protected:

- CFM-1: Functional regulatory compliance adapter implementations
- The predictive eligibility layer (implementation internals)
- The lineage-memory subsystem (architecture and implementation)
- Internal protocol-structuring representations (implementation)
- Production deployment infrastructure
- Proprietary model artifacts (trained weights, adapters, and fine-tuning data)
- Proprietary regulatory rule sets embedded in functional adapters

---

## Patent Notice

Provisional patent application on file (#63/889,659).
This open standard is published under Apache 2.0, which includes a patent grant
for contributions. The patent grant does not extend to the protected
implementations listed above.

---

*The open standard is published under Apache 2.0. The protected implementations listed above remain proprietary to NexTrial.ai.*
