#!/usr/bin/env python3
"""Compute the light-depth threshold of change-review from past run statistics.

Each file in STATS_DIR is one run's JSON record (pr-mode.md Step 9). Only
re-reviews run at full depth count, escalated runs included (they are
recorded with depth "full"): a light run had one worker, so its yield says
nothing about what four workers would have found.

Rule: sort those runs by `lines` (the PR-only change they reviewed). Walk up
from the smallest; the threshold is the largest `lines` value up to which every
run, ties included, produced at most one new finding (`findings_total`). The
first line count whose runs produced more stops the walk. With no such run the
threshold is -1, meaning: never light.

Usage: threshold.py STATS_DIR
Prints: {"threshold": T, "runs": n, "stopped_at": L or null}
"""
import glob
import json
import os
import sys
from collections import defaultdict


def main():
    if len(sys.argv) != 2:
        print(__doc__, file=sys.stderr)
        return 2
    by_lines = defaultdict(list)
    n = 0
    for fp in sorted(glob.glob(os.path.join(sys.argv[1], "*.json"))):
        try:
            r = json.load(open(fp, encoding="utf-8"))
        except (OSError, ValueError) as e:
            print(f"skip {fp}: {e}", file=sys.stderr)
            continue
        if r.get("review") != "re-review" or r.get("depth") != "full":
            continue
        if not isinstance(r.get("lines"), int) or not isinstance(r.get("findings_total"), int):
            continue
        by_lines[r["lines"]].append(r["findings_total"])
        n += 1
    threshold, stopped = -1, None
    for lines in sorted(by_lines):
        if max(by_lines[lines]) <= 1:
            threshold = lines
        else:
            stopped = lines
            break
    print(json.dumps({"threshold": threshold, "runs": n, "stopped_at": stopped}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
