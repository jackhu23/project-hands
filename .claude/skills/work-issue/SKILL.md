---
name: work-issue
description: Build one GitHub issue end to end through the agent loop - branch, test-first build, pull request, fresh-context AI review (max two rounds), hand-off to the human reviewer. Use when the user says "/work-issue <N>" or "work on issue <N>".
argument-hint: <issue number>
---

# Work an issue

Build issue `$ARGUMENTS` in `jackhu23/project-hands` following [CLAUDE.md](../../../CLAUDE.md). An issue labelled `ready-for-agent` runs straight through without stopping, except for anything that needs the user's accounts, admin rights or hardware (a Mac, a physical tablet). Any other issue is HITL: stop where the issue needs the user.

## 1. Read

- `gh issue view $ARGUMENTS --comments`. Note the acceptance criteria and the "Blocked by" list.
- If any blocker is still open, stop and tell the user which.
- Read CONTEXT.md and the PRD and ADRs the issue links to.

## 2. Plan

- Write down the public interface and the behaviors to test, in priority order.
- HITL issue, or the user is present and asked to see it: get their approval before writing code.
- `ready-for-agent` issue: don't wait. Put the plan in the pull request's "What changed" so the human reviewer can check it against the code.

## 3. Build

- `git switch main && git pull`, then `git switch -c issue-$ARGUMENTS-<short-slug>`. If the issue already has a branch, use it instead.
- Build test-first with the `tdd` skill: one failing test, the code to pass it, repeat; refactor only when green.
- Before pushing: `fvm dart format --output=none --set-exit-if-changed .`, `fvm flutter analyze`, `fvm flutter test`. All must pass.
- Commit in small steps with messages that say why.

## 4. Open the pull request

- Push and run `gh pr create --base main`, filling in the template: `Closes #$ARGUMENTS`, what changed, and the acceptance criteria ticked. Criteria that need hardware or a person (e.g. "runs on the iOS Simulator") stay unticked and go under "Unresolved".
- Watch CI with `gh pr checks --watch`. If it fails, fix, push, and note the failure for the review notes. If the repo has no CI yet (before #3 lands), say so in the review notes and rely on the local checks.

## 5. AI review (at most two rounds)

- Start a reviewer subagent with fresh context. Give it only the issue number, the pull request number, and this brief: review the diff (`gh pr diff`) against the issue's acceptance criteria and CLAUDE.md; look for bugs, missing tests, untested edge cases, and design problems; report findings in the exact `[ai-review]` format from CLAUDE.md with file:line. It must not edit code.
- Post its output as a pull request comment headed `## AI review, round <n>`.
- Fix the findings you agree with, push, and wait for CI. If you disagree with a finding, say why in a reply rather than ignoring it.
- Run a second round only if round one found a blocker or bug. Never run a third.

## 6. Hand off

- Fill in "Review notes" in the pull request body (`gh pr edit --body-file`): CI failures, AI findings by severity and what was fixed, and anything unresolved.
- Tell the user the pull request is ready, with its link and a two-line summary. Never merge it yourself, and don't enable auto-merge unless the user asks.
