# Contributing to the Regulatory Validation Framework

**Repository:** nextrial-regulatory-framework  
**Version:** 1.0  
**AI-Assisted — Human Review Required**

---

## Why This Exists

Clinical trial AI is moving faster than the regulatory guidance that governs it. The result is a fragmented, inconsistent, and often undocumented set of practices that vary by sponsor, CRO, site, and jurisdiction.

This framework is an attempt to change that — to build a shared, open, auditable standard for how AI systems in clinical trials get verified. Not a vendor standard. Not a trade association white paper. An actual specification with schemas, test cases, and formal properties that practitioners can implement, challenge, and improve.

The standard is open. The implementations that satisfy it are not.

This repository welcomes contributions from:
- Clinical trial operations professionals
- Regulatory affairs specialists
- AI/ML engineers building clinical trial systems
- GCP auditors and quality professionals
- Biostatisticians and data managers
- Patient advocates with operational trial experience
- Regulators and agency staff (individual capacity)

---

## What We're Building Together

The framework has six open questions that are explicitly unresolved in v1.0. Community input is actively sought on:

1. The cold-start problem in RBQM risk classification — what is the minimum site data for meaningful risk assessment?
2. Dynamic risk reassessment during execution — what triggers a re-classification under Article 9(e)?
3. Rubber-stamp prevention — how do we distinguish substantive attestation from perfunctory review in the audit trail?
4. Composite risk matrix logic — should composite classification use additive scoring or the current any-HIGH-equals-HIGH rule?
5. Adapter certification — should third-party adapters have a certification process? What does it require?
6. Multi-jurisdiction documents — should the adapter interface support multi-jurisdiction invocation?

Beyond the open questions, we welcome:
- Additional regulatory mapping tables (jurisdictions not yet covered: Canada, Japan, Australia, South Korea)
- Validation test cases that challenge the specification's edge cases
- Adversarial scenarios that identify gaps in the three-gate architecture
- Case studies from real trials (de-identified) that test the framework against operational reality

---

## How to Contribute

### Before You Start

1. Read the full specification set — at minimum, the README, BOUNDARY.md, the proof certificate spec, and the three-gate architecture spec.
2. Read the open questions in `/co-development/open-questions.md`.
3. Read the Dominique Chesnais adversarial review in `/co-development/dominique-critique-response.md` — it models the kind of substantive engagement we're looking for.

### Contribution Types

**Type 1 — Issue (Question, Challenge, Gap)**

Use GitHub Issues to:
- Ask a question about the specification
- Identify a gap in the framework
- Challenge a claim in the specification with evidence or reasoning
- Report an inconsistency between specifications

Label your issue:
- `question` — you need clarification
- `gap` — you've identified something missing
- `challenge` — you disagree with something and have an argument
- `inconsistency` — two specs conflict

**Type 2 — Discussion (Open Question Input)**

Use GitHub Discussions for:
- Input on the six open questions
- Case study sharing
- Regulatory interpretation debate
- Working session follow-up

**Type 3 — Pull Request (Specification Change)**

Use Pull Requests to:
- Propose changes to existing specifications
- Add new regulatory mapping tables
- Add validation test cases
- Fix errors in schemas or JSON

Pull Request requirements:
- One change per PR (don't bundle unrelated changes)
- Describe the problem your change solves
- Cite the regulatory basis for any compliance claim
- Include test cases for schema changes
- Acknowledge the Contributor License Agreement (see below)

---

## Review Process

### For Issues and Discussions

All issues and discussions are reviewed by the NexTrial.ai team within 10 business days. For complex regulatory questions, we may convene the co-development working group before responding.

### For Pull Requests

**Step 1 — Automated validation**  
Schema changes are validated against the reference test harness. PRs that break existing test cases will not be merged without resolution.

**Step 2 — Technical review**  
PRs are reviewed by at least one NexTrial.ai team member for technical accuracy.

**Step 3 — Regulatory review**  
PRs that affect compliance claims are reviewed against the cited regulatory basis. We may request additional citations or documentation.

**Step 4 — Working session**  
Significant changes (major spec revisions, new architecture layers) are taken to the co-development working session for community input before acceptance.

**Step 5 — Merge or decline**  
Accepted PRs are merged with attribution in the change log. Declined PRs receive written explanation.

---

## Co-Development Working Sessions

Working sessions are held quarterly and open to any registered participant.

**Format:**
- 60 minutes via video
- Structured agenda published 5 days in advance
- Mentimeter polling for quantitative input
- Findings published to `/co-development/working-session-findings.md` within 10 days

**Next session:** See the [Discussions tab](https://github.com/nextrial-ai/nextrial-regulatory-framework/discussions) for the current schedule.

**To register:** Create a GitHub Discussion with the label `working-session` and include your name, organization (optional), and the open question you're most interested in.

---

## What This Repository Is Not

This repository is not:
- A venue for vendor product announcements
- A place to publish unverified claims about regulatory compliance
- A lobbying effort for any particular regulatory approach
- A substitute for qualified legal or regulatory counsel

Contributions that are primarily promotional, that cite proprietary data without appropriate caveats, or that misrepresent regulatory requirements will be declined.

---

## Contributor License Agreement

By submitting a pull request to this repository, you agree to the following:

1. You have the right to submit the contribution — it is your original work or you have the necessary rights to contribute it.
2. You grant NexTrial.ai and all users of this repository a perpetual, worldwide, non-exclusive, royalty-free license to use, reproduce, modify, and distribute your contribution under the Apache 2.0 license.
3. You understand that your contribution may be incorporated into the specification and that the specification may be implemented in proprietary products by any party.
4. You are not submitting anything that is confidential, trade secret, or otherwise subject to a non-disclosure obligation that prohibits this contribution.

If you are contributing on behalf of an organization, you represent that you have authority to grant the above license on behalf of that organization.

---

## Attribution

Contributors whose changes are merged into the specification are listed in the change log for the affected document and in `/co-development/contributors.md`. Organizational affiliation is included only with the contributor's explicit permission.

The working session co-development process is acknowledged in the framework documentation. Individual participant names from working sessions are listed in `/co-development/contributors.md` only with explicit consent.

---

## Questions

Questions about the contribution process: open a GitHub Issue with the label `process-question`.

Questions about the framework content: open a GitHub Issue with the label `question`.

Questions about the NexTrial.ai production implementation: this repository covers the open standard only. For implementation questions, contact framework@nextrial.ai.

---

*This CONTRIBUTING.md is published under Apache 2.0.*  
*NexTrial.ai — "The standard is open. The implementation is NexTrial's."*
