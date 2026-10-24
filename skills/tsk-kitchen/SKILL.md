---
name: tsk-kitchen
description: House rules for working the tsk board, by role. The chef coordinates a repo from its main checkout and dispatches tasks; a cook works one task in its own worktree. Load before your first `tsk` command in a session, alongside `tsk-cli`.
---

# tsk-kitchen

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

**Close only on a yes.** When you believe a task you worked on is complete (its PR merged, or the
outcome verified), ask the user in one line: `T12 looks complete: <evidence>. Mark it done?`
Set `tsk status T12 done` only on a yes. Until then it stays at `review`; `done` is the
user's call.

## Chef

The chef runs the repo's coordination loop from the main checkout. For planning, briefs, the
review gate, and live tests, load `tsk-coordinator`. To name a session the chef, use
`herdr-chef`.

1. **Brief.** Write the brief into the task's notes. A dispatched cook reads its brief there.
2. **Assign.** `tsk edit T12 --assignee <profile> [--base <branch>]`, where the profile is an
   `[agent.<name>]` in `~/.tsk/config.toml`.
3. **Preview.** `tsk dispatch T12 --show-prompt` prints the command and prompt the cook gets.
4. **Dispatch.** `tsk dispatch T12` creates the worktree and herdr workspace, starts the
   cook with tsk's prompt, and sets the task `started`. Confirm it is working with
   `herdr agent get t12-<profile>`.
5. **Wait on status.** The cook signals by setting `review` or `blocked`; poll
   `tsk list T12 --json`.
6. **Clean up** after the user merges: `tsk clean T12`.

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
