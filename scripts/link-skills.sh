#!/usr/bin/env bash
# link-skills.sh — symlink every skill in this repo into ~/.claude/skills
#
# Each skill is a directory containing a SKILL.md. This script finds them all
# and creates a symlink for each in your global Claude skills directory, so
# Claude Code (and any skill-aware agent) auto-discovers them.
#
# Usage:
#   ./scripts/link-skills.sh           # link into ~/.claude/skills
#   CLAUDE_SKILLS_DIR=/path ./scripts/link-skills.sh   # custom target
#
# Re-running is safe: existing links are refreshed.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="$REPO_ROOT/skills"
TARGET_DIR="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "error: skills directory not found at $SKILLS_SRC" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

linked=0
# Find every directory that directly contains a SKILL.md
while IFS= read -r -d '' skill_md; do
  skill_dir="$(dirname "$skill_md")"
  skill_name="$(basename "$skill_dir")"
  link_path="$TARGET_DIR/$skill_name"

  # Refresh any existing link/dir of the same name
  if [[ -L "$link_path" || -e "$link_path" ]]; then
    rm -rf "$link_path"
  fi

  ln -s "$skill_dir" "$link_path"
  echo "linked  $skill_name  ->  $link_path"
  linked=$((linked + 1))
done < <(find "$SKILLS_SRC" -name SKILL.md -type f -print0)

echo ""
echo "Done. Linked $linked skill(s) into $TARGET_DIR"
echo "Restart Claude Code (or your agent) so it picks up the new skills."
