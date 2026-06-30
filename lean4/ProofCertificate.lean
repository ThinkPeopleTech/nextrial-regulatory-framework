/-
  Regulatory Validation Framework — Lean4 Proof Certificate v3.0

  Repository: nextrial-regulatory-framework
  Document:   LEAN4-CERT-001
  License:    Apache 2.0
  Source of truth: papers/regulatory-validation-framework-v3.md §4

  This module defines the eight-property proof certificate type and the
  cross-property well-formedness conditions the schema also encodes, and it
  carries the structural verification properties (the MVP properties and the
  Phase-2 properties) from proof-properties-v1.md as decidable predicates.

  It is pure Lean 4 core (no Mathlib), so `lake build` needs only the toolchain.

  AI-Assisted — Human Review Required
-/

namespace ProofCertificate

/-! ## 1. Controlled vocabularies for the eight properties -/

/-- Property 1: the source class of the rule invoked. A rule is a rule
    regardless of its source (paper §3.1). -/
inductive RuleSource where
  | regulation | protocol | sop | jurisdiction
  deriving Repr, BEq, DecidableEq

/-- Property 3 / overall: a deterministic verification result. -/
inductive OperationResult where
  | pass | fail | requiresReview
  deriving Repr, BEq, DecidableEq

/-- Property 5: the four risk classes of the named, versioned taxonomy
    `nxt-rbqm-risk-taxonomy@1.0` (paper §4.3). -/
inductive RiskClass where
  | critical | high | moderate | low
  deriving Repr, BEq, DecidableEq

/-- Property 6: the two attestation levels. There is no Level 3. -/
inductive AttestationLevel where
  | l1  -- qualified reviewer
  | l2  -- responsible principal investigator or delegated equivalent
  deriving Repr, BEq, DecidableEq

/-- Property 7: the reviewer verdict — accept, reject, or ask for revision. -/
inductive Outcome where
  | accept | reject | ask
  deriving Repr, BEq, DecidableEq

/-- Property 8: evidence (default) or substitution. -/
inductive Mode where
  | evidence | substitution
  deriving Repr, BEq, DecidableEq

/-! ## 2. Taxonomy-driven parameters (paper §4.3) -/

/-- The minimum Gate-3 attestation level required by a frozen risk class. -/
def RiskClass.minAttestation : RiskClass → AttestationLevel
  | .critical => .l2
  | .high     => .l2
  | .moderate => .l1
  | .low      => .l1

/-- Whether substitution is permitted for a frozen risk class. Prohibited by
    construction for CRITICAL and HIGH. -/
def RiskClass.substitutionAllowed : RiskClass → Bool
  | .critical => false
  | .high     => false
  | .moderate => true
  | .low      => true

/-- Numeric rank so that "at least this level" is decidable. -/
def AttestationLevel.rank : AttestationLevel → Nat
  | .l1 => 1
  | .l2 => 2

/-- `actual` meets the required minimum level. -/
def AttestationLevel.meets (actual minimum : AttestationLevel) : Bool :=
  minimum.rank ≤ actual.rank

/-! ## 3. The eight properties -/

/-- Property 4: the four-part boundary statement. -/
structure BoundaryStatement where
  verifiedScope       : List String   -- rules/criteria evaluated
  reservedScope       : List String   -- factors reserved for the human
  reviewerObligations : List String   -- actions the signature attests to
  escalationDestination : String      -- where escalation routes
  deriving Repr

/-- A boundary statement is complete iff all four parts are populated. -/
def BoundaryStatement.complete (b : BoundaryStatement) : Bool :=
  !b.verifiedScope.isEmpty
    && !b.reservedScope.isEmpty
    && !b.reviewerObligations.isEmpty
    && b.escalationDestination ≠ ""

/-- The eight-property proof certificate. -/
structure Certificate where
  -- P1 Rule invoked
  ruleSource             : RuleSource
  citation               : String
  rulesetSnapshotVersion : String
  -- P2 Values verified
  values                 : List String   -- attributable named values
  -- P3 Verification operation
  predicate              : String
  operationResult        : OperationResult
  -- P4 Boundary statement
  boundary               : BoundaryStatement
  -- P5 Risk classification (taxonomy nxt-rbqm-risk-taxonomy@1.0)
  riskClass              : RiskClass
  -- P6 Human reviewer identity
  attestationLevel       : AttestationLevel
  -- P7 Override and escalation record
  outcome                : Outcome
  -- P8 Evidence, not substitution
  mode                   : Mode
  -- Overall certified result
  result                 : OperationResult
  deriving Repr

/-! ## 4. Cross-property well-formedness -/

/-- The cross-property rules the JSON Schema and the conformance checker also
    enforce:
      (a) substitution is prohibited for CRITICAL/HIGH (P5 × P8);
      (b) the attestation level meets the minimum for the frozen class (P5 × P6);
      (c) the overall result agrees with the verification operation (P3);
      (d) the boundary statement is complete (P4);
      (e) at least one attributable value is recorded (P2). -/
def Certificate.wellFormed (c : Certificate) : Bool :=
  (c.mode == Mode.evidence || c.riskClass.substitutionAllowed)
    && c.attestationLevel.meets c.riskClass.minAttestation
    && (c.result == c.operationResult)
    && c.boundary.complete
    && !c.values.isEmpty

/-! ### Theorems about well-formedness -/

/-- Substitution is not allowed for CRITICAL decisions. -/
theorem critical_no_substitution :
    RiskClass.substitutionAllowed .critical = false := rfl

/-- Substitution is not allowed for HIGH decisions. -/
theorem high_no_substitution :
    RiskClass.substitutionAllowed .high = false := rfl

