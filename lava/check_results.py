#!/usr/bin/env python3
"""Read LAVA results CSV from stdin, exit 1 if any test case failed."""
import sys
import csv
import re

reader = csv.DictReader(sys.stdin)
rows = []
for r in reader:
    # A 'lava' row named like '12_remote-desktop' is a whole test definition;
    # it fails when its script stops early, so count it too.
    if r.get('suite') != 'lava' or re.match(r'\d+_', r.get('name', '')):
        rows.append(r)
failures = [r for r in rows if r.get('result', '').lower() not in ('pass', 'skip')]
for f in failures:
    print(f"  FAIL: {f.get('suite', '?')}/{f.get('name', '?')} -> {f.get('result', '?')}")
if failures:
    print(f"{len(failures)} test(s) failed")
    sys.exit(1)
print(f"All {len(rows)} test(s) passed")
