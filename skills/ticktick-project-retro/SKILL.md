---
name: ticktick-project-retro
description: Summarise a TickTick project's completed work, remaining work, and next steps.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Ask for the project list and period if not given. Default period: last three months. Resolve the list id from `project list --json`.
2. Pull completed tasks in the window with `task completed --projects <pid> ...` and open tasks with `task filter --status 0 --projects <pid> --json`. Verify an empty result with `project data <pid> --json`.
3. Identify milestones, the areas with most completions, and tasks that were rescheduled or are overdue.
4. Present: 1. project summary 2. key accomplishments 3. outstanding work 4. recommended next steps.

Read-only.
