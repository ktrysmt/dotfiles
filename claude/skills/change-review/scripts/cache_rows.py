#!/usr/bin/env python3
"""Read the rows of a change-review PR cache without printing the cache.

The cache is an active file (<owner>__<repo>__<number>.md) plus an optional
history directory (<owner>__<repo>__<number>.history/, one Markdown file per
run). Rows are resolved by id: a row in a later history file (by file name)
replaces an earlier one, and a row in the active file replaces any history row.

Usage:
  cache_rows.py CACHE_MD [--history DIR] [--path TEXT] [--status S1,S2] [--trials] [--count]

Output: one compact JSON object per line. --count prints one JSON object with
the number of distinct finding ids, trial ids and other-reviewer rows.
Schema v1 caches (no severity column, no history directory) are read too.
"""
import argparse
import glob
import json
import os
import re
import sys

FINDINGS = "既出の指摘"
TRIALS = "修正の試行"
REVIEWERS = "他レビュアの指摘"

FINDING_KEYS = {
    "id": "id",
    "file:line": "location",
    "観点": "axes",
    "severity": "severity",
    "status": "status",
    "根拠url": "evidence",
    "提出": "submitted",
}
TRIAL_KEYS = {
    "trial": "trial",
    "finding": "finding",
    "回数": "count",
    "判定": "verdict",
    "記録": "record",
}


def split_row(line):
    cells = re.split(r"(?<!\\)\|", line.strip())
    if cells and cells[0] == "":
        cells = cells[1:]
    if cells and cells[-1] == "":
        cells = cells[:-1]
    return [c.strip().replace("\\|", "|") for c in cells]


def tables(path):
    """Yield (section heading, [row dicts]) for every table in a Markdown file."""
    section = None
    header = None
    rows = []
    with open(path, encoding="utf-8") as fh:
        lines = fh.read().splitlines()
    for line in lines + [""]:
        if line.startswith("## "):
            if header is not None:
                yield section, rows
            section, header, rows = line[3:].strip(), None, []
            continue
        if line.startswith("|"):
            cells = split_row(line)
            if header is None:
                header = cells
            elif all(re.fullmatch(r":?-{3,}:?", c) for c in cells if c):
                continue
            else:
                rows.append(dict(zip(header, cells)))
        elif header is not None and line.strip() == "":
            yield section, rows
            header, rows = None, []
    return


def normalize(row, keys, claim_prefix):
    out = {}
    for k, v in row.items():
        lk = k.lower()
        if lk in keys:
            out[keys[lk]] = v
        elif k.startswith(claim_prefix):
            out["claim" if claim_prefix == "要旨" else "chain"] = v
    return out


def history_files(cache, history):
    hdir = history or re.sub(r"\.md$", "", cache) + ".history"
    return sorted(glob.glob(os.path.join(hdir, "*.md")))


def collect(cache, history, want):
    resolved = {}
    reviewers = 0
    sources = history_files(cache, history) + ([cache] if os.path.exists(cache) else [])
    for src in sources:
        for section, rows in tables(src):
            if section is None:
                continue
            if want == "findings" and section.startswith(FINDINGS):
                for r in rows:
                    n = normalize(r, FINDING_KEYS, "要旨")
                    if re.match(r"F-\d+", n.get("id", "")):
                        n["source"] = os.path.basename(src)
                        resolved[n["id"]] = n
            elif want == "trials" and section.startswith(TRIALS):
                for r in rows:
                    n = normalize(r, TRIAL_KEYS, "連鎖")
                    if re.match(r"T-\d+", n.get("trial", "")):
                        n["source"] = os.path.basename(src)
                        resolved[n["trial"]] = n
            elif want == "reviewers" and section.startswith(REVIEWERS):
                reviewers += sum(1 for r in rows if any(v.startswith("@") for v in r.values()))
    return reviewers if want == "reviewers" else list(resolved.values())


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("cache")
    ap.add_argument("--history")
    ap.add_argument("--path", help="keep rows whose file:line contains this text")
    ap.add_argument("--status", help="comma-separated statuses to keep")
    ap.add_argument("--trials", action="store_true")
    ap.add_argument("--count", action="store_true")
    a = ap.parse_args()
    if not os.path.exists(a.cache) and not history_files(a.cache, a.history):
        print(f"no cache: {a.cache}", file=sys.stderr)
        return 2
    if a.count:
        print(json.dumps({
            "findings": len(collect(a.cache, a.history, "findings")),
            "trials": len(collect(a.cache, a.history, "trials")),
            "reviewers": collect(a.cache, a.history, "reviewers"),
        }))
        return 0
    rows = collect(a.cache, a.history, "trials" if a.trials else "findings")
    if a.path:
        rows = [r for r in rows if a.path in r.get("location", "")]
    if a.status:
        keep = set(a.status.split(","))
        rows = [r for r in rows if r.get("status") in keep]
    for r in rows:
        print(json.dumps(r, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
