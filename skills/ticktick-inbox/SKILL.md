---
name: ticktick-inbox
description: Triage the TickTick Inbox into lists, tags, priorities, schedules, and deletions.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Pull every open Inbox task: `task filter --status 0 --projects <inbox id> --json`. Note `createdTime` and `modifiedTime` to spot recently added and long-neglected items.
2. Pull `project list --json` so recommendations name real lists.
3. For every task, decide:
   - **Vague?** Rewrite as a concrete next action.
   - **Home**: which list, which tags, which priority (0/1/3/5).
   - **Schedule**: high priority or a real deadline gets a date today or this week; no timeline stays in Inbox.
   - **Neglected** (untouched 30+ days): keep, defer, or delete.
4. Present four numbered tables: ① revise ② move ③ schedule ④ delete. Every Inbox task appears in exactly one table or an explicit "leave as is" line.
5. Ask which groups to apply. Apply only what the user confirms, using `task update`, `task move`, `task complete`. Deletion always gets a per-task confirmation.
