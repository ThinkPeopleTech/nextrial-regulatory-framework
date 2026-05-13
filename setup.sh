#!/bin/bash
# =============================================================================
# nextrial-regulatory-framework — Bootstrap Script
# Run from repo root: bash setup.sh
# Creates all directories, drops completed files, stubs placeholders
# =============================================================================

set -e

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  nextrial-regulatory-framework — scaffold starting"
echo "═══════════════════════════════════════════════════════"
echo ""

# -----------------------------------------------------------------------------
# 1. CREATE DIRECTORY STRUCTURE
# -----------------------------------------------------------------------------

mkdir -p specs
mkdir -p regulatory-mappings
mkdir -p lean4
mkdir -p validation/fixtures
mkdir -p validation/reference-adapter
mkdir -p co-development
mkdir -p assets
mkdir -p papers

echo "✓ Directories created"

# -----------------------------------------------------------------------------
# 2. ROOT FILES (stubs — paste final content in)
# -----------------------------------------------------------------------------

# LICENSE — Apache 2.0
cat > LICENSE << 'EOF'
                                 Apache License
                           Version 2.0, January 2004
                        http://www.apache.org/licenses/

TERMS AND CONDITIONS FOR USE, REPRODUCTION, AND DISTRIBUTION
[Full Apache 2.0 text — paste from https://www.apache.org/licenses/LICENSE-2.0.txt]

Copyright 2026 NexTrial.ai (Steven Thompson)

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
EOF

echo "✓ LICENSE created (stub — replace with full Apache 2.0 text)"

# BOUNDARY.md — stub (Alex Lee review required before content)
cat > BOUNDARY.md << 'EOF'
# BOUNDARY.md — Open Standard vs. Protected Implementation

**Status:** DRAFT — Pending Alex Lee review before publication  
**Document:** BOUNDARY-001  
**Version:** 1.0 DRAFT  

---

## Purpose

This document defines the explicit boundary between:
- What is published as open standard in this repository (Apache 2.0)
- What is proprietary to NexTrial.ai and protected as trade secret or patent

---

## What Is Open (This Repository)

The following are published as open standard:

- Proof Certificate Specification (four-property schema)
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
- PPEE: Physics-informed patient eligibility prediction engine
- RLM: Recursive Lineage Memory architecture and implementation
- SPEO: Structured Protocol Execution Object implementation
- Production deployment infrastructure
- Trained model weights and LoRA adapters
- Proprietary regulatory rule sets embedded in functional adapters

---

## Patent Notice

Provisional patent application on file (#63/889,659).
This open standard is published under Apache 2.0, which includes a patent grant
for contributions. The patent grant does not extend to the protected
implementations listed above.

---

*DRAFT — Alex Lee (IP & Regulatory Strategy Advisor) to review before publication.*  
*Do not publish this file until review is complete.*
EOF

echo "✓ BOUNDARY.md created (DRAFT — Alex Lee review required)"

# -----------------------------------------------------------------------------
# 3. SPECS — completed files (copy content from Claude outputs)
# -----------------------------------------------------------------------------

# Stub headers for all 5 specs
# Replace each with the full content from the Claude-generated files

cat > specs/proof-certificate-spec-v1.md << 'EOF'
# Proof Certificate Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** PC-SPEC-001  
**Version:** 1.0  
**Status:** Published  

> PLACEHOLDER — paste full content from Priority 1 output
EOF

cat > specs/three-gate-architecture-v1.md << 'EOF'
# Three-Gate Verification Architecture Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** TGA-SPEC-001  
**Version:** 1.0  
**Status:** Published  

> PLACEHOLDER — paste full content from Priority 1 output
EOF

# The three Priority 2 specs are COMPLETE — paste their full content here
# or copy the files directly into /specs/

cat > specs/rbqm-pre-verification-spec-v1.md << 'EOF'
# Risk-Based Quality Management Pre-Verification Layer Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** RBQM-SPEC-001  
**Version:** 1.0  
**Status:** Published  

> COMPLETE — paste full content from rbqm-pre-verification-spec-v1.md
EOF

cat > specs/site-ai-utilization-disclosure-v1.md << 'EOF'
# Site AI Utilization Disclosure Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** SAID-SPEC-001  
**Version:** 1.0  
**Status:** Published  

> COMPLETE — paste full content from site-ai-utilization-disclosure-v1.md
EOF

cat > specs/adapter-interface-spec-v1.md << 'EOF'
# Regulatory Adapter Interface Specification v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** ADAPTER-SPEC-001  
**Version:** 1.0  
**Status:** Published  

> COMPLETE — paste full content from adapter-interface-spec-v1.md
EOF

echo "✓ /specs — 5 files created (3 complete, 2 need Priority 1 content)"

# -----------------------------------------------------------------------------
# 4. REGULATORY MAPPINGS — stub JSON files
# -----------------------------------------------------------------------------

cat > regulatory-mappings/us-fda.json << 'EOF'
{
  "jurisdiction": "US",
  "regulatory_body": "FDA",
  "version": "1.0",
  "last_verified": "2026-05-01",
  "regulations": [],
  "_note": "PLACEHOLDER — paste full content from Priority 1 output"
}
EOF

cat > regulatory-mappings/brazil-anvisa.json << 'EOF'
{
  "jurisdiction": "BR",
  "regulatory_body": "ANVISA",
  "version": "1.0",
  "last_verified": "2026-05-01",
  "regulations": [],
  "_note": "PLACEHOLDER — paste full content from Priority 1 output"
}
EOF

cat > regulatory-mappings/india-cdsco.json << 'EOF'
{
  "jurisdiction": "IN",
  "regulatory_body": "CDSCO",
  "version": "1.0",
  "last_verified": "2026-05-01",
  "regulations": [],
  "_note": "PLACEHOLDER — paste full content from Priority 1 output"
}
EOF

cat > regulatory-mappings/eu-ai-act.json << 'EOF'
{
  "jurisdiction": "EU",
  "regulatory_body": "European Commission",
  "regulation": "EU AI Act 2024/1689",
  "version": "1.0",
  "last_verified": "2026-05-01",
  "articles": [],
  "_note": "PLACEHOLDER — paste full content from Priority 1 output"
}
EOF

cat > regulatory-mappings/adapter-registry.json << 'EOF'
{
  "registry_version": "1.0",
  "last_updated": "2026-05-01",
  "adapters": [],
  "_note": "Registry populated as conforming adapters are registered"
}
EOF

echo "✓ /regulatory-mappings — 5 JSON files created (stubs)"

# -----------------------------------------------------------------------------
# 5. LEAN4 — stub files
# -----------------------------------------------------------------------------

cat > lean4/proof-properties-v1.md << 'EOF'
# Lean4 Proof Property Definitions v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** LEAN4-PROPS-001  
**Version:** 1.0  
**Status:** Published  

> PLACEHOLDER — paste full content from Priority 1 output
EOF

cat > lean4/type-definitions-v1.lean << 'EOF'
-- Lean4 Type Definitions v1.0
-- nextrial-regulatory-framework
-- PLACEHOLDER — paste full content from Priority 1 output

namespace NexTrialFramework

-- Proof Certificate Types
-- [content to be added]

end NexTrialFramework
EOF

echo "✓ /lean4 — 2 files created (stubs)"

# -----------------------------------------------------------------------------
# 6. VALIDATION — test harness COMPLETE, fixtures stubs
# -----------------------------------------------------------------------------

cat > validation/test-harness-v1.md << 'EOF'
# Validation Test Harness — Reference Test Cases v1.0

**Repository:** nextrial-regulatory-framework  
**Document:** TEST-HARNESS-001  
**Version:** 1.0  
**Status:** Published  

> COMPLETE — paste full content from test-harness-v1.md
EOF

# Fixture stubs
for fixture in \
  "valid-certificate-pass" \
  "valid-certificate-warning" \
  "valid-certificate-fail" \
  "invalid-certificate-missing-id" \
  "invalid-certificate-pass-with-critical" \
  "invalid-certificate-summary-mismatch" \
  "valid-adapter-input-complete" \
  "valid-adapter-input-minimal" \
  "invalid-adapter-input-unknown-doctype" \
  "rbqm-all-high" \
  "rbqm-all-low" \
  "rbqm-mixed-high-medium" \
  "rbqm-cold-start-site" \
  "attestation-level-assignments"
do
  cat > "validation/fixtures/${fixture}.json" << FIXEOF
{
  "_fixture": "${fixture}",
  "_status": "PLACEHOLDER",
  "_note": "See test-harness-v1.md for expected structure"
}
FIXEOF
done

cat > validation/reference-adapter/README.md << 'EOF'
# Reference Adapter

Schema validator for the adapter interface specification.
Validates input/output objects — does NOT make regulatory compliance determinations.

## Status
PLACEHOLDER — implementation forthcoming

## Usage
```bash
python validate.py --input <input.json> --output <output.json>
```
EOF

echo "✓ /validation — test harness + 14 fixture stubs + reference adapter readme"

# -----------------------------------------------------------------------------
# 7. CO-DEVELOPMENT — COMPLETE files
# -----------------------------------------------------------------------------

cat > co-development/open-questions.md << 'EOF'
# Open Questions — Active Co-Development

> COMPLETE — paste full content from open-questions.md
EOF

cat > co-development/dominique-critique-response.md << 'EOF'
# Dominique Chesnais Adversarial Review — Response

**Status:** Complete  
**Points reviewed:** 8  
**Outcome:** 3 gaps acknowledged | 3 addressed | 2 mapped | 1 additional identified  

> PLACEHOLDER — document the full 3+3+3 point-by-point response
EOF

cat > co-development/working-session-findings.md << 'EOF'
# Working Session Findings

**Session 1:** May 14, 2026  
**Participants:** 15 practitioners  
**Duration:** 60 minutes  

> PLACEHOLDER — populate after May 14 session with Mentimeter data and findings
EOF

cat > co-development/contributors.md << 'EOF'
# Contributors

With gratitude to everyone who has challenged, improved, and co-developed this framework.

## Working Session Participants
*Listed with permission — to be populated after May 14, 2026 session*

## External Reviewers
- Dominique Chesnais — adversarial review, EU AI Act and GxP principles (8 points)
- Brian Burke — ALIGN-AI Framework, EU AI Act conformity assessment review

## Co-Development Collaborators
- Gourav Pandey, Takeda R&D Quality — GxP validation integration

## Author
Steven Thompson, NexTrial.ai
EOF

echo "✓ /co-development — 4 files created (open-questions complete, others partial)"

# -----------------------------------------------------------------------------
# 8. ASSETS — placeholder SVGs
# -----------------------------------------------------------------------------

for asset in \
  "four-layer-stack-diagram" \
  "three-gate-architecture-diagram" \
  "proof-certificate-schema-diagram"
do
  cat > "assets/${asset}.svg" << SVGEOF
<!-- ${asset}.svg — PLACEHOLDER -->
<!-- Diagram to be added post-DIA 2026 -->
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 400">
  <rect width="800" height="400" fill="#0A1628"/>
  <text x="400" y="200" fill="#00D4FF" font-family="monospace" font-size="16" text-anchor="middle">${asset}</text>
  <text x="400" y="230" fill="#666" font-family="monospace" font-size="12" text-anchor="middle">Diagram forthcoming</text>
</svg>
SVGEOF
done

echo "✓ /assets — 3 SVG placeholders created"

# -----------------------------------------------------------------------------
# 9. PAPERS — empty, ready for DIA poster
# -----------------------------------------------------------------------------

cat > papers/README.md << 'EOF'
# Papers

## Forthcoming

- **DIA 2026 Poster** — Abstract ID 116114. Poster Session II, June 16, 2026.
  Will be added after the conference.

- **CAISc 2026 Submission** — July 24-25, 2026. Pending.

## Published

- Substack: "Toward a Regulatory Validation Framework for AI-Assisted Clinical Trial Activation and Execution"
  https://open.substack.com/pub/steventhompsonai/p/toward-a-regulatory-validation-framework

- Substack: "Confidence Is Not a Compliance Artifact"
  https://open.substack.com/pub/steventhompsonai/p/confidence-is-not-a-compliance-artifact
EOF

echo "✓ /papers — README created"

# -----------------------------------------------------------------------------
# 10. CONTRIBUTING.md — COMPLETE
# -----------------------------------------------------------------------------

cat > CONTRIBUTING.md << 'EOF'
# Contributing to the Regulatory Validation Framework

> COMPLETE — paste full content from CONTRIBUTING.md
EOF

echo "✓ CONTRIBUTING.md created (complete content ready to paste)"

# -----------------------------------------------------------------------------
# SUMMARY
# -----------------------------------------------------------------------------

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  SCAFFOLD COMPLETE"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Directory structure:"
find . -not -path './.git/*' -not -name '.git' | sort | sed 's|[^/]*/|  |g'
echo ""
echo "═══════════════════════════════════════════════════════"
echo "  NEXT STEPS"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "Files ready to paste full content into:"
echo ""
echo "  COMPLETE (paste from Claude outputs):"
echo "  → specs/rbqm-pre-verification-spec-v1.md"
echo "  → specs/site-ai-utilization-disclosure-v1.md"
echo "  → specs/adapter-interface-spec-v1.md"
echo "  → CONTRIBUTING.md"
echo "  → co-development/open-questions.md"
echo "  → validation/test-harness-v1.md"
echo ""
echo "  NEED PRIORITY 1 CONTENT (from Task 1):"
echo "  → specs/proof-certificate-spec-v1.md"
echo "  → specs/three-gate-architecture-v1.md"
echo "  → regulatory-mappings/us-fda.json"
echo "  → regulatory-mappings/brazil-anvisa.json"
echo "  → regulatory-mappings/india-cdsco.json"
echo "  → regulatory-mappings/eu-ai-act.json"
echo "  → lean4/proof-properties-v1.md"
echo "  → lean4/type-definitions-v1.lean"
echo ""
echo "  PENDING REVIEW / FUTURE:"
echo "  → BOUNDARY.md (Alex Lee review required)"
echo "  → LICENSE (replace stub with full Apache 2.0 text)"
echo "  → co-development/dominique-critique-response.md"
echo "  → co-development/working-session-findings.md (post May 14)"
echo "  → validation/fixtures/*.json (14 test fixtures)"
echo "  → assets/*.svg (post-DIA diagrams)"
echo "  → papers/ (post-DIA poster)"
echo ""
echo "  THEN COMMIT:"
echo "  git add -A"
echo "  git commit -m 'feat: scaffold full repo structure v1.0'"
echo "  git push origin main"
echo ""
echo "═══════════════════════════════════════════════════════"
