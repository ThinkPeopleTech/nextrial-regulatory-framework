# Risk-Based Quality Management Pre-Verification Layer Specification v3.0

**Repository:** nextrial-regulatory-framework
**Document:** RBQM-SPEC-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §3.0 and §4.3
**AI-Assisted — Human Review Required**

> Supersedes [rbqm-pre-verification-spec-v1.md](rbqm-pre-verification-spec-v1.md).
> The v1.0 three-dimension (site / protocol / population) composite model is
> retained for historical reference and survives as operational input. This v3.0
> specification aligns the pre-gate to the framework paper: a **two-factor**
> classification (model influence × decision consequence) producing the four
> classes of the **named, versioned risk taxonomy `nxt-rbqm-risk-taxonomy@1.0`**,
> frozen at decision time into **Property 5** of the proof certificate.

---

## 1. Purpose

Before a proposal reaches the verification gates, it passes through a risk-based
quality management **pre-gate**. The pre-gate does not check conformance — it is
not a fourth gate. It performs a different function: it **classifies the
decision's risk**, and that classification governs how the rest of the pipeline
behaves. The class it assigns is **frozen into the proof certificate at decision
time**, where it becomes Property 5.

The pre-gate situates the risk chain at the **design layer**, upstream of any
monitoring dashboard, because the live integrity question in AI-assisted trials is
not only catching errors after they occur but trusting that the AI-assisted
identification of what is critical was sound in the first place. That trust is
established or denied at the design layer, so the pre-gate is a primary site of
trustworthiness evaluation, not an operational afterthought.

---

## 2. Regulatory Basis

The classification follows a chain the regulatory world already accepts.

| Instrument | Role in the pre-gate |
|---|---|
| ICH E8(R1) | Critical-to-Quality factors identify what matters in a given protocol |
| ICH E6(R3) | Risk-based quality management translates CtQ factors into risks, KRIs, and quality tolerance limits |
| ICH Q9(R1) | Quality-risk-management discipline around them |
| EU AI Act Art. 9 | The documented, continuously maintained classification of risk is the structural form of an Art. 9 risk-management system |
| FDA draft AI guidance (FDA-2024-D-4689) | The two-factor sizing of model risk (influence × consequence) |
| FDA 21 CFR 312 | Sponsor responsibility for risk-proportionate oversight |

---

## 3. The Two-Factor Classification

A decision is assigned to a class by a two-factor logic — the same two factors the
FDA's draft AI guidance uses to size model risk.

- **Model influence.** How much the AI-assisted output drives the decision relative
  to the other evidence available to the reviewer. An output a qualified human would
  independently arrive at carries **low** influence; an output the decision
  effectively rests on carries **high** influence.
- **Decision consequence.** The severity of the outcome if the decision is wrong. A
  consequence reaching participant safety or regulatory standing is **high**; a
  purely administrative or logistical consequence is **low**.

Each axis is scored high / medium / low, and the pair places the decision into one
of four classes (paper §3.0):

| Model influence \ Decision consequence | Low | Medium | High |
|---|---|---|---|
| **High** | MODERATE | HIGH | CRITICAL |
| **Medium** | LOW | MODERATE | HIGH |
| **Low** | LOW | LOW | MODERATE |

A high-influence, high-consequence decision is **CRITICAL** and cannot be handled
as anything less; a low-influence, low-consequence decision is **LOW**. This matrix
is the normative content of [reference/risk-taxonomy-v1.json](../reference/risk-taxonomy-v1.json)
(`assignment.matrix`).

### 3.1 Operational inputs (carried from v1.0)

The model-influence and decision-consequence scores may be informed by the three
operational risk dimensions of v1.0 — **site risk**, **protocol risk**, and
**population risk** — which remain useful evidence for sizing consequence and
influence. They are inputs to the two-factor score, not a separate composite. The
v1.0 dimension assessments and the cold-start handling are retained in
[rbqm-pre-verification-spec-v1.md](rbqm-pre-verification-spec-v1.md).

---

## 4. What the Frozen Class Parameterizes

The risk class the pre-gate assigns is frozen into the certificate at decision time
and parameterizes three things downstream (paper §3.0, §4.3):

| Parameter | How the class drives it |
|---|---|
| **Gate rigor** | The rigor applied at each verification gate, scaled to the decision's risk class. |
| **Re-verification cadence** | Risk-classified rather than calendar-driven: CRITICAL = every certificate; HIGH = daily; MODERATE = weekly; LOW = at deployment then monthly. |
| **Human re-attestation threshold** | Under continuous learning, high-risk decisions force supersession and human re-attestation on any material change; lower-risk decisions permit wider automated variance within a predetermined change envelope (see [continuous-learning-spec-v3.md](continuous-learning-spec-v3.md)). |

