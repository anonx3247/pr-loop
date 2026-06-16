# pr-loop

An agent skill for shipping a piece of work as a series of small pull requests —
one dedicated, backgrounded subagent per PR.

Given a task, the orchestrator splits it into the smallest set of independently
reviewable PRs, chooses Graphite or plain GitHub stacking, creates a git worktree
and a backgrounded subagent for each PR, and lets each subagent iterate on its
own PR's CI and review comments until it merges — then cleans up. It drives
`git`, `gh`, and `gt` directly, so it runs unchanged under any agent harness.

## Requirements

- `git` and a remote you can open PRs against.
- `gh` (GitHub CLI), authenticated.
- `gt` (Graphite CLI), optional but preferred for stacked PRs.
- A harness that can background a subagent.

## Install

```bash
./install.sh            # install into every harness found (claude, codex, pi)
./install.sh claude pi  # or name the harnesses to install into
```

This copies the skill into each harness's skills directory
(`~/.claude/skills`, `~/.codex/skills`, `~/.pi/agent/skills`). Override the base
locations with `CLAUDE_CONFIG_DIR`, `CODEX_HOME`, or `PI_HOME`.

The workflow entry point is [`skills/pr-loop/SKILL.md`](skills/pr-loop/SKILL.md);
the per-PR subagent workflow is [`worker.md`](skills/pr-loop/worker.md) and the
Graphite reference is [`gt-graphite.md`](skills/pr-loop/gt-graphite.md).
