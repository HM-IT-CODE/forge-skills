#!/usr/bin/env python3
"""Structural validator for every SKILL.md in the repo.

Checks, per skill:
  1. File begins with a YAML frontmatter delimiter (`---` on the first line).
  2. The frontmatter block is closed with a second `---`.
  3. `name:` is present, kebab-case, and matches the parent folder name.
  4. `description:` is present and at least 20 characters.

Pure standard library, no dependencies. Exits non-zero if any skill fails,
so it doubles as a CI gate.
"""

from __future__ import annotations

import sys
from pathlib import Path
import re

NAME_RE = re.compile(r"^[a-z0-9]+(?:-[a-z0-9]+)*$")
MIN_DESC = 20
MAX_DESC = 1024


def parse_frontmatter(text: str):
    """Return (fields, error) where fields is a dict of the YAML-ish frontmatter."""
    # Normalize line endings so CRLF checkouts don't break us.
    lines = text.replace("\r\n", "\n").replace("\r", "\n").split("\n")

    if not lines or lines[0].strip() != "---":
        return None, "frontmatter must start with '---' on line 1"

    # Find the closing delimiter.
    close_idx = None
    for i in range(1, len(lines)):
        if lines[i].strip() == "---":
            close_idx = i
            break
    if close_idx is None:
        return None, "frontmatter is not closed with a second '---'"

    fields: dict[str, str] = {}
    for line in lines[1:close_idx]:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if ":" not in line:
            continue
        key, _, value = line.partition(":")
        fields[key.strip()] = value.strip().strip('"').strip("'")
    return fields, None


def validate(skill_md: Path, repo_root: Path):
    problems: list[str] = []
    folder = skill_md.parent.name

    fields, err = parse_frontmatter(skill_md.read_text(encoding="utf-8"))
    if err:
        return [err]

    name = fields.get("name", "")
    if not name:
        problems.append("missing 'name:' field")
    else:
        if not NAME_RE.match(name):
            problems.append(f"name '{name}' is not kebab-case")
        if name != folder:
            problems.append(f"name '{name}' does not match folder '{folder}'")

    desc = fields.get("description", "")
    if not desc:
        problems.append("missing 'description:' field")
    else:
        n = len(desc)
        if n < MIN_DESC:
            problems.append(f"description too short ({n} chars; min {MIN_DESC})")
        if n > MAX_DESC:
            problems.append(f"description too long ({n} chars; max {MAX_DESC})")

    return problems


def main() -> int:
    repo_root = Path(__file__).resolve().parent.parent
    skills_dir = repo_root / "skills"

    if not skills_dir.is_dir():
        print(f"error: no skills/ directory at {skills_dir}", file=sys.stderr)
        return 1

    skill_files = sorted(skills_dir.rglob("SKILL.md"))
    if not skill_files:
        print("error: no SKILL.md files found under skills/", file=sys.stderr)
        return 1

    errors = 0
    for f in skill_files:
        rel = f.relative_to(repo_root)
        problems = validate(f, repo_root)
        if problems:
            print(f"FAIL  {rel}")
            for p in problems:
                print(f"        - {p}")
            errors += 1
        else:
            print(f"OK    {rel}")

    print()
    if errors:
        print(f"{errors} of {len(skill_files)} skill(s) failed validation.")
        return 1
    print(f"All {len(skill_files)} skill(s) valid.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
