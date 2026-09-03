---
name: ticktick-reflect
description: Reflect on six months of completed TickTick tasks for patterns, milestones, and shifting priorities.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Default period: last six months. Resolve list ids from `project list --json`.
2. Pull completed tasks per list for the window with `task completed --projects <pid> ...`.
3. Compare the first and second halves of the period: which lists grew or shrank, what was done consistently, what standout tasks mark milestones.
4. Present: 1. personal growth summary 2. key accomplishments 3. patterns noticed 4. recommendations for the next six months.

Read-only.
