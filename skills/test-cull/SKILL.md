---
name: test-cull
description: Find and remove tests that cannot fail for a reason worth acting on — existence checks, typecheck-satisfied assertions, external service shape tests, and interface or registration tests. Use when someone asks to cull, prune, thin, or de-noise a test suite, or to remove tests that do not earn their place.
---

# Test cull

A test earns its place if it can fail for a reason you must act on. Cut every
test that cannot. Keep every test that holds a contract.

## What to cull

Cut a test in these four groups.

**a. Existence tests.** The test shows that a thing is present. It does not
show that the thing works. Examples: a function is exported; a key is present;
a config file loads.

**b. Typecheck tests.** A static type already gives this guarantee. Look for
many property checks on one typed value.

**c. External shape tests.** The test copies an outside service, then asserts
the shape of the data from that service. The service can change the shape
tomorrow. The test stays green and the code breaks. Read the next section
before you cut here.

**e. Interface and registration tests.** The test asserts rendered output,
layout, prose, or an element id. Or it asserts that a command or a route
registers. Cut most of these.

Keep a test in this group.

**d. Contract tests.** A contract is a promise your code makes. Something else
depends on that promise, and the promise can break. This rule decides every cut
and every keep.

## How to cut group (c)

Apply this test to each one:

- The test asserts what the service **sends**. Cut it.
- The test asserts what your code **does** with the data. Keep it. This holds
  also when the test data has the shape of the service.

Cut these: status codes, envelope structure, field names, field paths, type
strings, pagination, request parameters.

Keep these: retries, backoff, pacing, signature vectors, chunk-boundary math,
dedupe keys, watermarks, timeout and abort classification.

## Three tests that look like group (c) and stay

1. **Hardening tests.** Example: a malformed body becomes `unknown` and does
   not crash the code. The test shows the absence of a shape assumption. A
   simple text search removes these first, so read each one before you cut it.
2. **Parser tests with real logic.** The test guards your parser. Do not delete
   it. Write it again as a statement about your code.
3. **Generated fixtures.** A schema makes the test data. Make the data again
   from the schema. Do not cut the test.

## One test that looks like group (e) and stays

The test asserts a number, not a layout. Example: a very small quantity shows
its true value, and not zero. This test shows that the math is correct. Cut the
layout tests. Keep the number tests.

## More

- Cut group (c) and you remove real coverage. `PROBES.md` tells you how to
  replace it.
- `PROCEDURE.md` gives the steps for a sweep, and the errors to avoid.
