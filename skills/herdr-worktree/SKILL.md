---
name: herdr-worktree
description: "Launch a new herdr worktree workspace under a repo, optionally seeded from a GitHub issue, with an agent started and prompted automatically. Use when the user says 'new worktree for issue N', 'spin up a worktree in akku to do X', 'start an agent on branch Y', or wants an isolated workspace for a task."
argument-hint: "[repo: akku|ledger|path] [issue number or branch-name] [optional task prompt] [kind:codex]"
---

# herdr-worktree — spin up a task worktree with a primed agent

Creates a git worktree as a **sibling workspace grouped under the repo's workspace**, then starts an agent in it and hands it the task prompt.

Requires: running inside herdr (`HERDR_ENV=1`), herdr >= 0.7.5 (`agent start` / `agent prompt`), and `gh` for issue lookup.

## Arguments

Free-form. Extract:

- **repo** — `akku`, `ledger`, or a path. Resolve to a repo root: use the path if given, else `~/code/<name>`. Confirm with `git -C <root> rev-parse --show-toplevel`.
- **issue number** (optional) — e.g. `79`, `#79`, `issue 79`.
- **branch name** (optional) — explicit branch; otherwise derive one.
- **prompt** (optional) — the task text for the agent. If an issue is given and no prompt, build the prompt from the issue.
- **agent kind** (optional) — default `claude`. Also `codex`, `gemini`, etc.

If repo is ambiguous or missing, ask. Everything else has a sane default.

## Steps

### 1. Resolve the source workspace (never reuse a cached id)

Workspace ids (`w4`, `w21`, …) are renumbered and recycled — always resolve fresh, keyed on the repo path:

```bash
herdr worktree list --cwd <repo-root> --json
```

Take `result.source.source_workspace_id` as `<SRC>`, and check `result.worktrees[]` for whether the branch already exists.

### 2. If an issue number was given, fetch it

```bash
gh issue view <N> --repo <owner/repo> --json number,title,body,url
```

Derive:
- branch: `issue-<N>-<slug>` (slug = title lowercased, non-alphanumerics → `-`, trimmed, max ~4 words) — matches the existing convention (`issue-47-extrinsic-fees`).
- label: `#<N>: <title>` (workspace label; free-form, spaces fine).
- prompt: issue title + body + URL, plus any extra instruction the user gave.

### 3. Create the worktree

**If the branch/worktree does NOT already exist:**

```bash
herdr worktree create --workspace <SRC> --branch <BRANCH> \
  --label "<LABEL>" --base <BASE> --no-focus --json
```

- `--base` defaults to the source checkout's `HEAD`, which may be stale. For a clean start prefer an up-to-date ref: `git -C <repo-root> fetch origin` then `--base origin/main` (or `origin/master` for ledger).
- Use `--no-focus` unless the user asked to jump there — focusing yanks them out of the current pane.

**If the branch/worktree ALREADY exists** (from `worktree list`), adopt it instead — `create` will fail:

```bash
herdr worktree open --workspace <SRC> --branch <BRANCH> --no-focus --json
```

`open` returns `already_open: true` and attaches group provenance to the existing workspace in place (no duplicate).

Parse from either response:
- `result.workspace.workspace_id` → `<WS>`
- `result.root_pane.pane_id` → `<PANE>`
- `result.workspace.worktree.checkout_path` → the worktree dir

### 4. Start the agent

Agent names must match `[a-z][a-z0-9_-]{0,31}` and be unique among **live** agents (names free up when the agent exits). Derive from the branch, e.g. `issue-79-dividends` → `issue79`; on collision append `-2`.

```bash
herdr agent start <AGENT_NAME> --kind claude --pane <PANE> --timeout 60000
```

The pane must be at an interactive shell prompt — a freshly created worktree root pane always is. Success means the agent was detected and is ready for input.

### 5. Send the prompt

```bash
herdr agent prompt <AGENT_NAME> "<PROMPT TEXT>" --wait --until working
```

`agent prompt` submits text **with Enter** (bracketed-paste safe). `agent send-keys` sends key presses only (`esc`, `enter`, `ctrl+c`).

For long prompts, keep it one argument; embedded newlines are fine. If `--wait` reports `agent_prompt_stalled` (no state change after 5s), the submission didn't take — read the pane and retry:

```bash
herdr agent read <AGENT_NAME> --source recent --lines 40
```

### 6. Report back

Give the user: workspace id + label, branch, worktree path, agent name, and the one-liner to jump there:

```bash
herdr workspace focus <WS>     # or: herdr agent focus <AGENT_NAME>
```

## Gotchas

- **`worktree create` makes a NEW sibling workspace.** It does not add panes/tabs to the existing repo workspace. Grouping is by repo (`repo_key`), so a worktree can only join its own repo's group.
- **Moving an existing tab/pane in instead?** `herdr pane move <pane> --new-workspace --label "<name>"` creates a *detached* workspace (no group provenance); fix it by running `worktree open --workspace <SRC> --branch <BRANCH>` afterwards, which attaches provenance to that same workspace.
- **`pane move` does not change a pane's cwd.** A shell already running keeps its original directory — only move panes that are already inside the worktree, else `cd` them.
- **Agents may go `blocked` after being moved** between workspaces — they're waiting on input, not broken.
- **Cleanup:** `herdr worktree remove --workspace <WS> [--force]`. Never `rm -rf` a worktree dir; git tracks its metadata (`git worktree remove <path>` / `git worktree prune` if it was deleted).

## Example

> "new worktree in akku for issue 79, tell it to export dividends to CSV"

```bash
herdr worktree list --cwd ~/code/akku --json                    # -> SRC=w4
gh issue view 79 --repo ascjones/akku --json number,title,body,url
git -C ~/code/akku fetch origin
herdr worktree create --workspace w4 --branch issue-79-dividends \
  --label "#79: dividends export" --base origin/main --no-focus --json   # -> WS, PANE
herdr agent start issue79 --kind claude --pane <PANE> --timeout 60000
herdr agent prompt issue79 "Work on issue #79: <title>

<body>

<url>

Additionally: export dividends to CSV." --wait --until working
```
