---
name: ticktick-backlog
description: Review stale and long-overdue TickTick tasks and decide keep, break down, defer, or delete.
disable-model-invocation: true
---

Load the `ticktick` skill for commands, IDs, and conventions.

1. Pull all open tasks: `task filter --status 0 --json`.
2. Flag stale candidates: `modifiedTime` older than 30 days, due date more than 30 days past, or `createdTime` older than 90 days with no date.
3. For each candidate recommend one of keep, break down, defer, delete, with a one-line reason. "Break down" includes the proposed subtasks.
4. Present three numbered tables: ① keep ② break down ③ delete, plus a defer table if any. Every candidate appears once.
5. Ask which groups to apply. Break down by creating sibling tasks with `task create` in the same list, then completing the original. Deletion always gets a per-task confirmation; prefer `task complete` when the item is effectively done.
