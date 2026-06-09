# forge-skills

[![Validate Skills](https://github.com/HM-IT-CODE/forge-skills/actions/workflows/validate-skills.yml/badge.svg)](https://github.com/HM-IT-CODE/forge-skills/actions/workflows/validate-skills.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**Battle-tested [Agent Skills](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) for full-stack & systems engineers.**

Skills that make Claude Code (and any skill-aware agent) *behave like a senior engineer on your team* — not a one-shot code generator. Straight from a working `.claude` directory: opinionated, composable, and small enough to read in 60 seconds.

> A skill is just a folder with a `SKILL.md` file. Markdown in, better engineering out. No binaries, no servers, no lock-in. Works with any model.

---

## What's inside

| Skill | Type | What it does |
|-------|------|--------------|
| [`tdd-loop`](skills/engineering/tdd-loop/SKILL.md) | Discipline | Forces a red → green → refactor loop. No production code before a failing test. |
| [`pr-ready`](skills/engineering/pr-ready/SKILL.md) | Discipline | Turns a messy branch into a reviewable PR: conventional commits, self-review, changelog. |
| [`vertical-slice`](skills/engineering/vertical-slice/SKILL.md) | Discipline | Breaks a feature into thin, shippable, end-to-end slices instead of horizontal layers. |
| [`dockerize`](skills/devops/dockerize/SKILL.md) | Capability | Generates a production-grade multi-stage `Dockerfile` + `compose` for the detected stack. |
| [`ci-pipeline`](skills/devops/ci-pipeline/SKILL.md) | Capability | Scaffolds a GitHub Actions pipeline (lint, test, build, cache) for your language. |
| [`rust-cli-scaffold`](skills/systems/rust-cli-scaffold/SKILL.md) | Capability | Bootstraps a clean Rust CLI: `clap`, error handling with `anyhow`, tests, CI. |

Half the collection enforces *good habits*; the other half gives the agent *new powers*. Mix and match.

---

## Quick start (3 steps)

```bash
# 1. Clone
git clone https://github.com/HM-IT-CODE/forge-skills.git
cd forge-skills

# 2. Link the skills into your ~/.claude/skills directory
./scripts/link-skills.sh

# 3. Use them — just ask Claude Code naturally
#    "use tdd-loop to add a rate limiter"
#    "dockerize this service for production"
```

That's it. Claude Code auto-discovers every `SKILL.md` and loads the right one when your request matches its description.

> **Prefer not to symlink?** Copy any single skill folder into your project's `.claude/skills/` directory. Each skill is self-contained.

---

## See it in action

> Replace the block below with a real GIF once you record one — a 15-second clip
> of an agent using a skill is the single biggest driver of stars.
> Record with [asciinema](https://asciinema.org) (`asciinema rec`) or any screen
> recorder, then drop the file in `docs/` and reference it here:
> `![demo](docs/demo.gif)`

Until then, here's what `tdd-loop` looks like from the driver's seat:

```text
you ›  use tdd-loop to add a function that parses "3d6+2" dice notation

claude ›  RED — writing the first failing test.
          test: parse("3d6+2") returns { count: 3, sides: 6, modifier: 2 }
          $ cargo test
          ✗ FAILED — function `parse` does not exist   ← expected failure

          GREEN — minimum code to pass.
          + pub fn parse(s: &str) -> Dice { ... }
          $ cargo test
          ✓ 1 passed

          REFACTOR — extracting the regex, naming the captures.
          $ cargo test
          ✓ 1 passed

          Next behavior to drive: reject malformed input like "3x6"?
```

One failing test at a time, never production code before red. That's the whole
point — the skill makes the agent *behave*, not just *produce*.

---

## Why this exists

Coding agents fail in predictable ways: they skip tests, write code top-to-bottom instead of slice-by-slice, and produce PRs no human wants to review. These skills encode the **engineering motions** that fix those failure modes — the same ones a good senior would insist on.

The bet is simple: the bottleneck in agentic coding isn't speed, it's *judgment*. A 40-line markdown file that makes the agent write a failing test first beats any amount of raw horsepower.

---

## Architecture

```
forge-skills/
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── .github/
│   └── workflows/
│       └── validate-skills.yml # CI: lints every SKILL.md on push & PR
├── scripts/
│   ├── link-skills.sh          # symlink every skill into ~/.claude/skills
│   └── validate-skills.sh      # frontmatter validator (also run by CI)
└── skills/
    ├── engineering/            # discipline: how to work
    │   ├── tdd-loop/
    │   ├── pr-ready/
    │   └── vertical-slice/
    ├── devops/                 # capability: ship it
    │   ├── dockerize/
    │   └── ci-pipeline/
    └── systems/                # capability: low-level
        └── rust-cli-scaffold/
```

Every skill is a directory containing a single `SKILL.md` with YAML frontmatter (`name`, `description`) plus the instructions. Add a new one by dropping in a folder — that's the whole extension model.

---

## Contributing

Forks and PRs welcome. To add a skill:

1. Create `skills/<category>/<your-skill>/SKILL.md`.
2. Give it a tight `description` — that one line is what the agent matches against, so make it specific.
3. Keep it short, single-purpose, and model-agnostic.
4. Open a PR.

The best skills are sharp and composable: one job, done the way a senior would do it.

---

## License

MIT — see [LICENSE](LICENSE). Use it, fork it, ship it.
