/-
  Regulatory Validation Framework — Lean4 Type Definitions v1.0
  
  Repository: nextrial-regulatory-framework
  Document:   LEAN4-TYPES-001
  Status:     Type signatures only — no theorem statements, no proofs
  License:    Apache 2.0
  
  These type definitions model the input structures for the formal
  verification properties defined in LEAN4-PROPS-001. They define
  the types that any Lean4 implementation of the proof properties
  must accept as input.
  
  This file contains type signatures only. Theorem statements and
  proof tactics are part of the production implementation and are
  not included in the open standard.
  
  See BOUNDARY.md for the boundary between open types and
  proprietary implementation.
  
  AI-Assisted — Human Review Required
-/

namespace RegulatoryFramework

-- ============================================================
-- Core scalar types
-- ============================================================

/-- Semantic version: MAJOR.MINOR.PATCH -/
structure SemanticVersion where
  major : Nat
  minor : Nat
  patch : Nat
  deriving Repr, BEq, DecidableEq

/-- ISO 8601 UTC timestamp as a comparable natural (epoch ms) -/
abbrev Timestamp := Nat

/-- Dot-notation path to a field within a structured document
    e.g., "protocol.eligibility.inclusion_criterion_3.threshold" -/
abbrev FieldPath := String

/-- Document identifier — globally unique -/
abbrev DocumentId := String

/-- Package identifier — globally unique -/
abbrev PackageId := String

-- ============================================================
-- Controlled vocabularies
-- ============================================================

/-- Regulatory jurisdictions covered by the framework -/
inductive Jurisdiction where
  | US   -- United States (FDA)
  | BR   -- Brazil (ANVISA / CEP / CONEP / CFM)
  | IN   -- India (CDSCO)
  | EU   -- European Union (EU AI Act / EU CTR)
  | DE   -- Germany (specific to EU + national)
  | MX   -- Mexico (COFEPRIS)
  | CO   -- Colombia (INVIMA)
  | AR   -- Argentina (ANMAT)
  deriving Repr, BEq, DecidableEq

/-- Document types within a clinical trial submission -/
inductive DocumentType where
  | protocol
  | informedConsentForm
  | investigatorBrochure
  | siteQualificationReport
  | regulatorySubmissionPackage
  | irbApplication
  | clinicalStudyReport
  | siteActivationChecklist
  deriving Repr, BEq, DecidableEq

/-- Field value — the possible types a structured field can hold -/
inductive FieldValue where
  | str    (v : String)
  | num    (v : Float)
  | bool   (v : Bool)
  | date   (v : Timestamp)
  | null
  deriving Repr

-- ============================================================
-- Document structure types
-- ============================================================

/-- A single field within a structured document -/
structure Field where
  path  : FieldPath
  value : FieldValue
  deriving Repr

/-- A version reference — a pointer from one document to a
    specific version of another document -/
structure VersionReference where
  sourceDocId   : DocumentId
  sourceField   : FieldPath
  targetDocId   : DocumentId
  targetVersion : SemanticVersion
  deriving Repr

/-- A cross-reference — a pointer from one document to another
    document (version-independent existence check) -/
structure CrossReference where
  sourceDocId : DocumentId
  sourceField : FieldPath
  targetDocId : DocumentId
  deriving Repr

/-- A section within a document (for completeness property) -/
structure Section where
  sectionId   : String
  sectionName : String
  present     : Bool
  deriving Repr

/-- Temporal record — timestamps associated with a document -/
structure TemporalRecord where
  createdAt   : Timestamp
  modifiedAt  : Timestamp
  effectiveAt : Timestamp
  deriving Repr

/-- A structured document instance — the primary input to
    all verification properties -/
structure DocumentInstance where
  documentId   : DocumentId
  documentType : DocumentType
  jurisdiction : Jurisdiction
  version      : SemanticVersion
  fields       : List Field
  sections     : List Section
  versionRefs  : List VersionReference
  crossRefs    : List CrossReference
  timestamps   : TemporalRecord
  deriving Repr

-- ============================================================
-- Package and registry types
-- ============================================================

/-- A submission package — a collection of documents submitted
    together for regulatory review -/
structure SubmissionPackage where
  packageId      : PackageId
  documents      : List DocumentInstance
  jurisdiction   : Jurisdiction
  protocolId     : DocumentId
  protocolVersion: SemanticVersion
  deriving Repr

/-- Field requirement specification — defines which fields are
    required for a given document type in a given jurisdiction -/
structure FieldRequirement where
  documentType   : DocumentType
  jurisdiction   : Jurisdiction
  requiredFields : List FieldPath
  deriving Repr

/-- Version registry — maps document IDs to their current version -/
structure VersionRegistry where
  entries : List (DocumentId × SemanticVersion)
  deriving Repr

/-- Document registry — the set of all known document IDs -/
structure DocumentRegistry where
  documents : List DocumentId
  deriving Repr

-- ============================================================
-- Proof result types
-- ============================================================

/-- Verification result — binary -/
inductive VerificationResult where
  | pass
  | fail
  deriving Repr, BEq, DecidableEq

/-- Detail of a single failure within a property verification -/
structure FailureDetail where
  fieldOrReference : String
  expected         : String
  observed         : Option String  -- None if absent
  remediationHint  : String
  deriving Repr

/-- Complete proof result for a single property verification -/
structure ProofResult where
  propertyName     : String
  inputDocumentId  : DocumentId
  inputPackageId   : Option PackageId
  jurisdiction     : Jurisdiction
  result           : VerificationResult
  proofDurationMs  : Nat
  failureDetails   : List FailureDetail
  lean4ProofHash   : String
  verifierVersion  : String
  deriving Repr

-- ============================================================
-- End of type definitions
-- ============================================================

/- 
  BOUNDARY NOTE
  
  These types define the input and output contract for the
  formal verification layer. Theorem statements proving the
  three MVP properties (FieldPresence, VersionConsistency,
  ReferenceResolution) against these types are part of the
  NexTrial.ai production implementation.
  
  See proof-properties-v1.md for the formal property
  definitions that any implementation must satisfy.
  
  See BOUNDARY.md for the explicit boundary between the
  open standard and the proprietary implementation.
-/

end RegulatoryFramework
