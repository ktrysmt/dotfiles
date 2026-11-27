#!/bin/sh
# Write the change a pull request itself made between two reviewed states,
# leaving out whatever the base branch brought in, and print its size.
#
# Usage: pr_interdiff.sh OLD_BASE OLD_HEAD NEW_BASE NEW_HEAD OUT_PATCH
#   OLD_BASE, NEW_BASE: the merge-base of the base branch and OLD_HEAD / NEW_HEAD.
# Run it inside the repository.
#
# When the merge-base did not move, this is `git diff OLD_HEAD NEW_HEAD`.
# When it moved (the author merged or rebased onto the base branch), the
# earlier PR change is first replayed onto NEW_BASE with
# `git merge-tree --write-tree --merge-base=OLD_BASE NEW_BASE OLD_HEAD`, and the
# result is compared with NEW_HEAD. merge-tree writes tree objects to the object
# store only: no commit, no ref, no working tree change.
# <https://git-scm.com/docs/git-merge-tree>
#
# Prints: mode=<incremental|interdiff> lines=<added+deleted> files=<n>
# Exit: 0 written; 2 a commit is missing locally; 3 the earlier PR change
# conflicts with NEW_BASE, so no PR-only diff exists; 4 merge-tree failed.
set -u
old_base=$1
old_head=$2
new_base=$3
new_head=$4
out=$5

for c in "$old_base" "$old_head" "$new_base" "$new_head"; do
  if ! git cat-file -e "$c^{commit}" 2>/dev/null; then
    echo "missing=$c"
    exit 2
  fi
done

if [ "$old_base" = "$new_base" ]; then
  from=$old_head
  mode=incremental
else
  git merge-tree --write-tree --merge-base="$old_base" "$new_base" "$old_head" > "$out.merge-tree" 2>&1
  st=$?
  if [ "$st" -eq 1 ]; then
    echo "conflict: see $out.merge-tree"
    exit 3
  fi
  if [ "$st" -ne 0 ]; then
    echo "merge-tree exit=$st: see $out.merge-tree"
    exit 4
  fi
  from=$(head -n 1 "$out.merge-tree")
  mode=interdiff
fi

git diff "$from" "$new_head" > "$out"
git diff --numstat "$from" "$new_head" |
  awk -v mode="$mode" '{ a += ($1 == "-" ? 0 : $1) + ($2 == "-" ? 0 : $2); f++ }
    END { printf "mode=%s lines=%d files=%d\n", mode, a, f }'
