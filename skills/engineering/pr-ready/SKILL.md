---
name: pr-ready
description: Prepares the current branch into a clean, reviewable pull request. Use when the user says "open a PR", "make this PR-ready", "prepare a pull request", "clean up my commits", or is about to push for review. Produces conventional commits, a self-review, and a PR description.
---

# PR Ready

Turn a working-but-messy branch into something a busy senior reviewer can approve quickly. A good PR is small, tells a story through its commits, and reviews itself before a human has to.

## Step 1 — Survey the branch

Run and read the output before doing anything:

```bash
git status
git diff --stat $(git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main)..HEAD
git log --oneline $(git merge-base HEAD main)..HEAD
```

Identify the base branch (`main`/`master`/`develop`), the files touched, and the current commit history. If the diff is large (> ~400 lines of meaningful change), flag it to the user and suggest splitting into multiple PRs before proceeding.

## Step 2 — Self-review the diff

Read the *entire* diff as if you were the reviewer. Look for:

- Debug leftovers: `console.log`, `dbg!`, `print`, commented-out code, `TODO`/`FIXME` added in this branch.
- Secrets or credentials accidentally staged.
- Tests: does new behavior have tests? Does the suite pass? Run it.
- Scope creep: changes unrelated to the stated goal. Call them out.

List every issue you find and fix the mechanical ones. Surface judgment calls to the user.

## Step 3 — Shape the commits

Rewrite history into a clean, logical sequence using **Conventional Commits**:

```
<type>(<scope>): <imperative summary>

<body: what & why, not how>
```

Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`, `perf`, `build`, `ci`.

- One concern per commit. A reviewer should be able to read commits top to bottom and understand the change.
- Summary line ≤ 72 chars, imperative mood ("add", not "added").
- Use `git rebase -i` (or reset + recommit) to reorganize. **Confirm with the user before rewriting any already-pushed history.**

## Step 4 — Write the PR description

Produce this template, filled in:

```markdown
## What
<one-paragraph summary of the change>

## Why
<the problem / motivation / ticket link>

## How
<key decisions a reviewer should understand>

## Testing
<what you ran; how to verify locally>

## Risk
<blast radius, rollback plan, anything to watch in prod>
```

Keep it honest — note known gaps or follow-ups rather than hiding them.

## Step 5 — Final gate

Before declaring PR-ready, confirm: suite green, lint clean, no secrets, commits conventional, description complete. Report the checklist result. Do **not** push or run `gh pr create` unless the user explicitly asks.
