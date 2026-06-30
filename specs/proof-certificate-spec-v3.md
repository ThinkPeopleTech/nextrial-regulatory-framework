# Proof Certificate Specification v3.0

**Repository:** nextrial-regulatory-framework
**Document:** PC-SPEC-001
**Version:** 3.0, FDA-Filing-Aligned Revision
**Status:** Published
**Author:** Steven Thompson, NexTrial.ai
**Date:** June 2026
**Source of truth:** [papers/regulatory-validation-framework-v3.md](../papers/regulatory-validation-framework-v3.md), §4
**Companion to:** NexTrial.ai public comment to FDA Docket No. FDA-2026-N-4390
**AI-Assisted — Human Review Required**

> Supersedes [proof-certificate-spec-v1.md](proof-certificate-spec-v1.md). The
> v1.0 four-property certificate is retained for historical reference. This v3.0
> specification aligns the property numbering exactly with the framework paper
> and the FDA filing: **eight properties**, numbered 1 through 8.

---

## 1. Purpose

This specification defines the **proof certificate** — the artifact the framework
asks for. A proof certificate is a machine-readable, signed, versioned object,
produced at the moment an AI-assisted decision is made, that serializes eight
properties. The first four define what was checked and what was reserved for the
human. The second four make the artifact defensible under inspection, under
accountability scrutiny, and under continuous learning.

Everything in the verification architecture (paper §3) exists to produce this
artifact. The recommendation to a pilot or a standards body is to evaluate any
system by the certificate it emits rather than by the architecture that emits it.
Any system that produces a conforming certificate satisfies the standard,
whether or not it resembles NexTrial's.

> **The discipline that separates a certificate from a description.** Each
> property carries an **admissibility test**: the specific inspection an auditor
> can perform against it. A property that cannot be inspected is not a property of
> this certificate, and the test, not the label, is what a pilot should evaluate.

---

## 2. Regulatory Basis

The same object satisfies the reconstructibility requirement that recurs across
jurisdictions. None of these requirements mandates a particular substrate; all of
them require a particular class of artifact. A confidence score satisfies none of
them.

| Regulation | Requirement | How the certificate satisfies it |
|---|---|---|
| 21 CFR Part 11 | A regulated decision must be reconstructible from source through decision logic to the rule that produced it | Properties 1–3 record rule, values, and operation; the signed lineage is the audit trail |
| ALCOA+ | Attributable, Legible, Contemporaneous, Original, Accurate, plus Complete, Consistent, Enduring, Available | Values attributable to source (P2); certificate produced at decision time (contemporaneous); supersede-not-delete (original, enduring) |
| ICH E6(R3) | Documentation supports source verification and reconstruction | The certificate is the per-decision verification artifact |
| EU AI Act Art. 11 | Technical documentation | The certificate is the technical documentation the article calls for |
| EU AI Act Art. 12 | Record-keeping / automatic logs | The signed, append-only, supersede-not-delete lineage |
| EU AI Act Art. 13 | Transparency to deployers | A single certificate projects to each stakeholder at the detail that role needs |
| EU AI Act Art. 14 | Human oversight | Gate 3 attestation (P6–P8) against the boundary statement (P4) |
| CFM Resolução 2.454/2026 | Physician oversight and explicability for AI in medical practice | Boundary statement + named attester make the human contribution inspectable |
| ANVISA RDC 945/2024 | Submissions traceable to source | Property 2 attribution + lineage |
| India NDCTR 2019 | Investigator attestation and reconstructibility | Property 6 attestation + reconstructible operation |

---

### 2.1 EU AI Act article mapping (Articles 9–14)

The EU AI Act classifies relevant clinical AI as high-risk. The articles map onto
the architecture directly; in each case the artifact the article requires is one
the architecture already produces (paper §8.2; surfaced from
[regulatory-mappings/eu-ai-act.json](../regulatory-mappings/eu-ai-act.json)).

| Article | Obligation | Where it is satisfied |
|---|---|---|
| **Article 9** | Risk management system | The RBQM pre-gate is a documented, continuously maintained classification of risk for every output, bounded by a declared context of use, frozen into **Property 5** ([rbqm-pre-verification-spec-v3.md](rbqm-pre-verification-spec-v3.md)). |
| **Article 10** | Data and data governance | Processing and residency scoped by jurisdiction, kept in-region (LGPD for the Brazil perimeter), de-identified to each jurisdiction's standard; the architecture stores no documents and captures no PHI beyond what a verification operation requires. |
| **Article 11** | Technical documentation | The **proof certificate** is the technical documentation the article calls for. |
| **Article 12** | Record-keeping | The signed, append-only, supersede-not-delete **bi-temporal lineage** ([continuous-learning-spec-v3.md](continuous-learning-spec-v3.md)). |
| **Article 13** | Transparency to deployers | A single certificate projects to each stakeholder at the detail that role needs (Properties **1**, **3**, **4**). |
| **Article 14** | Human oversight | **Gate 3** attestation and the four-part boundary statement: a named human attests against a record of exactly what was and was not checked (Properties **4**, **6**, **7**, **8**). |

