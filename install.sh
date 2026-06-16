#!/usr/bin/env bash
# Install the pr-loop skill into the skill directories of claude, codex, and pi.
#
# Usage:
#   ./install.sh            # install into every harness found on this machine
#   ./install.sh claude pi  # install into the named harnesses only
#   ./install.sh --all      # install into all harnesses, creating dirs as needed
#
# Env overrides for non-default locations:
#   CLAUDE_CONFIG_DIR  (default ~/.claude)
#   CODEX_HOME         (default ~/.codex)
#   PI_HOME            (default ~/.pi)
set -euo pipefail

skill="pr-loop"
src="$(cd "$(dirname "$0")" && pwd)/skills/$skill"
[ -f "$src/SKILL.md" ] || { echo "error: $src/SKILL.md not found" >&2; exit 1; }

# Harness base dirs (overridable) and their skills subdirectory.
claude_base="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
codex_base="${CODEX_HOME:-$HOME/.codex}"
pi_base="${PI_HOME:-$HOME/.pi}"
skills_dir() {
  case "$1" in
    claude) echo "$claude_base/skills" ;;
    codex)  echo "$codex_base/skills" ;;
    pi)     echo "$pi_base/agent/skills" ;;
  esac
}
base_dir() {
  case "$1" in
    claude) echo "$claude_base" ;;
    codex)  echo "$codex_base" ;;
    pi)     echo "$pi_base" ;;
  esac
}

# Decide which harnesses to install into.
force=0
targets=()
for arg in "$@"; do
  case "$arg" in
    --all) force=1 ;;
    claude|codex|pi) targets+=("$arg") ;;
    *) echo "error: unknown argument '$arg' (expected claude|codex|pi|--all)" >&2; exit 1 ;;
  esac
done
# With no harness names given, auto-detect every harness present (or all with --all).
if [ "${#targets[@]}" -eq 0 ]; then
  for h in claude codex pi; do
    if [ "$force" -eq 1 ] || [ -d "$(base_dir "$h")" ]; then
      targets+=("$h")
    fi
  done
fi
if [ "${#targets[@]}" -eq 0 ]; then
  echo "No harness found (looked for ~/.claude, ~/.codex, ~/.pi). Re-run with --all to install anyway." >&2
  exit 1
fi

for h in "${targets[@]}"; do
  dest="$(skills_dir "$h")/$skill"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$dest"
  cp -R "$src" "$dest"
  echo "installed $skill → $dest"
done
