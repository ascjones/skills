# skills

Personal agent skills, usable across Claude Code, Codex, and any other
harness the [`skills`](https://skills.sh) CLI supports.

## Install

```bash
npx skills add ascjones/skills -g -a claude-code -a codex
```

Add `-s <name>` (repeatable — it does **not** accept a comma-separated list)
to install only specific skills.

Prefer naming agents explicitly over `-a '*'`, which fans out to 50+ agent
targets and creates directories for tools you don't use.

## Layout

```
skills/<name>/SKILL.md
```

Flat, one directory per skill. **Do not nest into category folders.**
Installed lockfiles record each skill's exact `skillPath`, so moving a skill
later makes the CLI report it as "deleted upstream" to everyone who has it —
a silent, confusing break that looks like the skill was withdrawn.

## Authoring

```bash
cd skills && npx skills init <name>
```

Creates `skills/<name>/SKILL.md`. See `TEMPLATE.md` for the frontmatter
fields, including the two optional ones worth knowing:

- `disable-model-invocation: true` — the skill is no longer offered to the
  model automatically and becomes `/name`-only. Use it for skills you want to
  fire deliberately rather than have an agent reach for on its own.
- `argument-hint: "..."` — placeholder text shown for user-invoked skills.

## Local development — `dev-link.sh`

```bash
./dev-link.sh <name>
```

Symlinks `skills/<name>` into `~/.agents/skills/` (the universal directory
Codex reads) and points `~/.claude/skills/<name>` at that same target. Every
harness then reads this working copy directly, so **edits are live**: save the
file and run `/reload-skills` in a running session, or just start a new one.

### Why not just `npx skills add ./`

`npx skills add` accepts a local path, but it **copies** the files rather than
linking them. The copy is a snapshot — edit the skill here afterwards and the
installed version keeps serving the old text until you re-run the install.
That turns every wording tweak into a reinstall, which is the wrong loop when
you are iterating on how a skill reads.

It also copies **per agent**. Install for two harnesses and you get two
independent copies that drift apart the moment one is updated and the other
isn't. `dev-link.sh` keeps a single source of truth: one directory in this
repo, symlinked everywhere.

### When to stop using it

`dev-link.sh` is for skills you are actively writing. It deliberately leaves
no entry in `~/.agents/.skill-lock.json`, so linked skills are invisible to
`npx skills list` and `npx skills update`.

Once a skill is stable and pushed, install it the normal way so it is tracked
and updatable:

```bash
npx skills remove <name> -g -y     # drop the link if one exists
npx skills add ascjones/skills -g -a claude-code -a codex -s <name>
```

### Undoing a link

```bash
rm ~/.agents/skills/<name> ~/.claude/skills/<name>
```

Both are symlinks, so this removes only the links — the skill itself stays in
this repo.

## Credits

Inspired by [a post from Nate B. Jones](https://x.com/natebjones/status/2089457435459404093).
