#!/usr/bin/env bash
# Convenience wrapper: runs the Python validator so the documented command
# `./scripts/validate-skills.sh` keeps working. The real logic lives in
# validate_skills.py (also what CI runs).
exec python3 "$(dirname "$0")/validate_skills.py"