What the Act does not yet specify is how formal verification methods map onto
conformity assessment; the structural proof of Gate 2 is offered as a candidate
answer (paper §8.2, §9.1), not a settled one.

## 3. The Eight Properties and Their Admissibility Tests

Every proof certificate must contain exactly these eight properties. No
certificate that omits any property satisfies this specification. The table below
is the normative summary, reproduced from paper §4.1; the subsections that follow
give the requirements for each property.

| # | Property | What it records | Admissibility test |
|---|---|---|---|
| 1 | Rule invoked | The specific rule, by source, citation, and version (regulatory provision, protocol criterion, SOP step, or jurisdictional requirement), with the ruleset snapshot version and effective date. Citation precision, not "applicable regulation." | An inspector re-executes the rule against the source document at the cited snapshot version and obtains the same result. |
| 2 | Values verified | The exact patient, protocol, site, or operational values checked, listed rather than summarized, each attributable to its source per ALCOA+ and contemporaneous with the decision. | Each value is independently verifiable against source, and the set is sufficient to re-execute the operation. |
| 3 | Verification operation | The deterministic procedure that returned pass or fail on this specific decision, expressible as a formal predicate, with its version and result. | An independent verifier re-running the operation against the same rule and values obtains the same output; bit-exact reproducibility is the standard. |
| 4 | Boundary statement | What the operation did not check, and the judgment factors reserved for the responsible human. Four parts (§3.4). | A reviewer can determine from the boundary statement alone what the AI did and did not contribute, sufficient to apportion liability. |
| 5 | Risk classification | The risk class assigned by the RBQM pre-gate and frozen at decision time, with a named, versioned taxonomy, indexing gate rigor and re-verification cadence. | An auditor confirms the rigor and cadence applied match what the frozen risk class requires. |
| 6 | Human reviewer identity | The identity and role of the human who attested, bound to the attestation. | Liability is allocable by attestation level, with the responsible principal investigator primary. |
| 7 | Override and escalation record | Whether the human accepted, rejected, or asked for revision; any challenge the reviewer raised and how it was resolved, including any mitigate-and-rerun loop; any override and its recorded rationale; and whether escalation criteria were met and to where. | An auditor reconstructs the full human decision path, including any challenge and its resolution, and confirms escalation occurred where required. |
| 8 | Evidence, not substitution | An explicit declaration that the operation is evidence presented to the reviewer, not a substitution for the reviewer's judgment. | The certificate cannot be read as having reduced the human verification burden. |

### 3.1 Property 1 — Rule invoked

**Records:** the specific rule, by source, citation, and version. The source may
be a regulatory provision, a protocol criterion, an SOP step, or a jurisdictional
requirement — a rule is a rule regardless of its source (paper §3.1). The record
carries the ruleset snapshot version and effective date.

**Requirements:**
- Cite the specific provision at section/subsection or criterion level — never the
  regulation title alone ("applicable regulation" fails).
- Record `rule_source` ∈ {`REGULATION`, `PROTOCOL`, `SOP`, `JURISDICTION`}.
- Record the ruleset snapshot version and the effective date of that version.
- Be the rule actually applied, not a summary of applicable rules.

**Admissibility test:** an inspector re-executes the rule against the source
document at the cited snapshot version and obtains the same result.

### 3.2 Property 2 — Values verified

**Records:** the exact patient, protocol, site, or operational values checked,
listed rather than summarized, each attributable to source per ALCOA+ and
contemporaneous with the decision.

**Requirements:**
- List actual values, not descriptions — `HbA1c = 7.2%`, not "within range".
- Each value carries `source_origin`, `acquisition_timestamp`, and an
  `attribution_chain` to its origin document (ALCOA+ attributable).
- The set must be sufficient to re-execute the operation.

**Admissibility test:** each value is independently verifiable against source, and
the set is sufficient to re-execute the operation.

### 3.3 Property 3 — Verification operation

**Records:** the deterministic procedure that returned pass or fail on this
decision, expressible as a formal predicate, with its version and result.

**Requirements:**
- Deterministic: same inputs + same operation = same result. No probabilistic
  reasoning, no confidence scores presented as verification.
- Expressible as a formal predicate; carry the operation version and result
  (`PASS` | `FAIL` | `REQUIRES_REVIEW`).
- Re-runnable on the original inputs in front of an inspector.

**Admissibility test:** an independent verifier re-running the operation against
the same rule and values obtains the same output; **bit-exact reproducibility is
the standard.**

