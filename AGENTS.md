# Authoring skills in this repo

One directory per skill, published through the [`skills`](https://skills.sh)
CLI and consumed by any harness that reads it.

```
skills/<name>/SKILL.md
```

Keep this layout flat. Never nest skills into category folders: installed
lockfiles record each skill's exact `skillPath`, so moving a skill later makes
the CLI report it as "deleted upstream" to everyone who has it — a silent break
that reads as if the skill were withdrawn.

## Create one

```bash
cd skills && npx skills init <name>
```

Write the body against `TEMPLATE.md`, and match the section shape of a skill
already in `skills/`.

Frontmatter takes `name` and `description`. The description is the only text an
agent sees when deciding whether to load the skill, so write it for selection:
what the skill does, and the distinct triggers that should reach it. Two
optional fields are worth knowing:

- `disable-model-invocation: true` withdraws the skill from automatic selection
  and makes it `/name`-only. Use it for skills that should fire deliberately.
- `argument-hint: "..."` sets the placeholder text for a user-invoked skill.

After writing the file, run `./dev-link.sh <name>` to link it into every
harness, then commit. The README explains what the link does and when to
replace it with a tracked install.

## House style

**Write for reuse.** A skill here is generic. Project-specific conventions —
build commands, directory layout, house terminology — belong to the calling
project. Where a skill has that seam, say so in it, so a caller knows what to
layer on top.

**Ground claims in sources.** Fetch the guide, the spec, or the API docs a
skill encodes rather than writing from recall.

**State limits.** Link to a reference that is large or that changes instead of
reproducing it, and name the cases the skill declines. A skill that admits its
edges is more useful than one that bluffs past them.

**Prompt the positive.** Say what to do. A prohibition makes the banned
behaviour more available, not less, so save it for a hard guardrail and pair it
with the target behaviour.

**Earn every line.** Cut anything an agent already does by default. Keep each
rule in one place; a rule stated twice is a rule that changes in one place and
goes stale in the other.
