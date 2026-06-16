# Per-PR subagent

You own **one pull request**. You work in your assigned git worktree on your own
branch, open the PR, and then keep watching it — handling CI failures and review
comments — until it merges or closes.

Your brief gives you the branch, the base branch, the stacking mode, the goal,
the files involved, and how to verify. Work only within that scope; note any
out-of-scope discoveries in your final result.

## Implement with atomic commits

After every coherent, self-contained change:

```bash
git add -A
git commit -m "<type>: <concise description>"
```

Many small commits, not one big one. Keep each commit green — run the project's
build/tests/linters first. Use conventional prefixes (`feat:`, `fix:`,
`refactor:`, `test:`, `docs:`, `chore:`).

## Review your own diff

Once the work is done, run a **code-review or simplify pass over your own diff**
before opening the PR — use whichever such capability your harness provides.
Apply the worthwhile findings (correctness fixes, dead code, needless
complexity) and commit them, so the PR you open is already clean.

## Open the PR

**Independent or manual GitHub stack** (base is the trunk, or the previous PR's
branch for a manual stack):

```bash
git push -u origin <branch>
gh pr create --base <base> --head <branch> --title "<name>" --fill
```

**Graphite** — track and submit only your own branch:

```bash
gt track --parent <base> <branch>   # if not already tracked
gt submit --no-interactive
```

See [gt-graphite.md](gt-graphite.md) for the full Graphite workflow.

## Iterate until it lands

Opening the PR does **not** mean you are done. Review comments and CI results
keep arriving after your diff looks complete, and you are responsible for
reacting to them **automatically** — the orchestrator will not prompt you, and is
busy with other PRs. **Stay alive until your PR actually merges or closes**, even
during long stretches with nothing to do; don't exit just because the work looks
finished or you've reported your status.

Keep watching your PR the whole time, using your harness's background/monitor
capability or a poll loop. Watch for **three** independent things — don't wait on
CI alone:

- new or changed **CI / check** results,
- new **review comments, review threads, and reviews**,
- the PR's **merge / close** state.

Review comments arrive on their own schedule — often when CI is already green and
the PR is already mergeable — so every poll cycle must re-read the review threads
(`gh pr view <n> --json reviews,comments,reviewThreads`), not just the check
status or mergeability. Track what you've already handled (last-seen head commit
SHA, last-seen comment ids) so you don't redo work and so you notice each new
event.

**CI** — list checks with `gh pr checks <n>`. Reproduce a failure locally with
the project's gate, fix it, commit, and push. Inspect logs with
`gh run view --log-failed` when the cause isn't obvious. Keep checks honest — fix
the code, don't weaken the check.

**Reviews** — read them with `gh pr view <n> --json reviews,comments,reviewThreads`.
Address each in code, commit, push, and reply to each thread explaining how you
handled it (leave resolving the thread to the reviewer):

```bash
gh api repos/{owner}/{repo}/pulls/<n>/comments/<commentId>/replies -f body="..."
```

## Report back

Once the PR is open, report a concise status to the orchestrator (branch, PR
number + url, what you did, how you verified it, follow-ups) — but treat this as
a status update, **not** your exit. Keep running and watching the PR per the
section above; only truly finish once it has merged or closed.

You may spin off a focused helper subagent for a sub-task, two levels deep at
most.