### 3.4 Property 4 — Boundary statement

**Records:** what the operation did not check, and the judgment factors reserved
for the responsible human. Property 4 answers the most common claim made for AI
oversight — that a human approved the output. A signature on its own is a
platitude, not a control; the boundary statement is what gives the signature
something to attest to. It has **four parts**, and a statement missing any of them
is insufficient to support effective human oversight.

| Part | Content |
|---|---|
| **Verified scope** | The bounded list of rules and criteria the operation evaluated. Anything not on the list is, by construction, outside verified scope. |
| **Reserved scope** | The bounded list of judgment factors reserved for the human: clinical-judgment domains, ambiguity resolution, interpretation of novel protocol provisions. |
| **Reviewer obligations** | The specific actions the reviewer must take to discharge oversight, to which the signature attests — not a generic approval. |
| **Escalation criteria** | The conditions under which the system must escalate to a higher level of review, and the destination of that escalation. |

**Admissibility test:** a reviewer can determine from the boundary statement alone
what the AI did and did not contribute, sufficient to apportion liability.

### 3.5 Property 5 — Risk classification

**Records:** the risk class assigned by the RBQM pre-gate (paper §3.0) and frozen
at decision time, recorded with a **named, versioned taxonomy referenced by
identifier**, indexing gate rigor and re-verification cadence.

**The taxonomy.** Property 5 records not only the class label but the taxonomy
under which it was assigned, by identifier and version:

- **Taxonomy identifier:** `nxt-rbqm-risk-taxonomy`
- **Taxonomy version:** `1.0`
- **Canonical reference:** `nxt-rbqm-risk-taxonomy@1.0`

The taxonomy is defined in [reference/risk-taxonomy-v1.json](../reference/risk-taxonomy-v1.json)
and is the same identifier the schema (PC-SCHEMA), the RBQM pre-verification spec
(RBQM-SPEC-001 v3), and the continuous-learning spec reference. The baseline below
pairs each class with its failure consequence, whether substitution is permitted,
the re-verification cadence, and the minimum Gate 3 attestation level (paper §4.3).

| Risk class | Failure consequence | Substitution | Re-verification cadence | Minimum Gate 3 attestation |
|---|---|---|---|---|
| **CRITICAL** | Immediate patient-safety or regulatory risk | Prohibited by construction | Every certificate | Level 2 |
| **HIGH** | Patient-experience harm or material protocol deviation | Prohibited by construction | Daily | Level 2 |
| **MODERATE** | Operational; independent verification still required | Permitted under property 8 | Weekly | Level 1 permitted |
| **LOW** | Administrative or logistical; no safety or regulatory consequence | Permitted | At deployment, then monthly | Level 1 sufficient |

The class is assigned before verification and frozen into the certificate, so the
rigor a decision received is a matter of record rather than discretion. It is a
proposed baseline; harmonizing a single taxonomy across the FDA, the EU, ANVISA,
and the CDSCO is open work (paper §9.3).

**Admissibility test:** an auditor confirms the rigor and cadence applied match
what the frozen risk class requires.

### 3.6 Property 6 — Human reviewer identity

**Records:** the identity and role of the human who attested, bound to the
attestation, with the attestation level (see §4 and SAID-SPEC-001 v3).

**Requirements:**
- Name, role, and credential of the attester.
- The attestation level performed: `1` (qualified reviewer) or `2` (responsible
  principal investigator or delegated equivalent). There is no Level 3.
- Binding of the identity to the attestation (signature reference).

**Admissibility test:** liability is allocable by attestation level, with the
responsible principal investigator primary.

### 3.7 Property 7 — Override and escalation record

**Records:** the full human decision path. The reviewer's verdict is one of
exactly three outcomes:

- **`ACCEPT`** — the reviewer accepts the determination.
- **`REJECT`** — the reviewer rejects the determination.
- **`ASK`** — the reviewer asks for revision (interrogates a rule application,
  questions a value, or sends the decision back).

The gate is interactive, not a single yes/no. Property 7 therefore also records:

- **Challenge and resolution.** Any challenge the reviewer raised and how it was
  resolved, including any **mitigate-and-rerun** loop in which the issue is
  mitigated, the verification re-run, and the determination converges or escalates.
- **Override rationale.** Any override the reviewer made, with its recorded
  rationale.
- **Escalation.** Whether escalation criteria (P4) were met, and the **escalation
  destination** to where the decision was escalated.

**Admissibility test:** an auditor reconstructs the full human decision path,
including any challenge and its resolution, and confirms escalation occurred where
required.

### 3.8 Property 8 — Evidence, not substitution

**Records:** an explicit declaration that the operation is **evidence** presented
to the reviewer, **not a substitution** for the reviewer's judgment. This is the
certificate's load-bearing declaration, and it defaults to the conservative
reading.

