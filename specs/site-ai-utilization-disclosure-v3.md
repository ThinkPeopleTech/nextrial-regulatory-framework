# Site AI Utilization Disclosure Specification v3.0

**Repository:** nextrial-regulatory-framework
**Document:** SAID-SPEC-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §3.3 and §4.3
**AI-Assisted — Human Review Required**

> Supersedes [site-ai-utilization-disclosure-v1.md](site-ai-utilization-disclosure-v1.md).
> The v1.0 three-level attestation model is retained for historical reference.
> This v3.0 specification aligns attestation to the framework paper: **two
> attestation levels.** There is no Level 3.

---

## 1. Purpose

This specification defines what clinical trial sites must disclose when AI systems
are used in trial activation or execution decisions, and how the responsible human
attests. It establishes the **two** attestation levels, the override and escalation
protocol that completes Property 7 of the proof certificate, and the liability
allocation framework that satisfies ICH E6(R3), EU AI Act Article 14, and CFM
Resolução 2.454/2026.

It defines a disclosure and attestation interface. It does not specify how any AI
system produces its outputs.

---

## 2. Scope

This specification applies when an AI system contributes to eligibility
determinations, generates or validates regulatory submission documents, assesses
site readiness, produces activation timelines with predictive components, or
monitors execution variance against protocol plans. It does not apply to AI used
solely for administrative scheduling, non-clinical logistics, or data-entry
assistance with no decision-relevant output.

---

## 3. The Two Attestation Levels

Attestation level is **set by the frozen risk class** the RBQM pre-gate assigned
into Property 5 of the certificate (PC-SPEC-001 v3 §3.5), not selected by the
reviewer after the fact. The certificate records, in Property 6, the level actually
performed.

### Level 1 — Qualified reviewer

**Definition:** a qualified reviewer evaluates the AI-assisted determination, the
certificate, and the boundary statement, and accepts, rejects, or asks for
revision.

**Permitted for:** MODERATE and LOW risk classes (Level 1 permitted at MODERATE;
sufficient at LOW). Not sufficient for CRITICAL or HIGH.

**Canonical statement:**
> "I am a qualified reviewer. I have evaluated the AI-assisted determination
> identified by [Certificate ID], its proof certificate, and its boundary
> statement. I record my verdict (ACCEPT / REJECT / ASK) and any challenge and its
> resolution in Property 7. The determination is evidence I have weighed, not a
> substitute for my judgment."

### Level 2 — Responsible principal investigator (or delegated equivalent)

**Definition:** the responsible principal investigator, or a delegated equivalent
of equivalent standing, attests. Level 2 is the responsible-PI-primary allocation
of accountability.

**Required for:** CRITICAL and HIGH risk classes. CFM Resolução 2.454/2026 medical
determinations require Level 2 regardless of configuration.

**Canonical statement:**
> "I am the responsible principal investigator (or delegated equivalent of
> equivalent standing) for this decision. I have evaluated the AI-assisted
> determination identified by [Certificate ID] against the source values and rules
> in its proof certificate and boundary statement. I record my verdict, any
> challenge and its resolution, any override and its rationale, and any escalation
> in Property 7. I accept primary accountability for this determination."

> **There is no Level 3.** The v1.0 specification's third level is superseded; its
> clinical-judgment function is carried by Level 2 (responsible PI primary) and by
> the boundary statement's reserved scope.

---

## 4. Attestation-Level Assignment

| Frozen risk class (Property 5) | Minimum attestation level |
|---|---|
| CRITICAL | Level 2 |
| HIGH | Level 2 |
| MODERATE | Level 1 permitted |
| LOW | Level 1 sufficient |

The level is assigned **before** verification (it is indexed to the risk class the
pre-gate froze) and cannot be lowered by the reviewer. A reviewer may always attest
at a higher level than the minimum; the level performed is recorded in Property 6.

### Jurisdiction-specific minimums

| Jurisdiction | Rule |
|---|---|
| Brazil (CFM 2.454/2026) | Medical determinations require Level 2 (responsible PI primary) |
| EU (AI Act Art. 14) | High-risk AI outputs require effective human oversight — Level 2 for CRITICAL/HIGH |
| India (CDSCO NDCTR 2019) | Investigator attestation required for regulatory submissions — Level 2 |
| US (21 CFR 312) | GCP governs; sponsor discretion within the risk-class floor |

---

## 5. Override and Escalation Protocol (completes Property 7)

