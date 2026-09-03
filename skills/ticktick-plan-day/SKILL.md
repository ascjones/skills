---
name: ticktick-plan-day
description: Plan today from scheduled tasks, overdue items, and the Inbox.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Compute today's window in the user's time zone, converted to UTC.
2. Pull all open tasks: `task filter --status 0 --json`. Split into: due today, overdue, undated Inbox items, everything else.
3. Ask the user for calendar commitments and available hours if not already given this session.
4. Rank by priority, deadline, and value. Estimate each candidate's duration.
5. Build a schedule that fits the available hours with buffer between blocks.
6. Present: ① today's key tasks ② tasks to postpone or drop ③ the timed schedule ④ notes for the day.
7. Ask before mutating. On confirmation set due dates via `task update` and move postponed items.
