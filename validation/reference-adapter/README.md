# Reference Adapter — superseded

> **Superseded by the v3 reference layer.** The standalone schema-validator that was
> planned for this directory is now provided, in architecture-neutral form, by:
>
> - [`../../reference/proof-certificate.schema.json`](../../reference/proof-certificate.schema.json)
>   — the normative certificate schema (artifact A),
> - [`../../reference/generate_certificate.py`](../../reference/generate_certificate.py)
>   — a runnable reference generator (artifact B), and
> - [`../validate.py`](../validate.py) + [`../run_tests.py`](../run_tests.py)
>   — the conformance checker (artifact C), run with `python ../run_tests.py --all`.
>
> There is **no** `validate.py` in this directory; the earlier placeholder usage
> referenced a script that was never implemented here. Use the tools above.

This directory is retained only as a pointer. The adapter *interface contract* it was
meant to demonstrate is specified in
[`../../specs/adapter-interface-spec-v3.md`](../../specs/adapter-interface-spec-v3.md);
that spec's §9 points at the same reference and conformance tooling. A functional
regulatory-compliance adapter is part of the NexTrial.ai production implementation and
is out of scope for this open standard (see [`../../BOUNDARY.md`](../../BOUNDARY.md)).
