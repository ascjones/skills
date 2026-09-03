---
name: ticktick
description: Manage TickTick tasks, lists, and habits from the terminal via the official `ticktick` CLI. Use when asked to add, list, complete, move, or search tasks, or check habits.
---

# TickTick CLI

Official `@ticktick/ticktick-cli` (Open API v1). If a command says unauthorised, ask the user to run `! ticktick auth login`.

Always add `--json` and parse the output. Never print or log the token.

## IDs

Get list IDs, including the Inbox id, from `ticktick project list --json`. Task commands need both `<projectId>` and `<taskId>`.

## Common commands

```bash
ticktick project list --json                                   # all lists
ticktick task filter --status 0 --json                         # all open tasks
ticktick task filter --status 0 --projects <pid> --json        # open tasks in one list
ticktick task filter --status 0 --start-date <iso> --end-date <iso> --json   # open tasks in a date window
ticktick task search "<keywords>" --status 0 --json            # keyword search
ticktick task completed --projects <pid> --start-date <iso> --end-date <iso> --json
ticktick task get <pid> <tid> --json
ticktick task create --title "..." --project <pid> [--priority 0|1|3|5] [--due-date <iso>] [--tags a,b] [--content "..."]
ticktick task update <tid> --id <tid> --project <pid> [--title ...] [--priority ...] [--due-date ...] [--tags ...]
ticktick task complete <pid> <tid>
ticktick task delete <pid> <tid>
ticktick task move --from <pid> --to <pid> --task <tid>
ticktick habit list --json
ticktick habit checkin <hid> --stamp YYYYMMDD --value 1
```

Dates are `yyyy-MM-ddTHH:mm:ss+0000` (UTC). Convert from the user's time zone.

## Known gaps

- `task search --due-from/--due-to` returned API 500 as of Sep 2026. Use `task filter --start-date/--end-date` instead.
- Filtering by project through `task filter --projects` returned empty for lists that `project data` also showed empty, so verify with `project data <pid> --json` if a result looks wrong.
- No "today" verb. Compute the UTC window for today and use `task filter`.

## Conventions

- Priority: 0 none, 1 low, 3 medium, 5 high.
- Deleting is destructive. Confirm with the user first. Prefer `complete`.

## Routines

User-invoked skills built on this one: `ticktick-inbox` (triage), `ticktick-plan-day`, `ticktick-backlog` (stale cleanup), `ticktick-health` (system check), `ticktick-goal-review`, `ticktick-project-retro`, `ticktick-time-review`, `ticktick-reflect`. Source prompts: https://help.ticktick.com/articles/7475477082185662464