The class also sets the minimum Gate 3 attestation level and whether substitution
is permitted, per the taxonomy:

| Risk class | Substitution | Re-verification cadence | Minimum Gate 3 attestation |
|---|---|---|---|
| CRITICAL | Prohibited by construction | Every certificate | Level 2 |
| HIGH | Prohibited by construction | Daily | Level 2 |
| MODERATE | Permitted under Property 8 | Weekly | Level 1 permitted |
| LOW | Permitted | At deployment, then monthly | Level 1 sufficient |

Because the class is assigned **before** verification and carried in the
certificate, risk-proportionality is structural rather than procedural: a reviewer
cannot accidentally apply low-risk handling to a high-risk decision.

---

## 5. Binding the Frozen Class into Property 5

The pre-gate's output is bound into **Property 5** of the proof certificate by
**taxonomy identifier**, so that the certificate records not only the class label
but the taxonomy version under which it was assigned.

- **Taxonomy identifier:** `nxt-rbqm-risk-taxonomy`
- **Taxonomy version:** `1.0`
- **Canonical reference:** `nxt-rbqm-risk-taxonomy@1.0`
- **Definition of record:** [reference/risk-taxonomy-v1.json](../reference/risk-taxonomy-v1.json)
  (`$id: https://nextrial.ai/schemas/risk-taxonomy-v1.json`)

Property 5 therefore carries `{ risk_class, taxonomy_id = "nxt-rbqm-risk-taxonomy",
taxonomy_version = "1.0", frozen_at, gate_rigor, reverification_cadence }`. The
schema [reference/proof-certificate.schema.json](../reference/proof-certificate.schema.json)
`$ref`s the same taxonomy resource for the `risk_class` enum, so the pre-gate, the
schema, and the certificate all index the one identifier. An auditor confirms the
rigor and cadence applied match what the frozen class requires (the Property 5
admissibility test).

---

## 6. Cold-Start Handling

The cold-start problem (insufficient history at new sites, novel protocols, or rare
populations) is carried forward from v1.0 §6 as input handling: where data is
insufficient to score an axis confidently, the pre-gate sizes that axis
conservatively (no lower than the evidence supports) and records the cold-start
condition. Defining the minimum data for confident influence/consequence scoring
remains open work.

---

## 7. RBQM Record

Every assessment produces a structured record that carries, at minimum, the two
factor scores, the assigned class, the taxonomy reference, and the parameters the
class sets:

```json
{
  "rbqm_record_id": "uuid",
  "assessment_timestamp": "ISO 8601 UTC",
  "protocol_identifier": "string",
  "site_identifier": "string (anonymized)",
  "jurisdiction": "ISO 3166-1 alpha-2",
  "model_influence": "HIGH | MEDIUM | LOW",
  "decision_consequence": "HIGH | MEDIUM | LOW",
  "assigned_risk_class": "CRITICAL | HIGH | MODERATE | LOW",
  "taxonomy_id": "nxt-rbqm-risk-taxonomy",
  "taxonomy_version": "1.0",
  "gate_rigor": "string",
  "reverification_cadence": "string",
  "minimum_attestation_level": 1,
  "substitution_permitted": false,
  "cold_start_applied": false,
  "frozen_at": "ISO 8601 UTC"
}
```

The `assigned_risk_class`, `taxonomy_id`, `taxonomy_version`, `gate_rigor`, and
`reverification_cadence` map directly onto Property 5 of the certificate.

---

## 8. Open Questions

1. **Taxonomy harmonization (paper §9.3).** Harmonizing a single taxonomy across the
   FDA, the EU, ANVISA, and the CDSCO is open work; `nxt-rbqm-risk-taxonomy@1.0` is a
   proposed baseline.
2. **Cold-start scoring.** The minimum data for confident influence/consequence
   scoring is unvalidated.
3. **Re-classification under reference change.** When a referenced rule moves, a
   re-verification may raise a decision's class; the right cadence and evidence are
   open (continuous-learning-spec-v3.md §6).

---

## 9. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | Two-factor classification (model influence × decision consequence) producing the four taxonomy classes; pre-gate parameterizes gate rigor and re-verification cadence; frozen class bound into Property 5 by taxonomy identifier `nxt-rbqm-risk-taxonomy@1.0`. |
| 1.0 | May 2026 | Initial three-dimension composite specification (superseded; retained as operational input). |

---

*This specification is published under Apache 2.0. For the boundary between this
open standard and the NexTrial.ai production implementation, see
[BOUNDARY.md](../BOUNDARY.md).*