/-- CRITICAL and HIGH both require the higher attestation level. -/
theorem critical_requires_l2 : RiskClass.minAttestation .critical = .l2 := rfl
theorem high_requires_l2 : RiskClass.minAttestation .high = .l2 := rfl

/-- A CRITICAL certificate in SUBSTITUTION mode is never well-formed,
    whatever its other fields. -/
theorem critical_substitution_illformed (c : Certificate)
    (h1 : c.riskClass = RiskClass.critical) (h2 : c.mode = Mode.substitution) :
    c.wellFormed = false := by
  unfold Certificate.wellFormed
  rw [h1, h2]
  rfl

/-- Level 1 does not meet a Level 2 minimum (under-attestation is rejected). -/
theorem l1_under_attests_l2 : AttestationLevel.meets .l1 .l2 = false := rfl

/-! ## 5. Structural verification properties (carried from proof-properties-v1.md)

    Lean proves *structural* correctness — properties determinable from a
    document's architecture (fields, references, versions, sections, temporal
    order) without interpreting natural-language meaning. The MVP properties
    (Field Presence, Version Consistency, Reference Resolution) and the Phase-2
    properties (Regulatory Completeness, Non-Contradiction, Temporal Ordering)
    are carried here as decidable predicates. -/

abbrev FieldPath := String
abbrev DocumentId := String

structure Field where
  path    : FieldPath
  present : Bool
  deriving Repr, BEq

structure VersionRef where
  target          : DocumentId
  referencedVer   : Nat
  deriving Repr, BEq

structure Section where
  name    : String
  present : Bool
  deriving Repr, BEq

structure Document where
  id        : DocumentId
  fields    : List Field
  sections  : List Section
  versionRefs : List VersionRef
  crossRefs : List DocumentId
  createdAt : Nat
  effectiveAt : Nat
  deriving Repr

/-- Property 1 (MVP): Field Presence — every required field is present. -/
def fieldPresence (doc : Document) (required : List FieldPath) : Bool :=
  required.all fun p => (doc.fields.find? (·.path == p)).any (·.present)

/-- Property 2 (MVP): Version Consistency — every version reference points to the
    version the registry records for its target. -/
def versionConsistency (doc : Document) (registry : List (DocumentId × Nat)) : Bool :=
  doc.versionRefs.all fun r =>
    (registry.find? (·.1 == r.target)).any (·.2 == r.referencedVer)

/-- Property 3 (MVP): Reference Resolution — every cross-reference resolves to a
    known document. -/
def referenceResolution (doc : Document) (known : List DocumentId) : Bool :=
  doc.crossRefs.all fun t => known.contains t

/-- Property 4 (Phase 2): Regulatory Completeness — every required section is
    present in the document. -/
def regulatoryCompleteness (doc : Document) (requiredSections : List String) : Bool :=
  requiredSections.all fun s => (doc.sections.find? (·.name == s)).any (·.present)

/-- Property 5 (Phase 2): Non-Contradiction — no field path is asserted both
    present and absent (no structural contradiction). -/
def nonContradiction (doc : Document) : Bool :=
  doc.fields.all fun f =>
    doc.fields.all fun g => (f.path == g.path) → (f.present == g.present)

/-- Property 6 (Phase 2): Temporal Ordering — creation precedes or equals the
    effective time. -/
def temporalOrdering (doc : Document) : Bool :=
  doc.createdAt ≤ doc.effectiveAt

/-! ### Worked examples that build -/

/-- A well-formed MODERATE / EVIDENCE certificate (mirrors the reference
    evidence example). -/
def evidenceExample : Certificate :=
  { ruleSource := .protocol
    citation := "Protocol AMG-301 v2.1, Section 7.3.2, Inclusion Criterion 3"
    rulesetSnapshotVersion := "AMG-301-v2.1"
    values := ["HbA1c = 7.2%"]
    predicate := "hba1c < 9.0"
    operationResult := .pass
    boundary :=
      { verifiedScope := ["Inclusion Criterion 3 threshold"]
        reservedScope := ["clinical interpretation of concurrent medication"]
        reviewerObligations := ["confirm lab value against source"]
        escalationDestination := "Medical Monitor" }
    riskClass := .moderate
    attestationLevel := .l1
    outcome := .accept
    mode := .evidence
    result := .pass }

example : evidenceExample.wellFormed = true := by decide

/-- A CRITICAL certificate attempted in SUBSTITUTION mode is rejected. -/
def criticalSubstitution : Certificate :=
  { evidenceExample with riskClass := .critical, mode := .substitution, attestationLevel := .l2 }

example : criticalSubstitution.wellFormed = false := by decide

/-- A worked structural document passes all six structural properties. -/
def sampleDoc : Document :=
  { id := "ICF-AMG-301"
    fields := [⟨"informed_consent.research_statement", true⟩,
               ⟨"informed_consent.voluntary_statement", true⟩]
    sections := [⟨"purpose", true⟩, ⟨"risks", true⟩]
    versionRefs := [⟨"PROTO-AMG-301", 3⟩]
    crossRefs := ["PROTO-AMG-301"]
    createdAt := 100
    effectiveAt := 200 }

example : fieldPresence sampleDoc
    ["informed_consent.research_statement", "informed_consent.voluntary_statement"] = true := by decide
example : versionConsistency sampleDoc [("PROTO-AMG-301", 3)] = true := by decide
example : referenceResolution sampleDoc ["PROTO-AMG-301", "DMP-AMG-301"] = true := by decide
example : regulatoryCompleteness sampleDoc ["purpose", "risks"] = true := by decide
example : nonContradiction sampleDoc = true := by decide
example : temporalOrdering sampleDoc = true := by decide

end ProofCertificate
