---
name: ticktick-goal-review
description: Review progress toward a goal from completed TickTick tasks and habits.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Ask for the goal, and the list, tag, or habit that tracks it, if not given. Default period: this calendar year.
2. Pull completions: `task completed --projects <pid> --start-date <iso> --end-date <iso> --json`, and `habit list --json` for a habit. Filter by tag or keyword when the goal is not a whole list.
3. Bucket completions by month. Identify streaks and gaps.
4. Present: 1. goal progress summary 2. monthly trend table 3. consistency analysis 4. suggestions for staying on track.

Read-only.
