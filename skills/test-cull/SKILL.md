---
name: test-cull
description: Sweep a test suite and remove tests that cannot fail for a reason worth acting on — existence checks, typecheck-satisfied assertions, external-payload-shape fixtures, UI and registration wiring — then restore any coverage the cull genuinely removes. Use when asked to cull, prune, thin, or de-noise a test suite, or to cut tests that do not earn their place.
---

# Test cull

Remove tests that cannot fail for a reason worth acting on, keep the ones that
pin contracts, and restore any coverage the cull genuinely removes.

## When to use

Someone asks to cull, prune, thin, or de-noise a test suite.

Not for: raising coverage, fixing failing tests, or speeding up a slow one.

## What to cull

- **a. Existence tests** — a function is exported, a key is present, a config
  loads.
- **b. Typecheck-satisfied tests** — anything a static type already guarantees.
  Property-presence clusters on a typed value are the usual form.
- **c. External-shape tests** — tests that simulate an outside service and
  assert its shape. The service can change tomorrow, the test stays green, and
  the code breaks; the test misleads. See below.
- **d. The rule: contracts, not features.** A contract is a promise your code
  makes that something depends on and that could break. Every cut and keep
  resolves here.
- **e. UI, presentation, and registration** — rendered output, layout, prose,
  element ids, and tests proving a command or route registers. Cull heavily.

## The line inside (c)

> What the service **sends** → cut. What your code **does with whatever it is
> given** → keep, even on a service-shaped fixture.

Cut: status vocabularies, envelope nesting, field names and paths, type
strings, pagination, request params. Keep: retries, backoff, pacing, signing
vectors, chunk-boundary math, dedupe keys, watermarks, timeout and abort
classification.

Three things a naive sweep gets wrong:

- **Hostile-input hardening survives.** "A malformed body degrades to unknown
  instead of crashing" asserts the *absence* of a shape assumption. These are
  full of service-shaped fixtures, so pattern matching kills them first.
- **Rewrite is a third option.** A shape test does guard your own parser. Where
  the parsing is non-trivial, reframe it as a claim about your code rather than
  deleting it.
- **A fixture generated from a published schema is not the target.** Regenerate
  it.

Display tests survive (e) when the subject is numeric exactness rather than
layout: a tiny quantity rendering as its true value and not zero is a
float-correctness claim. Cut layout and prose, keep numeric truth.

## Replace what you remove

Cutting (c) leaves a real hole — the assumptions were genuine even though the
tests were not. Enumerate every dependency now left with zero shape coverage
and offer a **probe** for each: an integration test behind an env gate that
asks the real service.

- Assert invariants, never values, so it passes against any account or dataset.
- For open vocabularies, log what you observe instead of asserting a fixed set.
  An unrecognised value is usually correct behaviour — it surfaces as unknown
  and fails loudly. The log is the deliverable.
- Assert where an unknown value would go **silent** rather than loud. A record
  neither processed nor flagged is the case worth pinning.
- The strongest shape is a **closure check**: every code in live data resolves
  through your mapping layer. That is what a rename or withdrawal breaks, and
  it cannot be written against a fixture.
- Log any sampling cap, so partial coverage never reads as full.
- Schedule them. A gated probe nobody runs is worse than the fixture it
  replaced.

Whether file inputs count as external is the operator's call — a file handed to
the tool is an artifact, not a live contract — so ask rather than assume.

## Procedure

1. **Survey read-only.** Inventory files with test counts, grep for each
   category's signals, change nothing.
2. **Report honestly.** A contract-oriented suite may have almost nothing in
   three of the five categories. Say so rather than inflating the list.
3. **Re-read every planned cut against the code** before proposing it. Shape
   assertions often turn out to be real claims about your own logic.
4. **Tier the proposal** — clear cuts, then judgement calls — with counts and
   per-file rationale. Get approval; deleting tests is not reversible.
5. **Execute one tier at a time.** Full suite plus typecheck green, then
   commit. One commit per tier, so a contested tier reverts alone.
6. **Enumerate the hole** any (c) tier left and offer probes.

## Pitfalls

- **A batch script that writes only after processing every target rolls the
  whole batch back on one miss.** Verify per-file counts against the last
  commit rather than the script's log — `git show HEAD:"$f" | grep -cE
  '^\s*(it|test)\('` against the same count on disk.
- **A skipped group still evaluates its body in many runners.** Anything built
  at group scope that throws on missing credentials breaks the default ungated
  run. Construct lazily inside the test.
- **Grepping for existence helpers is a bad detector** — most hits are
  narrowing guards before a real assertion. Better signals: property-assertion
  clusters, registration-API calls, and group names matching wiring, render, or
  format.
- **Watch for stale duplicate files** — often the better reason for a
  whole-file cut.
- **Clean up unused imports** left behind by surgical cuts.

## Boundaries

**Will:** survey read-only; classify against the taxonomy; propose tiered cuts
with counts; execute approved tiers behind a green gate, one commit each; write
gated probes.

**Will not:** delete without approval; cut a fixture-heavy test without reading
what it claims; assert a closed vocabulary where unknowns already fail loudly;
report a cut done without verifying the count delta.

Project specifics — test command, layout, which inputs count as external —
belong to the caller.
