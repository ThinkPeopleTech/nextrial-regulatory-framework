# Reference Implementation

This directory is the FDA-artifact reference layer for the framework:

| File | Role |
|---|---|
| [`proof-certificate.schema.json`](proof-certificate.schema.json) | **Artifact A** — the normative JSON Schema (draft 2020-12) for the eight-property proof certificate, model-architecture-neutral. |
| [`risk-taxonomy-v1.json`](risk-taxonomy-v1.json) | The named, versioned risk taxonomy (`nxt-rbqm-risk-taxonomy@1.0`), referenced by `$ref` from the schema and bound into Property 5. |
| [`generate_certificate.py`](generate_certificate.py) | **Artifact B** — a runnable, architecture-neutral generator that emits a conforming certificate from a compact decision descriptor. |
| [`examples/`](examples/) | Conforming example certificates produced by the generator. |
| [`requirements.txt`](requirements.txt) | Python dependencies (`jsonschema`, `referencing`). |

The conformance checker (**Artifact C**) lives in [`../validation/`](../validation/).

## What this implementation is — and is not

It is a **clean-room reference**. It contains no proprietary internals. It is
**architecture-neutral**: nothing here references a model, weights, adapters,
training data, a retrieval corpus, or any architectural component. It assembles a
certificate from the inputs of a verification *operation* only.

It **stores no documents and captures no PHI** beyond what a verification operation
requires: a value is recorded as the named scalar a rule was checked against, with
an attribution chain to its source — not the source document itself. The example
values are illustrative and anonymized.

## Install

```bash
pip install -r requirements.txt
```

## Run

```bash
# Emit a canonical example certificate to stdout
python generate_certificate.py --emit evidence
python generate_certificate.py --emit substitution

# Generate a certificate from your own decision descriptor
python generate_certificate.py --input my-decision.json

# (Re)write the committed examples
python generate_certificate.py --write-examples
```

Every certificate the generator returns is validated against
`proof-certificate.schema.json` before it is emitted; an invalid certificate raises
rather than being returned.

## The one rule the generator enforces as a guard

Substitution is **unavailable by construction for CRITICAL and HIGH** decisions
(paper §4.3 / §4.4). A descriptor requesting a `CRITICAL`/`HIGH` certificate with
`mode = SUBSTITUTION` is **unproducible** — the generator raises
`UnproducibleCertificate`. The schema encodes the same constraint independently, so
a hand-authored certificate that violates it fails validation.

## The two examples

| Example | Risk class | Mode | Determination |
|---|---|---|---|
| [`examples/evidence-example.json`](examples/evidence-example.json) | MODERATE | EVIDENCE | Eligibility threshold (HbA1c < 9.0) |
| [`examples/substitution-example.json`](examples/substitution-example.json) | LOW | SUBSTITUTION | Administrative presence check (Form FDA 1572 box 1) |

Both validate PASS against the schema. The SUBSTITUTION example is a LOW-risk
administrative check, because a CRITICAL/HIGH substitution cannot be produced.
