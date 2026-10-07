---
name: herdr-chef
description: Make one agent session the "chef" — the coordinator for a repo — by naming its herdr agent `<project>-chef` and renaming its Claude Code or Codex session to match. Renames an existing session, or starts a new one on the repo's main checkout. Use when the user asks to make a session the chef, set up a chef for a repo, or rename the coordinator session.
argument-hint: "[this | <pane-or-agent> | new] [repo path] [kind:codex]"
---

# herdr-chef

A chef is the one coordinator session for a repo. It runs in the main checkout
on the default branch, and its herdr agent is named `<project>-chef`. A repo
has at most one chef.

Requires herdr (`HERDR_ENV=1`).

## 1. Find the target and the repo

- **Rename existing** (the default): the target is this pane,
  `$HERDR_PANE_ID`, or the pane or agent name that the user gives. The target
  must be a detected agent, not a plain shell.
- **Create new**: the user says "new". The repo is the path given, else the
  repo of this pane.

`herdr agent list` prints JSON. Each agent has `pane_id`, `name`, `agent`
(`claude` or `codex`), and `cwd`. `herdr agent get <pane>` shows one agent.

Get the repo root and the project name from the target `cwd`, or from the
given path for "new":

```bash
root=$(dirname "$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)")
project=$(basename "$root")
```

The chef name is `${project}-chef`. Lowercase it, and replace characters
outside `[a-z0-9_-]` with `-`: herdr agent names must match
`[a-z][a-z0-9_-]{0,31}`.

## 2. Check the rules

Stop and report to the user if a rule fails.

1. **Main checkout, not a worktree.** For a rename,
   `git -C "$cwd" rev-parse --path-format=absolute --git-dir` must equal the
   `--git-common-dir`. A new chef starts at `$root`, so this rule holds.
2. **Default branch.** `git -C "$root" branch --show-current` must equal the
   default branch: `git -C "$root" symbolic-ref --short refs/remotes/origin/HEAD`
   without `origin/`, or `main` if that command fails.
3. **One chef per repo.** No agent in `herdr agent list` other than the target
   may have the `name` `${project}-chef`. If one exists, report its `pane_id`
   and stop. If the target already has the name, skip the herdr rename and do
   the session rename.

## 3a. Rename existing

```bash
herdr agent rename <TARGET> ${project}-chef
herdr agent prompt <TARGET> "/rename ${project}-chef"
```

Send `/rename` without `--wait`: it does not start a turn.

- **Claude Code**: `/rename` takes the name inline and runs at once, also
  during a turn, so it works when the target is this pane.
- **Codex**: `/rename` renames the thread, but it can open a "Name thread"
  input instead of using the inline name. Read the pane with
  `herdr agent read <TARGET> --source recent --lines 20`. If the input is open,
  send the name: `herdr agent prompt <TARGET> "${project}-chef"`.

## 3b. Create new

```bash
herdr worktree list --cwd "$root" --json     # result.source.source_workspace_id -> SRC
herdr tab create --workspace <SRC> --cwd "$root" --label "${project}-chef" --no-focus
                                             # result.root_pane.pane_id -> PANE
herdr agent start ${project}-chef --kind claude --pane <PANE> --timeout 60000 -- --name ${project}-chef
```

`agent start` names the herdr agent. `--name` names the Claude Code session at
launch. For Codex, use `--kind codex`, remove `-- --name …`, and rename the
session as in 3a.

## 4. Verify and report

`herdr agent get <TARGET>` must show `name` as `${project}-chef`. For Claude
Code, `terminal_title_stripped` also shows the session name. Report the chef
name, the pane, and the repo.
