---
name: tdd-loop
description: Drives a strict test-driven development loop for any new behavior or bug fix. Use when the user asks to implement a feature, add functionality, fix a bug, or says "use TDD" / "write tests first". Forbids writing production code before a failing test exists.
---

# TDD Loop

You are pairing with an engineer who wants behavior built test-first. Follow the loop below without skipping steps. Do not write production code until a test for it fails for the right reason.

## The loop

For each unit of behavior, run **Red → Green → Refactor**:

1. **Red — write one failing test.**
   - Pick the smallest next behavior. One assertion's worth of new intent.
   - Write the test before any implementation. It must describe *what* the code should do, not *how*.
   - Run the suite. Confirm the new test fails, and that it fails because the behavior is missing — not because of a typo, import error, or compile error. Read the failure message out loud (in your reasoning) and verify it's the expected one.

2. **Green — make it pass with the least code.**
   - Write the minimum production code to pass the failing test. Hardcoding a return value is acceptable at this stage if it's genuinely the simplest thing.
   - Run the full suite. All tests must pass before you continue.

3. **Refactor — clean up under green.**
   - With every test passing, improve names, remove duplication, and clarify structure.
   - Run the suite again after each change. Never refactor on a red bar.

Then repeat for the next behavior. Small loops beat big ones — aim for cycles of minutes, not hours.

## Rules

- **Never** write production code that isn't demanded by a failing test.
- **One** failing test at a time. Don't write five tests then implement.
- If a test is hard to write, that's a design signal — the unit under test is probably doing too much. Pause and tell the user before forcing it.
- Don't delete or weaken a test to get green. If a test is wrong, say so explicitly and explain why before changing it.
- Keep tests fast and isolated. No network, no real clock, no shared mutable state unless the behavior under test *is* that integration.

## Detect the stack first

Before the first test, identify the test runner from the project:
- Node/TS: `vitest`, `jest`, `node:test` — check `package.json`.
- Python: `pytest`, `unittest`.
- Rust: `cargo test` (`#[cfg(test)]` modules or `tests/`).
- Go: `go test` with `_test.go` files and table-driven cases.

Use the existing convention in the repo. If none exists, propose one and wait for confirmation.

## Output discipline

At each step state which phase you're in (RED / GREEN / REFACTOR), show the test or diff, and report the suite result. End the task only when the suite is fully green and you've offered the next behavior to drive.
