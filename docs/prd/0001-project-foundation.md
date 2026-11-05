# PRD: Project Foundation

## Problem Statement

Project HANDS is a tablet app for post-stroke hand rehabilitation, built by three part-time student developers between Nov 2026 and May 2027. Two develop on macOS and one on Windows, and the app has to run on both iPads and Android tablets for a December demo to Occupational Therapists (OTs).

The team lead has seen this go wrong before. On a previous mixed Mac/Windows team, tool versions drifted, packages installed differently on each machine, and setup scripts written on one OS failed on the other. Without a shared foundation, the team will lose its limited hours to "works on my machine" problems. A Windows developer can't build for iPad at all, so iOS breakages could go unnoticed until demo week. And because code reviews are optional to keep a fast prototyping pace, nothing else would catch broken or sloppy code before it merges.

## Solution

Set up the project foundation before any feature work starts:

- **A Flutter + Dart app skeleton** that builds for iPad and Android.
- **Pinned toolchain and dependency versions**, so every developer and CI use the same Flutter SDK and packages.
- **A single cross-platform setup script**, written in Dart, that takes a fresh Mac or Windows machine to a working project with one command.
- **GitHub Actions CI** as the only merge gate. It runs fast checks on every PR, runs the slower iOS and Android builds whenever a PR touches build-sensitive files, and runs everything on every push to `main`.
- **Lint rules** tuned to catch the bugs that would hurt this app most, especially silently lost Session data.
- **A shared domain vocabulary** (`CONTEXT.md`) and a recorded framework decision (ADR 0001), so all three developers, and anyone who joins in spring, use the same terms and know why Flutter was chosen.

## User Stories

1. As a HANDS developer on Windows, I want one setup command that installs the pinned Flutter version and project dependencies, so that I'm productive without following a long manual guide.
2. As a HANDS developer on macOS, I want the same setup command to work unchanged on my machine, so that our team never maintains separate Mac and Windows scripts.
3. As a HANDS developer, I want the Flutter SDK version pinned in the repository, so that my machine builds with exactly the same toolchain as my teammates'.
4. As a HANDS developer, I want package versions locked and committed, so that installing dependencies gives identical results on every machine and on every day.
5. As a HANDS developer, I want line endings normalized by the repository, so that files don't show as changed just because they were saved on another OS.
6. As a HANDS developer on Windows, I want the README to tell me to enable Developer Mode, so that FVM and Flutter plugins work on the first try.
7. As a HANDS developer, I want the README to explain how to run the app on an Android emulator, a physical Android tablet and (on Mac) the iOS Simulator, so that I know my daily testing loop.
8. As a HANDS developer on Windows, I want to know that iPad testing goes through Mac teammates or CI, so that I don't waste time trying to build iOS locally.
9. As a HANDS developer, I want a minimal app that launches to a home screen, so that feature work starts from a known-good skeleton.
10. As a HANDS developer, I want an example widget test that launches the app, so that I have a pattern to copy when writing tests for my Exercise.
11. As a HANDS developer, I want CI to check formatting on every PR, so that we never argue about style and diffs stay readable.
12. As a HANDS developer, I want CI to run static analysis on every PR, so that type errors and lint violations are caught before merge.
13. As a HANDS developer, I want CI to run all unit and widget tests on every PR, so that logic regressions (for example in metric calculations) are caught before merge.
14. As a HANDS developer, I want CI to run the setup script on Linux, macOS and Windows on every PR, so that a script change that breaks one OS can't merge.
15. As a HANDS developer, I want the fast checks to finish in about 1â€“2 minutes, so that the many small PRs I open per feature don't slow me down.
16. As a HANDS developer, I want the iOS and Android builds to run on a PR only when it changes dependencies, platform configuration or the Flutter version, so that ordinary Dart-only PRs stay fast.
17. As a HANDS developer on Windows, I want CI to build the iOS app whenever I add or upgrade a package, so that I learn immediately if my change breaks the iPad build that I can't run locally.
18. As a HANDS developer, I want CI to build both iOS and Android on every push to `main`, so that any breakage the PR filter missed is caught within minutes of merging.
19. As a HANDS developer, I want CI to use the same pinned Flutter version as my machine, so that "passes locally, fails in CI" only happens for real differences.
20. As a HANDS developer, I want CI to cache the Flutter SDK and packages, so that repeat runs are fast.
21. As a HANDS developer, I want a superseded CI run to be cancelled when I push again to the same PR, so that I never wait on stale results.
22. As a HANDS developer, I want passing CI to be the only requirement to merge, so that I can keep a hackathon pace without waiting for a review.
23. As a HANDS developer, I want to enable auto-merge on my PR, so that it merges by itself as soon as CI is green while I start the next issue.
24. As a HANDS developer, I want PRs merged with regular merge commits, so that each issue's history is preserved on `main` and a single PR can be reverted.
25. As a HANDS developer, I want to be notified by email when a push to `main` fails CI, so that I know I broke `main` and can revert it.
26. As a HANDS developer, I want a documented "revert first, fix second" norm for a red `main`, so that my teammates are never blocked by my breakage.
27. As a HANDS developer, I want the linter to flag async calls that are never awaited, so that a failed "save Session" can't silently lose a Patient's data.
28. As a HANDS developer, I want the linter to flag dynamic method calls, so that AI-written parsing code can't crash mid-Exercise with a runtime type error.
29. As a HANDS developer, I want the linter to flag stream subscriptions that are never cancelled, so that touch and timer listeners don't leak or record duplicate Touch Samples.
30. As a HANDS developer, I want any analyzer issue to fail CI, so that the linter acts as our stand-in for code review.
31. As a HANDS developer, I want a glossary defining Patient, Exercise, Balloon Touch, Tracing, Session, Exercise Run, Trial, Action and Touch Sample, so that my teammates and I name things in code the same way.
32. As a HANDS developer, I want the glossary to list words to avoid (such as "repetition," "attempt," "game"), so that ambiguous terms don't creep into the code with different meanings.
33. As the project lead, I want the Flutter decision recorded as an ADR with the rejected alternatives, so that nobody reopens the framework debate without new information.
34. As a developer joining in spring, I want to read the ADR and glossary, so that I understand why things are the way they are without the original conversation.
35. As the project lead, I want the repository to state that it is public and must contain only synthetic data, so that no real Patient data is ever committed.
36. As the project lead, I want the CI status shown in the README, so that anyone can see at a glance whether `main` is healthy.
37. As an OT advisor reviewing the December demo, I want the app to behave identically on iPad and Android, so that usability feedback isn't confounded by platform differences.

