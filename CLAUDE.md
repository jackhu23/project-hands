# Working on Project HANDS

Read [CONTEXT.md](CONTEXT.md) before writing code, and use its terms (Patient, Session, Exercise Run, Trial, Action, Touch Sample...) in code, tests and pull requests. Decisions live in [docs/adr/](docs/adr/), product requirements in [docs/prd/](docs/prd/).

## Commands

Always run Flutter and Dart through FVM so the pinned SDK in `.fvmrc` is used.

- Setup: `fvm install`, `fvm flutter pub get`, then `fvm dart run tool/setup.dart`
- Test: `fvm flutter test`
- Lint: `fvm flutter analyze` (any issue fails)
- Format: `fvm dart format .` (CI checks with `--output=none --set-exit-if-changed .`)
- Run: `fvm flutter run`

## Conventions

- One branch per issue, named `issue-<N>-<short-slug>`, branched from `main`. Never commit to `main`; every change lands through a pull request into `main` that passes CI.
- Open pull requests with `--base main`: the GitHub default branch is still `feature/balloon-demo` until #4 switches it.
- Build test-first: one failing test, the code to pass it, repeat. Tests go through public interfaces (pump the widget, find what the Patient sees), not private implementation.
- Run analyze, format check and tests locally before opening a pull request.
- The repository is public: synthetic data only. Never commit real Patient data, Session exports or screenshots with real IDs.
- The pull request body follows the template, ticks the acceptance criteria that are met, and includes `Closes #<N>`.

## Review formats

**AI review.** A reviewer with fresh context, which did not write the code, reviews the pull request against the issue's acceptance criteria and posts one pull request comment per round:

```
## AI review, round <1|2>
[ai-review] severity: <blocker|bug|design|nit> - <finding, with file:line>
[ai-review] severity: ... - ...
```

If it finds nothing, it posts the heading and `[ai-review] none`. The author fixes findings and pushes. There are at most two rounds; anything left after round two is listed under "Review notes" for the human reviewer rather than looping again.

**Human review.** Review comments start with a category: `bug:`, `design:`, `test:`, or `nit:`.

**Review notes.** Before handing the pull request to the human reviewer, the author fills in the template's "Review notes": what failed in CI, what the AI reviewer caught and how it was fixed, and anything unresolved.
