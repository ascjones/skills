---
name: test-cull
description: Sweep a test suite and remove tests that cannot fail for a reason worth acting on — existence checks, typecheck-satisfied assertions, external-payload-shape fixtures, UI and registration wiring — then restore any coverage the cull genuinely removes. Use when asked to cull, prune, thin, or de-noise a test suite, or to cut tests that do not earn their place.
---

# Test cull

Remove tests that **cannot fail for a reason worth acting on**, keep the tests that
pin contracts, and replace the coverage the cull genuinely removes.

A suite full of unfalsifiable tests is worse than a smaller one. It reports
confidence it has not earned, it runs on every commit, and it buries the tests
that would actually catch a regression.

## When to use

- The user asks to cull, prune, thin, trim, or de-noise a test suite.
- A suite has grown large without the failure signal growing with it.
- A refactor left behind tests that assert structure rather than behaviour.

Not for: raising coverage, fixing failing tests, or speeding up a slow suite.
Cull is about signal. It usually shortens the run too, but that is a side effect.

## What to cull

Four targets and one rule. The rule decides what survives.

**a. Existence tests.** Assert that a thing is there rather than that it does
something: a function is exported, an object has a key, a config loads.

**b. Typecheck-satisfied tests.** Assert something a static type already
guarantees. Clusters of property-presence assertions on a typed value are the
usual form.

**c. External-payload-shape tests.** Assert what some service outside your
control sends: its field names, envelope nesting, status-code vocabulary, type
strings, pagination contract, request parameter format. These describe a
contract you neither own nor can enforce. The service can change tomorrow and
every one stays green while your code breaks. This is the deepest category —
see below.

**e. UI, presentation, and registration tests.** Assert human-readable output,
element identifiers, layout, prose, or that a command or route was registered
with its framework. Cull heavily.

**d. The rule: keep tests for contracts, not features.** A contract is a
promise your code makes that something else depends on and that could
plausibly break. A feature is a thing that exists. Every survival decision
resolves to this.

## The line inside (c)

This is the load-bearing judgement, and it is easy to get wrong in both
directions.

> An assertion about **what the external service sends** → cut.
> An assertion about **what our code does with whatever it is given** → keep,
> even when a service-shaped fixture is the scaffolding it runs on.

Cut: status-code vocabularies, envelope nesting, field names and paths,
service type strings, pagination contracts, request parameter formats.

Keep: retry budgets, backoff, throttle and pacing, request signing against
known vectors, nonce serialization, chunk-boundary arithmetic, dedupe-key
construction, watermark logic, timeout and abort classification.

Three refinements, each of which a naive sweep gets wrong:

**Hostile-input hardening tests are the inverse of the target. They survive.**
A test asserting that a non-array response body degrades to a safe unknown
instead of crashing asserts the *absence* of a shape assumption. Pattern
matching kills these first, because they are full of service-shaped fixtures.
Read every fixture-heavy test for what it claims before proposing it.

**Prefer rewriting to deleting when the parsing logic is non-trivial.** A shape
test does one honest job: it guards your own parser against refactors. If the
extraction logic is real, reframe the test as a claim about your code — "the
parser pulls the amount out of this input" — rather than cutting it. Rewrite is
a third disposition alongside cut and keep, and it is often the right one.

**A fixture generated from a published schema is not the target.** If the shape
is machine-derived from a schema you regenerate, it is not a hand-written
duplicate of someone else's contract. Regenerate it; do not cut it.

Display tests survive the (e) cull when their subject is **numeric exactness**
rather than layout. A test that a very small quantity renders as its true value
and not as zero is a claim about float and exponential correctness that happens
to be observed through rendered output. Cut layout and prose; keep numeric
truth.

## Replace, do not just remove

Cutting (c) leaves a real hole. The tests were misleading, but the assumptions
they encoded are genuine and your code still depends on them. Treat replacement
as part of the job, not a follow-up.

After the cut, enumerate every external dependency now left with zero shape
coverage, report the list, and offer an opt-in **probe** for each: an
integration test behind an environment-variable gate that asks the real service.

