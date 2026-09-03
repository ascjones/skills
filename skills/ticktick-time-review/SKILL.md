---
name: ticktick-time-review
description: Analyse where time went this month from completed TickTick tasks by list and tag.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Default period: current calendar month in the user's time zone. Resolve list ids from `project list --json`.
2. Pull completed tasks per list for the window with `task completed --projects <pid> ...`. Use Pomodoro or duration fields when present; otherwise count tasks.
3. Group by list, then by work versus personal. Ask which lists count as work when it is not obvious from the names.
4. Present: 1. allocation table 2. top focus areas 3. notable observations, including areas that got less attention than expected 4. suggestions for balance next month.

Read-only.
