# How to sweep a suite

1. **Survey. Change nothing.** List the test files. Count the tests in each
   file. Search for the signals of each group.
2. **Report what you find.** Some suites hold very few tests in three of the
   five groups. Tell the operator this. Do not make the list longer to look
   productive.
3. **Read every planned cut in the code.** A test can look like a shape test
   and then prove a real claim about your own code. Take it off the list. Say
   that you took it off.
4. **Put the proposal in tiers.** Tier 1 holds the clear cuts. Tier 2 holds the
   judgement calls. Give a count and a reason for each file. Get approval. A
   deleted test does not come back from a clean tree.
5. **Do one tier at a time.** Run the full suite and the typecheck. Both must
   pass. Then commit that tier. One commit per tier lets the operator revert
   one tier alone.
6. **List the coverage that a group (c) tier removed.** Offer probes. See
   `PROBES.md`.

## Errors to avoid

- **A batch script can write every file at the end.** One failure then rolls
  back the whole batch, and the log still reports success. Count the tests in
  each file and compare that count against the last commit:
  `git show HEAD:"$f" | grep -cE '^\s*(it|test)\('`. Compare the result to the
  same count on disk.
- **Many runners evaluate the body of a skipped group.** A client at group
  scope throws an error when the credentials are absent, and this breaks the
  default run. Build the client inside the test.
- **A search for existence helpers finds the wrong tests.** Most results are
  guards before a real assertion. Search instead for property-check clusters,
  for calls to the registration API, and for group names with the words wiring,
  render, or format.
- **Look for duplicate files.** A file can be an old copy of a newer file. This
  is often the better reason to cut the whole file.
- **Remove the imports that a cut leaves behind.**