**Requirements:**
- `mode` ∈ {`EVIDENCE`, `SUBSTITUTION`}, **default `EVIDENCE`**.
- Every certificate is `EVIDENCE` unless **both** conditions hold: the risk class
  permits substitution, **and** Property 8 records that the substitution was
  authorized.
- **Substitution is unavailable by construction for CRITICAL and HIGH decisions.**
  A CRITICAL or HIGH certificate with `mode = SUBSTITUTION` is non-conforming.
- The human verification burden is relocated and made inspectable, never removed.

**Admissibility test:** the certificate cannot be read as having reduced the human
verification burden.

---

## 4. Attestation

Gate 3 attestation has **two levels** (see SAID-SPEC-001 v3):

- **Level 1 — qualified reviewer.**
- **Level 2 — responsible principal investigator or a delegated equivalent of
  equivalent standing.**

There is no Level 3. The minimum level is set by the frozen risk class (Property 5,
§3.5): CRITICAL and HIGH require Level 2; MODERATE permits Level 1; LOW is
sufficient at Level 1.

---

## 5. Certificate Schema

The normative, machine-checkable schema is
[reference/proof-certificate.schema.json](../reference/proof-certificate.schema.json)
(JSON Schema 2020-12, model-architecture-neutral). It encodes the eight properties,
the Property 7 outcome enum (`ACCEPT` / `REJECT` / `ASK`), the Property 8 mode enum
(default `EVIDENCE`), the conditional that `CRITICAL`/`HIGH` may not be
`SUBSTITUTION`, the attestation-level enum (`1` / `2`), and the four boundary
sub-objects. Conforming and intentionally non-conforming examples are in
[reference/examples/](../reference/examples/).

---

## 6. Immutability, Supersession, and Bi-Temporal Recording

A proof certificate is immutable once sealed. Proof binds to a **state, not a
model** (paper §5): the certificate attests to the exact rule, values, and system
state in force when the decision was made.

- **Immutable once sealed.** No field is modified after sealing; the certificate
  hash must match the content at any future verification. Each entry is signed with
  a FIPS-approved hash (SHA-256 under FIPS 180-4 or HMAC-SHA-256 under FIPS 198-1).
- **Supersede, do not delete.** When a determination changes — because the system
  changed (state currency) or a referenced rule changed (reference currency) — the
  prior certificate is set to `SUPERSEDED`, a new certificate is generated, and
  both are retained in the lineage. A decision made under an earlier state stays
  defensible years later because that state's certificate is preserved intact.
- **Bi-temporal lineage.** Every lineage entry carries **valid-time** (when the
  state/value was in force) and **transaction-time** (when the record was written),
  enabling an as-of reconstruction of any decision exactly as it stood when made.

The full state-binding mechanism, the two-clocks model, and the predetermined
change envelope are specified in
[continuous-learning-spec-v3.md](continuous-learning-spec-v3.md).

---

## 7. What a Proof Certificate Is Not

A **confidence score** is the model grading its own work; it is correlated
evidence that shares the output's failure modes, and it satisfies none of the
regulatory requirements in §2. A proof certificate is reproducible, inspectable,
and admissible; a confidence score is none of these. The certificate is also not
an audit-log export (which records that something happened, not what was verified
before the decision), not a post-hoc explainability report (which is retrospective,
where the certificate is contemporaneous), and not a dashboard (which you cannot
hand to an inspector).

---

## 8. Open Questions

Carried from the paper (§9):
1. **Who certifies the encoding (§9.1)** — when a regulation is encoded into a
   computable check, who certifies the encoding is faithful, and who is accountable
   when the check is structurally perfect and semantically wrong. This is the
   framework's principal unsolved problem.
2. **Cross-agency standardization (§9.2)** — the minimum property set regulators
   would agree to accept, and how a certificate is presented to a reviewer without
   formal-methods expertise.
3. **Risk-taxonomy harmonization (§9.3)** — a shared taxonomy across the FDA, the
   EU, ANVISA, and the CDSCO.

---

## 9. Version History

| Version | Date | Changes |
|---|---|---|
| 3.0 | June 2026 | Eight-property certificate aligned to the framework paper and FDA filing. Property 7 = ACCEPT/REJECT/ASK with challenge, mitigate-and-rerun, override rationale, and escalation destination. Property 8 = evidence-not-substitution, default EVIDENCE, substitution prohibited for CRITICAL/HIGH. Property 5 carries a named, versioned risk taxonomy by identifier. Two attestation levels. |
| 1.0 | May 2026 | Initial four-property specification (superseded). |

---

*This specification is published under Apache 2.0. It defines an artifact and a
schema — not an implementation. For the boundary between this open standard and the
NexTrial.ai production implementation, see [BOUNDARY.md](../BOUNDARY.md).*
