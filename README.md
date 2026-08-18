# skills

Personal agent skills, usable across Claude Code, Codex, and any other harness
the [`skills`](https://skills.sh) CLI supports.

## What's here

| Skill | What it does |
|---|---|
| [`google-dev-style`](skills/google-dev-style/SKILL.md) | Writes and reviews developer docs in Google developer documentation style. |
| [`test-cull`](skills/test-cull/SKILL.md) | Sweeps a test suite and removes tests that cannot fail for a reason worth acting on. |

## Install

```bash
npx skills add ascjones/skills -g -a claude-code -a codex
```

To install specific skills, add `-s <name>`. The flag repeats; it does not
accept a comma-separated list.

Name the agents you use rather than passing `-a '*'`, which fans out to more
than 50 agent targets and creates directories for tools you don't have.

## Work on a skill

Each skill is one directory: `skills/<name>/SKILL.md`. To edit a skill and see
the change in every harness right away:

```bash
./dev-link.sh <name>
```

The script symlinks the skill into `~/.agents/skills/`, the universal directory
Codex reads, then points `~/.claude/skills/<name>` at that same target. Every
harness reads this working copy, so your edits are live: run `/reload-skills`
in an open session, or start a new one.

`npx skills add ./` looks like the same thing, but it copies the files instead
of linking them, once per agent. The copies go stale the moment you edit the
skill here, and they drift apart when you update one harness and not the other.

To remove a link, delete the two symlinks. The skill stays in this repo.

```bash
rm ~/.agents/skills/<name> ~/.claude/skills/<name>
```

## Track a finished skill

A linked skill leaves no entry in `~/.agents/.skill-lock.json`, so
`npx skills list` and `npx skills update` can't see it. Once a skill settles
down, install it the normal way:

```bash
npx skills remove <name> -g -y
npx skills add ascjones/skills -g -a claude-code -a codex -s <name>
```

## Authoring conventions

[AGENTS.md](AGENTS.md) holds the conventions for writing a skill in this repo —
layout rules, frontmatter, and house style. `CLAUDE.md` is a symlink to it.