## Implementation Decisions

- **Framework:** Flutter with Dart, per ADR 0001. Touch capture and canvas drawing use Flutter's built-in facilities. Rejected: React Native/Expo, Kotlin Multiplatform, native Swift + Kotlin, Unity.
- **Target platforms for the skeleton:** iOS (iPad) and Android. Minimum OS versions, orientation and tablet-only settings are deferred to a later issue.
- **Toolchain pinning:** FVM pins the Flutter SDK version in a repo-committed config file. Developers run Flutter through FVM, or point their editor at the FVM-managed SDK.
- **Dependency pinning:** the package lockfile is committed (this is an app, not a library).
- **Line endings:** a git attributes file normalizes text files to LF.
- **Setup script:** written in Dart and run with `dart run`. It must run identically on macOS, Windows and Linux. It launches external tools with shell resolution enabled, so `.bat` wrappers work on Windows, and builds paths with the `path` package, never string concatenation. At minimum it verifies or installs the pinned Flutter version via FVM and fetches dependencies.
- **CI platform:** GitHub Actions. The repository is public, so hosted Linux, macOS and Windows runners are free.
- **CI events and jobs:**
  - **On every `pull_request` (into any branch):**
    - Job "checks" on Linux: format check (fails on unformatted code), `flutter analyze` (fails on any issue), `flutter test`.
    - Job "setup-script" as a matrix over Linux, macOS and Windows: runs the setup script from a clean checkout.
    - Job "build-ios" on macOS (`flutter build ios --no-codesign`) and job "build-android" on Linux: **only when** the PR changes the package manifest or lockfile, anything under the iOS or Android platform folders, or the FVM version file.
  - **On every `push` to `main`:** all jobs, including both builds, unconditionally.
  - All jobs read the Flutter version from the FVM config so CI matches developers exactly.
  - Flutter SDK and pub caching are enabled.
  - A concurrency group per ref cancels superseded runs.
