# Replace the coverage you removed

Group (c) tests mislead, but the assumptions inside them are real. Your code
depends on those assumptions. Replacement is part of the job, not a later task.

After you cut group (c):

1. List every external service that now has no shape test.
2. Report that list to the operator.
3. Offer one **probe** for each service. A probe is an integration test. An
   environment variable gates it. It calls the real service.

## Rules for a probe

- **Assert an invariant. Do not assert a value.** The probe must pass against
  any account and any dataset.
- **Log an open vocabulary. Do not assert a fixed set.** The service can add a
  new value tomorrow. An unknown value is usually correct behaviour, because
  your code marks it unknown and fails loudly. The log is the product.
- **Assert a silent vocabulary.** One case is different: an unknown value goes
  silent, and your code neither processes the record nor marks it. Assert that
  vocabulary.
- **Prefer a closure check.** Every code in the live data must resolve through
  your mapping layer. A renamed code breaks this check. You cannot write this
  check against test data, which makes it the strongest probe.
- **Log every sampling cap.** Partial coverage must not read as full coverage.
- **Schedule the probes.** Nobody runs a gated probe. Then the coverage is
  zero, and zero is worse than the test you removed.

## One decision for the operator

A file that a user gives to the tool is an artifact. It is not a live contract
that changes under you. Ask the operator whether file inputs count as external.
Do not assume the answer.
