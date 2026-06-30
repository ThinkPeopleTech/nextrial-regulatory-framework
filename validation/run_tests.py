#!/usr/bin/env python3
"""
Reference test runner for the proof-certificate conformance harness.

Each fixture in fixtures/ is a wrapper:

    {
      "_fixture": "<name>",
      "_expect": "PASS" | "REJECT",
      "_exercises": "<what this fixture tests>",
      "certificate": { ... a claimed proof certificate ... }
    }

The runner checks each fixture's certificate with validate.check_certificate and
compares the actual outcome (CONFORMS -> PASS, NON-CONFORMING -> REJECT) against
the declared expectation. It prints a per-fixture line with a stated reason for
every rejection, then a summary. Exit code is non-zero if any fixture's actual
outcome disagrees with its expectation.

Usage:
    python run_tests.py --all
    python run_tests.py fixtures/invalid-certificate-missing-id.json
"""
from __future__ import annotations

import argparse
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
FIXTURES = os.path.join(HERE, "fixtures")

sys.path.insert(0, HERE)
from validate import check_certificate  # noqa: E402


def run_fixture(path: str) -> tuple[bool, str]:
    with open(path) as fh:
        wrapper = json.load(fh)
    name = wrapper.get("_fixture", os.path.basename(path))
    expect = wrapper["_expect"]
    cert = wrapper["certificate"]
    ok, reasons = check_certificate(cert)
    actual = "PASS" if ok else "REJECT"
    agree = actual == expect
    reason = "" if ok else reasons[0]
    status = "ok " if agree else "XX "
    line = f"[{status}] {name:<42} expect={expect:<6} actual={actual:<6}"
    if reason:
        line += f"  reason: {reason}"
    print(line)
    return agree, name


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description="Run the conformance fixtures.")
    parser.add_argument("--all", action="store_true", help="run every fixture")
    parser.add_argument("paths", nargs="*", help="specific fixture files")
    args = parser.parse_args(argv)

    if args.all or not args.paths:
        paths = sorted(glob.glob(os.path.join(FIXTURES, "*.json")))
    else:
        paths = args.paths

    print(f"Running {len(paths)} fixtures against the proof-certificate conformance checker\n")
    passed = 0
    failed_names = []
    for path in paths:
        agree, name = run_fixture(path)
        if agree:
            passed += 1
        else:
            failed_names.append(name)

    total = len(paths)
    print(f"\nSummary: {passed}/{total} fixtures matched their expected outcome")
    if failed_names:
        print("Mismatched fixtures: " + ", ".join(failed_names))
        return 1
    print("ALL FIXTURES MATCHED EXPECTED OUTCOMES")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
