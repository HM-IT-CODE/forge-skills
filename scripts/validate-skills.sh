#!/usr/bin/env bash
# validate-skills.sh — structural validation for every SKILL.md in the repo.
#
# Checks, per skill:
#   1. File begins with a YAML frontmatter delimiter (--- on line 1).
#   2. Frontmatter is closed with a second --- .
#   3. `name:` is present, kebab-case, and matches the parent folder name.
#   4. `description:` is present and 20–500 characters.
#
# No dependencies beyond coreutils + bash. Exit code is non-zero if any skill
# fails, so it doubles as a CI gate.
#
# Usage:  ./scripts/validate-skills.sh

set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

red()   { printf '\033[31m%s\033[0m\n' "$1"; }
green() { printf '\033[32m%s\033[0m\n' "$1"; }

errors=0
count=0

if [[ ! -d "$SKILLS_DIR" ]]; then
  red "error: no skills/ directory at $SKILLS_DIR"
  exit 1
fi

while IFS= read -r -d '' f; do
  count=$((count + 1))
  dir="$(dirname "$f")"
  folder="$(basename "$dir")"
  problems=()

  # 1. line 1 must be ---
  if [[ "$(sed -n '1p' "$f")" != "---" ]]; then
    problems+=("frontmatter must start with '---' on line 1")
  fi

  # 2. closing --- must exist (a second --- within the first ~40 lines)
  if ! sed -n '2,40p' "$f" | grep -qx -- "---"; then
    problems+=("frontmatter is not closed with a second '---'")
  fi

  # extract the frontmatter block (between the first two --- lines)
  fm="$(awk 'NR==1 && $0=="---"{f=1;next} f && $0=="---"{exit} f{print}' "$f")"

  # 3. name present, kebab-case, matches folder
  name="$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '"'"'"' \r')"
  if [[ -z "$name" ]]; then
    problems+=("missing 'name:' field")
  else
    if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
      problems+=("name '$name' is not kebab-case")
    fi
    if [[ "$name" != "$folder" ]]; then
      problems+=("name '$name' does not match folder '$folder'")
    fi
  fi

  # 4. description present, 20–500 chars
  desc="$(printf '%s\n' "$fm" | sed -n 's/^description:[[:space:]]*//p' | head -1)"
  if [[ -z "$desc" ]]; then
    problems+=("missing 'description:' field")
  else
    dlen=${#desc}
    if (( dlen < 20 )); then problems+=("description too short ($dlen chars; min 20)"); fi
    if (( dlen > 500 )); then problems+=("description too long ($dlen chars; max 500)"); fi
  fi

  rel="${f#"$REPO_ROOT"/}"
  if (( ${#problems[@]} == 0 )); then
    green "OK    $rel"
  else
    red "FAIL  $rel"
    for p in "${problems[@]}"; do echo "        - $p"; done
    errors=$((errors + 1))
  fi
done < <(find "$SKILLS_DIR" -name SKILL.md -type f -print0 | sort -z)

echo ""
if (( errors > 0 )); then
  red "$errors of $count skill(s) failed validation."
  exit 1
fi
green "All $count skill(s) valid."
