---
name: ci-pipeline
description: Scaffolds a GitHub Actions CI pipeline tailored to the project's stack. Use when the user says "add CI", "set up GitHub Actions", "add a pipeline", "automate tests on push", or wants lint/test/build to run on every PR. Produces a cached, matrix-aware workflow.
---

# CI Pipeline

Generate a GitHub Actions workflow that runs the right checks on every push and PR, with dependency caching so it stays fast. A green check on the PR should mean "safe to merge."

## Step 1 — Detect stack and existing tooling

Determine the language, package manager, and the actual lint/test/build commands the repo already uses (read `package.json` scripts, `Makefile`, `justfile`, `Cargo.toml`, `pyproject.toml`, `go.mod`). Reuse existing commands — don't invent new ones.

## Step 2 — Write `.github/workflows/ci.yml`

Structure every pipeline as ordered jobs that fail fast:

1. **lint** — formatter + linter in check mode (`prettier --check`, `eslint`, `ruff`, `cargo fmt --check` + `cargo clippy -- -D warnings`, `gofmt`/`golangci-lint`).
2. **test** — the project's test command, with the suite required to pass.
3. **build** — compile / bundle to prove the artifact is producible.

Apply these rules:

- Trigger on `push` to the default branch and on `pull_request`.
- **Cache dependencies** with the official cache (e.g. `actions/setup-node` with `cache:`, `Swatinem/rust-cache`, `actions/setup-go` cache, pip cache).
- **Pin action versions** to a major tag (`actions/checkout@v4`), never a floating branch.
- Set `permissions:` to least privilege (`contents: read` by default).
- Add `concurrency:` to cancel superseded runs on the same ref.
- Use a **matrix** only when it earns its keep (multiple language/OS versions the project actually supports).

### Reference shape (Rust)

```yaml
name: CI
on:
  push: { branches: [main] }
  pull_request:
permissions:
  contents: read
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with: { components: rustfmt, clippy }
      - uses: Swatinem/rust-cache@v2
      - run: cargo fmt --all -- --check
      - run: cargo clippy --all-targets -- -D warnings
      - run: cargo test --all
      - run: cargo build --release
```

Translate the same lint → test → build spine to whatever stack you detected.

## Step 3 — Offer extras (don't force)

Mention, but only add if the user wants them: a release workflow that builds cross-platform binaries on tag, dependency caching tuning, code coverage upload, and Dependabot config. Keep the core `ci.yml` lean.

## Step 4 — Verify

Show the final workflow and explain what each job gates. Note any secret or permission the user must add in repo settings (e.g. for release uploads). Do not commit or push unless asked.
