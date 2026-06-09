---
name: vertical-slice
description: Breaks a feature into thin, end-to-end vertical slices that each ship independently. Use when the user describes a large feature, says "where do I start", "break this down", "plan this feature", or is tempted to build layer-by-layer (all the DB, then all the API, then all the UI). Produces an ordered list of shippable slices.
---

# Vertical Slice

Big features die in horizontal layers: you build the whole database, then the whole API, then the whole UI, and nothing works until the very end. Instead, cut **vertical slices** — each one goes through every layer and delivers a sliver of real, demonstrable value.

## What a good slice is

A vertical slice is the **thinnest possible change that is end-to-end and observable**. It touches whatever layers it needs (storage → logic → interface) but does the minimum in each.

- **Thin:** does one concrete thing a user or caller can see.
- **End-to-end:** runs all the way through the system, even if hardcoded in places.
- **Shippable:** could be merged and deployed on its own without breaking anything.
- **Ordered by value + risk:** the first slice should retire the biggest unknown.

## Method

1. **Restate the feature** in one sentence as an outcome, not a component list.
2. **Find the walking skeleton** — the smallest path that exercises every layer end-to-end, even with fake data. That's slice #1.
3. **Enumerate slices** that each add one increment of real behavior on top. For each slice write:
   - *Title* (imperative, user-facing where possible)
   - *Demo* — the one sentence you'd say to show it works ("now an empty list returns `[]` over HTTP")
   - *Layers touched*
   - *Explicitly out of scope* for this slice
4. **Order them** so the riskiest assumption is tested first and each slice leaves the system shippable.
5. **Stop and present the plan** before writing code. Let the user approve or reorder.

## Anti-patterns to refuse

- "First I'll build all the models." → No. That's a horizontal layer with no demo.
- A slice whose only demo is "the code compiles." → Not a slice; it's plumbing. Fold it into a slice that produces visible behavior.
- A slice that can't ship without three other slices. → Too thick or wrongly ordered.

## Output

Deliver a numbered list of slices, each with title / demo / layers / out-of-scope, plus a one-line note on which unknown slice #1 retires. Then ask which slice to build first — and hand off to `tdd-loop` to build it.
