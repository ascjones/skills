---
name: test-audit
description: Gate new tests, and find and remove tests that cannot fail for a reason worth acting on — existence checks, typecheck-satisfied assertions, external service shape tests, interface and registration tests, and tests coupled to implementation. Use when adding a test, or when someone asks to audit, cull, prune, or de-noise a test suite.
---

# Test audit

A test earns its place if it can fail for a reason you must act on. Keep every
test that holds a contract. Cut every test that cannot fail for such a reason.

## Before you add a test

Answer these four questions. If you cannot answer one, do not add the test yet.

1. Which behaviour, invariant, or contract does the test protect?
2. Which credible regression makes the test fail?
3. Why does existing coverage not catch that regression? Give each contract one
   primary test at the strongest boundary. Extend a table case or a shared
   fixture before you write a near-duplicate.
4. Does the test need a production seam — an export, flag, wrapper, or hook —
   that no production caller uses? If yes, move the test to the real boundary.

Then check the test against the cut list below.

A bug regression test must fail on the code before the fix, for the correct
reason. A regression test that never failed proves the mock, not the fix. Write
one regression test at the owning boundary, not one at each layer the bug
crosses.

## What to cut

- **Existence tests.** The test shows that a thing is present, not that it
  works: a function is exported, a key is present, a config loads.
- **Typecheck tests.** A static type already gives the guarantee. Look for many
  property checks on one typed value.
- **External shape tests.** The test copies an outside service and asserts the
  shape of its data. The service can change tomorrow, the test stays green, and
  the code breaks. Read the next section before you cut here.
- **Interface and registration tests.** The test asserts rendered output,
  layout, prose, or an element id, or that a command or route registers.
- **Implementation tests.** The test breaks when you change the structure of
  the code but not its behaviour. Examples: private call-shape checks, exact
  source or string greps, a test that keeps a test-only export alive.
- **Circular tests.** The expected value comes from the code under test, a mock
  does the work that the test asserts, or a fixture supplies the result that
  the code must produce.
- **Duplicates.** The same contract runs twice, or a local test replays a shared
  helper that has its own tests.
- **Empty tests.** The test has no assertion, compares a value with itself, or
  passes for a reason other than the one its name gives. Read the assertions,
  not the name.

When you cut a test, also delete the production seams and dead code that only
that test used.

## The line for external shape tests

- The test asserts what the service **sends**. Cut it.
- The test asserts what your code **does** with the data. Keep it. This holds
  also when the test data has the shape of the service.

Cut these: status codes, envelope structure, field names, field paths, type
strings, pagination, request parameters.

Keep these: retries, backoff, pacing, signature vectors, chunk-boundary math,
dedupe keys, watermarks, timeout and abort classification.

## What to keep

Keep a test that holds a contract. A contract is a promise your code makes that
something else depends on, and that can break: a public API, a protocol, a
config or storage format, a migration, a security rule, a default.

These tests look like the cut list, but stay:

1. **Hardening tests.** Example: a malformed body becomes `unknown` and does not
   crash the code. The test shows the absence of a shape assumption. A text
   search removes these first, so read each one before you cut it.
2. **Parser tests with real logic.** Write the test again as a statement about
   your code. Do not delete it.
3. **Generated fixtures.** A schema makes the test data. Make the data again
   from the schema.
4. **Number tests.** The test renders output but asserts a number, not a
   layout. Example: a very small quantity shows its true value, and not zero.
5. **Order tests**, when the order is behaviour that a user can see.
6. **Source checks**, when a source check is the cheapest guard on a
   user-facing key, byte, or path, and it survives a rename.

A slow or static test is not a reason to cut. A kept test that fails on the
current code can be a product bug: reproduce it and fix the code, and keep the
test.

## Credit

The authoring gate, the implementation, circular, and empty test patterns, and
the retention rules are adapted from the
[`test-audit` skill](https://github.com/openclaw/openclaw/blob/main/.agents/skills/test-audit/SKILL.md)
in openclaw/openclaw. Copyright (c) 2026 OpenClaw Foundation, MIT License.