The reviewer's verdict is one of exactly three outcomes — **ACCEPT**, **REJECT**,
or **ASK** (for revision) — and the gate is interactive, not a single yes/no.
Property 7 of the proof certificate records the full human decision path.

### 5.1 Verdict
- **ACCEPT** — the reviewer accepts the determination.
- **REJECT** — the reviewer rejects the determination.
- **ASK** — the reviewer asks for revision: challenges a rule application, questions
  a value, or sends the decision back.

### 5.2 Challenge, mitigate-and-rerun
A REJECT or ASK can drive a remediation loop: the issue is **mitigated**, the
verification is **re-run**, and the determination converges or escalates. The
challenge and how it was resolved are recorded in Property 7, so the record carries
not only what was decided but why.

### 5.3 Override
Any override is recorded with a substantive **rationale** (the clinical, factual,
regulatory, or interpretive basis). An override is the intended function of human
oversight, not a failure.

### 5.4 Escalation
When the boundary statement's escalation criteria (Property 4) are met, the
decision is escalated. Property 7 records **whether escalation occurred and the
escalation destination** (to where). For CRITICAL/HIGH decisions, escalation is
forced before continued execution where the criteria are met.

### 5.5 Documentation
Every Property 7 record is immutable, bi-temporal (valid-time + transaction-time),
signed, and linked to the certificate by Certificate ID, retained for the
jurisdiction's TMF retention period.

---

## 6. Liability Allocation Framework

Liability is allocable by attestation level, with the responsible principal
investigator primary (Property 6 admissibility test).

- **System verification failure.** The verification architecture failed to detect
  an incorrect output that was within the system's documented scope. Responsibility:
  the AI system vendor, per the services agreement and documented specification.
- **Attestation scope failure.** The error was detectable through the assigned
  attestation level, but the reviewer attested without substantive review (a
  rubber-stamp). Responsibility: the attesting reviewer and, depending on
  supervision, the sponsor.
- **Reserved-scope judgment failure.** The reviewer exercised judgment within the
  boundary statement's reserved scope, departed from the (accurately produced)
  determination, and the departure caused harm. Responsibility: the attesting
  investigator, under standard medical-liability principles.

*This framework is a conceptual structure for liability analysis, not legal advice.
Applicable law, jurisdiction, and contract terms govern. Review with qualified legal
counsel before incorporation into any agreement or protocol.*

---

## 7. Audit Trail Requirements

For every AI-assisted determination subject to this specification, the following are
logged, immutably and bi-temporally, and reconstructable from the certificate and
its Property 7 record:

| Field | Description | Format |
|---|---|---|
| `certificate_id` | Identifier of the AI-assisted determination | UUID v4 |
| `risk_class` | Frozen class from Property 5 | CRITICAL / HIGH / MODERATE / LOW |
| `taxonomy_ref` | Risk taxonomy identifier and version | `nxt-rbqm-risk-taxonomy@1.0` |
| `attestation_level` | Level assigned and level performed | 1 / 2 |
| `reviewer_identity` | Attesting human | Name + role + credential |
| `verdict` | Property 7 outcome | ACCEPT / REJECT / ASK |
| `override_rationale` | Basis if overridden | Text or null |
| `escalation_destination` | Where escalated, if escalated | Text or null |
| `attestation_timestamp` | When attestation occurred | ISO 8601 UTC |
| `jurisdiction` | Applicable jurisdiction | ISO 3166-1 alpha-2 |

---

## 8. Open Questions

Carried from the paper (§9) and prior co-development:
1. **Rubber-stamp risk** — distinguishing substantive Level 1/Level 2 review from a
   rubber-stamp in the audit trail.
2. **Delegation** — the conditions under which Level 2 may be discharged by a
   delegated equivalent, and how delegation is documented.
3. **Escalation enforcement and arbitration (§9.6)** — who arbitrates a breach, and
   what aggregate signal warrants regulatory attention.

---

## 9. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | Two attestation levels (Level 1 qualified reviewer; Level 2 responsible PI or delegated equivalent). Level 3 superseded. Override/escalation protocol aligned to Property 7 (ACCEPT/REJECT/ASK, challenge, mitigate-and-rerun, override rationale, escalation destination). Attestation level set by the frozen risk class. |
| 1.0 | May 2026 | Initial three-level specification (superseded). |

---

*This specification is published under Apache 2.0. It defines an interface and a
framework — not an implementation. For the boundary between this open standard and
the NexTrial.ai production implementation, see [BOUNDARY.md](../BOUNDARY.md).*
