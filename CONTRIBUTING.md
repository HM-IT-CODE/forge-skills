# Contributing to forge-skills

Thanks for wanting to add a skill. The bar is simple: **small, sharp, single-purpose, and model-agnostic.** A skill should do one thing the way a senior engineer would do it.

## Add a skill in 4 steps

1. **Create the folder**

   ```
   skills/<category>/<your-skill>/SKILL.md
   ```

   Categories so far: `engineering` (discipline), `devops` and `systems` (capability). Add a new category folder if yours genuinely doesn't fit.

2. **Write the frontmatter** — this is the most important part. The `description` is the single line the agent matches against to decide whether to load your skill, so make it specific and trigger-rich.

   ```yaml
   ---
   name: your-skill
   description: One sentence on what it does + when to use it. Include the phrases a user would actually say ("dockerize", "add CI", "write tests first") so the agent matches reliably.
   ---
   ```

   Rules the validator enforces:
   - File starts with `---` on line 1.
   - `name:` is present, lowercase, kebab-case, and **matches the folder name**.
   - `description:` is present and between 20 and 500 characters.

3. **Write the instructions.** Below the frontmatter, tell the agent *how* to do the job — concrete steps, rules, and the anti-patterns to refuse. Keep it short enough to read in a minute. Prefer imperative, checkable steps over prose. Reference other skills by name when handing off (e.g. "hand off to `tdd-loop`").

4. **Validate, then open a PR.**

   ```bash
   ./scripts/validate-skills.sh
   ```

   CI runs the same check on every PR. Green check = structurally sound.

## What makes a *good* skill

- **One job.** If you're writing "and" in the description, it's probably two skills.
- **Composable.** Skills should hand off to each other, not duplicate each other.
- **Opinionated.** Encode a real engineering decision. "It depends" is not a skill.
- **Model-agnostic.** No reliance on a specific model's quirks.
- **No required infra.** A skill is markdown + maybe a local script. If it needs a server, a database, or an embeddings pipeline, that's a separate tool — not a skill.

## What we'll send back

PRs get bounced if the skill is vague, overlaps an existing one without improving it, requires heavy external setup, or has a generic description that won't trigger reliably. Don't take it personally — tighten and resubmit.
