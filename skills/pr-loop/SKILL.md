---
name: pr-loop
description: A workflow for shipping a piece of work as a series of small pull requests, one dedicated subagent per PR. Use this whenever you are asked to implement, build, refactor, or ship something that should land as PRs. It covers splitting the work into PRs, choosing Graphite or plain GitHub stacking, creating a worktree and a backgrounded subagent per PR, having each subagent iterate on its PR's CI and review comments until it merges, and cleaning up at the end. Drives `git`, `gh`, and `gt` directly, so it works under any harness.
---

# Shipping work as a series of PRs

You are the orchestrator. You split a piece of work into small pull requests and
hand **each PR to its own backgrounded subagent**, each working in its own git
worktree. Subagents do the coding and iterate on their PRs until they merge; you
coordinate the set and clean up at the end. You do not edit code yourself —
delegate every change to a subagent.

## 1. Understand the request

- **Small task** → ask at most 0–2 clarifying questions, then go.
- **Larger task** → propose a PR breakdown, ask for the detail you need, and
  iterate with the user until you converge before dispatching anything.

## 2. Split into PRs and pick a stacking strategy

Break the work into the **smallest set of independently reviewable PRs**. For
each PR decide:

- **independent** — branches off the trunk, reviewable on its own.
- **stacked** — depends on a previous PR. Use **Graphite** (`gt`) when it is
  available (`gt --version`) — it keeps each PR's base correct and restacks
  automatically; see [gt-graphite.md](gt-graphite.md). Otherwise use a manual
  GitHub stack where each PR's base is the previous PR's branch.

If you're stacking with Graphite and the repo isn't initialized, run `gt init`
(e.g. `gt init --trunk main`) once.

## 3. Create a worktree + subagent per PR

For each PR, in dependency order (stacks **bottom-up**), create a git worktree on
a new branch off the base:

```bash
git worktree add <path> -b <branch> <base>
```

Then spin off a **backgrounded subagent** for that worktree and hand it a
self-contained brief: the branch, the base, the stacking mode, the goal,
the files/areas involved, how to verify (the project's build/test/lint), and a
pointer to [worker.md](worker.md). Background it however your harness backgrounds
a subagent, and move on to the next PR — don't block on any one of them.

For a stack, give each subagent the previous PR's branch as its base, and never
dispatch a PR whose base hasn't been dispatched yet.

## 4. Let the subagents iterate

Each subagent implements its PR with atomic commits, runs a code-review or
simplify pass over its own diff, opens the PR, and then watches that PR — fixing
CI failures and addressing review comments — until it merges or closes
([worker.md](worker.md)).

Meanwhile you watch the set and coordinate:

```bash
gh pr list --author "@me" --state all --json number,title,state,headRefName
```

- When a PR **merges**, the next entry in its stack is unblocked — sync/restack
  it (`gt sync` for Graphite, or retarget + rebase for a manual stack) so it now
  targets the trunk, then proceed up the stack.
- When a subagent **finishes**, record what it did and start any follow-up.
- If a subagent goes the wrong way, steer it or stop and re-dispatch.

Merge stacks **bottom-up**.

## 5. Clean up

As PRs land, from the main checkout remove each finished PR's worktree and
branch:

```bash
git worktree remove <path>
git branch -d <branch>
gt sync                       # Graphite: also drops merged branches and restacks the rest
```

Prune anything left over (`git worktree prune`) once everything has merged.
