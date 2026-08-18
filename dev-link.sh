#!/bin/sh
# Symlink a skill from this repo into the universal + Claude Code skill dirs.
# Usage: ./dev-link.sh <name>
set -eu
name="${1:?usage: ./dev-link.sh <name>}"
src="$(cd "$(dirname "$0")" && pwd)/skills/$name"
[ -d "$src" ] || { echo "no such skill: $src" >&2; exit 1; }
[ -f "$src/SKILL.md" ] || { echo "missing $src/SKILL.md" >&2; exit 1; }
mkdir -p "$HOME/.agents/skills" "$HOME/.claude/skills"
ln -sfn "$src" "$HOME/.agents/skills/$name"
ln -sfn "../../.agents/skills/$name" "$HOME/.claude/skills/$name"
echo "linked $name -> ~/.agents/skills/$name (+ ~/.claude/skills/$name)"