Design rules for probes:

- **Assert invariants, never values.** "The balance parses as an exact decimal
  string", not "the balance is 0.5" — so the probe passes against any account
  or dataset.
- **For open vocabularies, log what you observe rather than asserting a fixed
  set.** When a service emits type strings, subtypes, or method names that can
  grow, an unrecognised value is usually *correct* behaviour: your code
  surfaces it as unknown and fails loudly. Asserting a closed set recreates the
  brittleness you just removed. The log is the deliverable.
- **Assert where an unknown value would go silent rather than loud.** If an
  unrecognised status means a record is neither processed nor flagged — it just
  disappears — pin that vocabulary. Silence is the thing worth a failing test.
- **Closure checks are the strongest shape.** Assert that every code appearing
  in live data resolves through your mapping layer. That is exactly what a
  renamed or withdrawn code breaks, and it cannot be written against a fixture.
- **Log any sampling cap.** If rate limits force you to walk N of M items, say
  so in the output, so partial coverage never reads as full coverage.
- **Schedule them, or accept that coverage is zero.** A gated probe nobody runs
  is worse than the fixture it replaced. Recommend a periodic CI run.

Decide explicitly whether file-format inputs count as external contracts. A
file the user hands the tool is an artifact, not a live contract that changes
underneath you — but make the operator make that call rather than assuming it.

## Procedure

1. **Survey read-only.** Inventory test files with per-file test counts, then
   grep for each category's signals. Change nothing yet.
2. **Report honestly, including when the premise does not hold.** A suite that
   is already contract-oriented may have almost nothing in two or three of the
   categories. Saying so is more useful than inflating a cull list to look
   productive. "Your suite is already fine on these axes" is a valid result.
3. **Re-read every planned cut against the actual code** before proposing it.
   A test filed as a shape assertion often turns out, on reading, to be a real
   claim about your own logic. Drop it from the list and say you did.
4. **Tier the proposal**: clear cuts separated from judgement calls, with exact
   counts and per-file rationale. Get approval before deleting. Deleting tests
   is not reversible from a clean tree.
5. **Execute one tier at a time.** Gate each tier on the full suite plus a type
   check, zero failures, then commit it. One commit per tier, so a contested
   tier can be reverted on its own.
6. **Enumerate the coverage hole** left by any (c) tier and offer probes.

## Pitfalls

- **A batch-edit script that writes only after processing every target rolls
  the whole batch back on a single miss.** Verify per-file test-count deltas
  against the previous commit rather than trusting the script's own log:
  `was=$(git show HEAD:"$f" | grep -cE '^\s*(it|test)\(' ); now=$(grep -cE '^\s*(it|test)\(' "$f")`
  Adjust the pattern to the framework's test function.
- **A skipped test group still evaluates its body in many runners.** Anything
  constructed at group scope that throws on missing credentials will crash the
  default ungated run — which is the state every normal run is in. Construct
  clients lazily inside the test, or through a memoised getter.
- **Grepping for existence-assertion helpers is a bad detector.** Most hits are
  narrowing guards before a real assertion. Better signals: property-assertion
  clusters for (b), calls into the framework's registration API for command and
  route wiring, and group names matching wiring, render, or format for (e).
- **Watch for stale duplicate files.** A whole-file cut is sometimes justified
  as much by being a near-duplicate of a newer file as by its category.
- **Clean up unused imports after surgical cuts.** A project without strict
  unused-local checking will not fail the build on these.

## Boundaries

**Will:** survey a suite read-only; classify tests against the taxonomy;
propose tiered cuts with counts and rationale; execute approved tiers with a
green gate and one commit each; enumerate lost coverage and write gated probes.

**Will not:** delete tests without explicit approval of a tiered proposal; cut
a fixture-heavy test without reading what it claims; assert a closed vocabulary
in a probe where an unknown value already fails loudly; report a cut as done
without verifying the file's test-count delta.

A caller may layer project-specific conventions on top of this skill — test
command, gate command, directory layout, which inputs count as external.
Those belong to the caller, not here.
