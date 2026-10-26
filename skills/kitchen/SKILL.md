---
name: kitchen
description: House rules for working the tsk board, by role. The chef coordinates a repo from its main checkout; a cook works one task in its own worktree. Load before your first `tsk` command in a session, alongside `tsk-cli`, and when the user asks to make a session the chef or set up a chef for a repo.
argument-hint: "[chef: this | <pane-or-agent> | new] [repo path] [kind:codex]"
---

# kitchen

House rules that sit on top of the tsk-owned skills (`tsk-cli`, `tsk-coordinator`). Where
they differ, these rules win.

## Your role

Compare `git rev-parse --path-format=absolute --git-dir` with `--git-common-dir`:

- **Equal**: you are in the repo's main checkout. If you coordinate the repo (a herdr agent
  named `<project>-chef`, or the user asked you to dispatch work), you are the **chef**.
- **Different**: you are in a worktree, working one task. You are a **cook**.

Read the rules for every role, then your own section.

## Every role

**Project root.** A tsk project is the main repository root, never a worktree. From a
worktree, pass the main checkout's root on every `tsk add` (`-p <root>`, or `"project"` in a
JSON plan); the default scope resolves to the worktree path and files the task under a stray
project. Find the root with
`dirname "$(git rev-parse --path-format=absolute --git-common-dir)"`.

**Notes are a brief.** The board renders basic Markdown (headings, `-` lists, bold, `code`,
fenced blocks; tables and links stay raw) and its peek shows the first five lines.

- Open with a one-sentence summary line.
- Follow with short `##` sections of bullets; keep any paragraph to three lines.
- Put history in review and block records, and checklists in steps.

**Pass multi-line notes from a file.** For multi-line notes on `tsk add`, `tsk edit --notes`,
or `--append-notes`, first write the notes to a Markdown file in your scratchpad (`mktemp`
where you have none), then pass the file's contents with the long flag and `=`:
`tsk add -t "…" --notes="$(cat "$file")"`, `tsk edit T12 --notes="$(cat "$file")"`, or
`--append-notes="$(cat "$file")"`. The file keeps line breaks, headings and lists intact, so
keep multi-line text out of the command itself. The `=` lets notes open with a `-` list item;
tsk refuses the short `-n=` form.

**Close only on a yes.** When you believe a task you worked on is complete (its PR merged, or the
outcome verified), ask the user in one line: `T12 looks complete: <evidence>. Mark it done?`
Set `tsk status T12 done` only on a yes. Until then it stays at `review`; `done` is the
user's call.

## Chef

A chef is the one coordinator session for a repo. It runs in the main checkout on the default
branch, and its herdr agent is named `<project>-chef`. A repo has at most one chef. For the
coordination workflow (plan, brief, dispatch, review gate, live test), load `tsk-coordinator`.

### Make a session the chef

Requires herdr (`HERDR_ENV=1`).

**1. Find the target and the repo.**

- **Rename existing** (the default): the target is this pane, `$HERDR_PANE_ID`, or the pane or
  agent name that the user gives. The target must be a detected agent, not a plain shell.
- **Create new**: the user says "new". The repo is the path given, else the repo of this pane.

`herdr agent list` prints JSON. Each agent has `pane_id`, `name`, `agent` (`claude` or
`codex`), and `cwd`. `herdr agent get <pane>` shows one agent.

Get the repo root and the project name from the target `cwd`, or from the given path for "new":

```bash
root=$(dirname "$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir)")
project=$(basename "$root")
```

The chef name is `${project}-chef`. Lowercase it, and replace characters outside `[a-z0-9_-]`
with `-`: herdr agent names must match `[a-z][a-z0-9_-]{0,31}`.

**2. Check the rules.** Stop and report to the user if a rule fails.

1. **Main checkout, not a worktree.** For a rename,
   `git -C "$cwd" rev-parse --path-format=absolute --git-dir` must equal the
   `--git-common-dir`. A new chef starts at `$root`, so this rule holds.
2. **Default branch.** `git -C "$root" branch --show-current` must equal the default branch:
   `git -C "$root" symbolic-ref --short refs/remotes/origin/HEAD` without `origin/`, or `main`
   if that command fails.
3. **One chef per repo.** No agent in `herdr agent list` other than the target may have the
   `name` `${project}-chef`. If one exists, report its `pane_id` and stop. If the target
   already has the name, skip the herdr rename and do the session rename.

**3a. Rename existing.**

```bash
herdr agent rename <TARGET> ${project}-chef
herdr agent prompt <TARGET> "/rename ${project}-chef"
```

Send `/rename` without `--wait`: it does not start a turn.

- **Claude Code**: `/rename` takes the name inline and runs at once, also during a turn, so it
  works when the target is this pane.
- **Codex**: `/rename` renames the thread, but it can open a "Name thread" input instead of
  using the inline name. Read the pane with
  `herdr agent read <TARGET> --source recent --lines 20`. If the input is open, send the name:
  `herdr agent prompt <TARGET> "${project}-chef"`.

**3b. Create new.**

```bash
herdr worktree list --cwd "$root" --json     # result.source.source_workspace_id -> SRC
herdr tab create --workspace <SRC> --cwd "$root" --label "${project}-chef" --no-focus
                                             # result.root_pane.pane_id -> PANE
herdr agent start ${project}-chef --kind claude --pane <PANE> --timeout 60000 -- --name ${project}-chef
```

`agent start` names the herdr agent. `--name` names the Claude Code session at launch. For
Codex, use `--kind codex`, remove `-- --name …`, and rename the session as in 3a.

**4. Verify and report.** `herdr agent get <TARGET>` must show `name` as `${project}-chef`. For
Claude Code, `terminal_title_stripped` also shows the session name. Report the chef name, the
pane, and the repo.

## Cook

A cook works one task in its own worktree and branch.

**Open the board beside you.** Inside herdr (`HERDR_ENV=1`), open the task in the tsk TUI in a
sibling pane when you start work. This overrides the tsk guide's rule that agents never open
the TUI.

1. Split the opposite way from the pane's shape and keep focus:
   `herdr pane split --current --direction right --cwd <root> --no-focus`. Use `down` for a
   narrow pane.
2. Run `herdr pane run <pane> "cd <root> && tsk"`. Start it from the main checkout: started
   from the worktree, it scopes to a stray empty project.
3. Select the task with `herdr pane send-keys` (arrow keys, then `enter`), and confirm with
   `herdr pane read`.

`pane run` types into whatever is in the foreground. Send it only to a fresh shell pane: in a
pane already running the TUI, the text lands as keystrokes.