- **Merge policy:** passing CI is the only merge requirement; reviews are optional. Only merge commits are allowed (no squash). Auto-merge is enabled for the repo. No formal branching rules; the team agrees on branching verbally. Branch protection on `main` requires the CI checks that always run, plus the build checks, which count as satisfied when skipped by the path filter.
- **Broken `main`:** failure emails go to whoever triggered the run. Team norm: whoever broke `main` reverts first, fixes second.
- **Lint rules:** base set `flutter_lints`, plus `unawaited_futures`, `avoid_dynamic_calls` and `cancel_subscriptions`. Revisit `very_good_analysis` in spring 2027, while the codebase is still small.
- **Domain vocabulary:** `CONTEXT.md` is the single glossary. The hierarchy is Patient â†’ Session â†’ Exercise Run â†’ Trial â†’ Action â†’ Touch Sample. Dart types introduced later must use these names. Metrics will be computed from stored raw Trials, Actions and Touch Samples rather than stored precomputed. This shapes the storage work later but isn't implemented here.
- **Repository hygiene:** the learner-notes directory (`.vibe-wise/`) is git-ignored. The README covers prerequisites (FVM, Windows Developer Mode), the one-command setup, the daily testing loop per OS, the CI overview, the synthetic-data-only rule and a CI status badge.

## Testing Decisions

- **What makes a good test here:** it checks externally observable behavior, such as "the app launches to its home screen" or "CI skips the builds for a Dart-only PR," not internal implementation details.
- **Seam 1: the CI workflow on real PRs.** Verified by opening (a) a Dart-only PR, which should run only the fast checks and the setup-script matrix, with builds skipped; (b) a PR that changes the package manifest, which should also run the iOS and Android builds; and (c) a merge to `main`, which should run all jobs.
- **Seam 2: the setup script on a fresh machine.** Verified by the setup-script matrix job on Linux, macOS and Windows, which must pass on every PR.
- **Seam 3: the lint configuration.** Verified once, manually, during implementation: a scratch change introducing an unawaited future and a dynamic call must fail `flutter analyze`, and clean code must pass. That scratch code isn't committed.
- **Seam 4: the app smoke test.** One widget test that pumps the app and finds the home screen. It proves the test setup works in CI and is the example teammates copy for Exercise tests.
- **Prior art:** none. This is the first code in the repository. The smoke test becomes the prior art for later tests.

## Out of Scope

- Any rehabilitation Exercise (Balloon Touch, Tracing), metrics, real-time feedback or "Watch How" videos.
- Local storage technology and the database schema. This must still be decided and built by the end of November 2026, under a separate PRD.
- Dart classes for the domain model. The vocabulary is fixed here; code comes with the Exercise work.
- State management library, folder structure, minimum OS versions and orientation. Deferred to later issues.
- Required code reviews, CODEOWNERS and formal branch naming rules.
- Release builds, code signing, TestFlight and the Apple Developer account.
- Running the Android build on Windows runners. Add it only if Windows-specific build problems appear.
- Team notifications in Discord or Slack for a broken `main`.
- Everything the project brief rules out: AI/ML, computer vision, EHR integration, cloud patient accounts, HIPAA infrastructure, AR/VR, external hardware.

## Further Notes

- **The repository is public.** Never commit real Patient data, session exports, or screenshots with real IDs. Use synthetic fixtures only. If usability testing involves real patients, check the IRB/ethics requirements with the OT advisor early.
- **The Windows developer's daily testing loop** is the Android emulator plus a physical Android tablet. iPad verification relies on the Mac teammates and the macOS CI build. Real-finger testing on physical tablets is required for anything metric-related; mouse input in an emulator doesn't resemble patient movement.
- **Open question for the OT advisors:** does sub-frame Apple Pencil data (iOS coalesced touches, up to 240 Hz) matter? Flutter doesn't expose it out of the box (see ADR 0001).
- **Timeline context:** one Exercise is due by mid-November 2026, and two Exercises plus storage and progress tracking by the end of November. This foundation should land first so feature issues can build on it.
