---
name: ticktick-health
description: Assess the overall state of the TickTick system and produce a maintenance plan.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Pull `project list --json` and `task filter --status 0 --json`.
2. Compute and tabulate: Inbox count, unscheduled count and share, vague-title share (no verb or unclear object), overdue count and oldest overdue, tasks per list, tasks untouched 30+ days.
3. Answer in order: biggest risk right now, areas needing most attention, tasks to prioritise, tasks to delete.
4. End with a maintenance plan: concrete routines with cadence, naming the matching skills (`ticktick-inbox`, `ticktick-plan-day`, `ticktick-backlog`).

Read-only. Recommend, then let the user run the relevant routine.
