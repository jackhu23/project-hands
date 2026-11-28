# Project HANDS

[![CI](https://github.com/jackhu23/project-hands/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/jackhu23/project-hands/actions/workflows/ci.yml)

A Flutter tablet app for post-stroke hand rehabilitation, for iPad and Android tablets.

Before writing code, read [CONTEXT.md](CONTEXT.md) (the glossary: Patient, Session, Exercise Run, Trial, Action, Touch Sample), [ADR 0001](docs/adr/0001-flutter-for-the-tablet-app.md) (why Flutter) and the [foundation PRD](docs/prd/0001-project-foundation.md).

## Prerequisites

Install these once per machine.

**macOS** (needs [Homebrew](https://brew.sh)):

```sh
brew tap leoafarias/fvm
brew install fvm
brew install cocoapods
```

Also install Xcode from the App Store, for the iOS Simulator and iPad builds. Open it once to finish its first-launch setup and download the iOS platform (Xcode → Settings → Components), then run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`.

**Windows** (needs [Chocolatey](https://chocolatey.org/install), installed from an **admin** PowerShell):

```powershell
choco install fvm -y
```

Also turn on **Developer Mode**: search Settings for "Developer Mode" (it is under System → Advanced on Windows 11 24H2 and later, System → For developers before that). FVM and Flutter plugins use symlinks, which fail without it.

**Both:** install [Android Studio](https://developer.android.com/studio) for the Android SDK and emulator. In Device Manager, create a tablet emulator (for example Pixel Tablet).

## Setup

From the repo root, on any OS:

1. `fvm install` downloads the Flutter version pinned in `.fvmrc` (Dart included).
2. `fvm flutter pub get` fetches the packages locked in `pubspec.lock`.
3. `fvm dart run tool/setup.dart` checks the result and prints `Setup OK` or what to fix.

Then accept the Android licenses once with `fvm flutter doctor --android-licenses`, and run `fvm flutter doctor` to confirm the Android (and on Mac, Xcode) toolchain is ready.

Always run Flutter through FVM (`fvm flutter ...`, `fvm dart ...`), or point your editor at `.fvm/flutter_sdk`, so you build with the pinned version, not a global one.

## Daily testing loop

`fvm flutter devices` lists what you can run on, and `fvm flutter run -d <device>` starts the app there. Before pushing, run the same checks CI does:

```sh
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

**Windows:** test on the Android tablet emulator (`fvm flutter emulators --launch <id>`) and on a physical Android tablet with USB debugging turned on. You can't build for iPad on Windows. CI builds iOS on every change that can break it, and Mac teammates check behaviour on an iPad.

**macOS:** everything above, plus the iOS Simulator (`open -a Simulator`) and a physical iPad. The first time you run on an iPad, open `ios/Runner.xcworkspace` in Xcode and choose your Apple ID team under Signing & Capabilities.

**Anything metric-related** (touch timing, accuracy, Touch Samples) must be tested with a real finger on a physical tablet. Emulators and mouse clicks don't produce realistic touch data.

### Testing on the other platform

The device smoke test ([`integration_test/smoke_test.dart`](integration_test/smoke_test.dart)) opens the real app, plays one Exercise Run at Level 1, opens it from My progress, and takes a screenshot at each step. Use it to check a branch on the platform you don't have.

**In GitHub:** go to Actions → **Device smoke test** → **Run workflow**. Pick the branch and the platform (`android`, `ios` or `both`). It runs on an Android tablet emulator and an iPad simulator. When it finishes, the screenshots are under the run's **Artifacts** (`screenshots-android`, `screenshots-ios`). If one platform fails, the other still runs. It only runs when started this way, never on pull requests or pushes.

**Locally,** with an emulator, simulator or tablet connected:

```sh
fvm flutter drive -d <device> --driver=test_driver/integration_test.dart --target=integration_test/smoke_test.dart
```

The screenshots land in `build/screenshots/`. The test uses the device's own database, so it adds a run to whatever history the app on that device already has. On an emulator without GPU acceleration, add `--no-enable-impeller`.

## CI

GitHub Actions ([`.github/workflows/ci.yml`](.github/workflows/ci.yml)) runs on every pull request and every push to `main`.

- **Every pull request:** format, analyze and tests (`checks`), plus the setup script on Linux, macOS and Windows (`setup-script`).
- **Only when a pull request touches build-sensitive files**, as decided by the `changes` job (`pubspec.yaml`, `pubspec.lock`, `.fvmrc`, `ios/`, `android/` or the CI files): the Android build (`build-android`) and the iOS build (`build-ios`). Otherwise they show as skipped, which counts as passing.
- **Every push to `main`:** all of the above, including both builds.

A new push to a pull request cancels its older run.

## Contributing

- One branch per issue, named `issue-<N>-<short-slug>`, branched from `main`. Never commit to `main` directly.
- Every change lands through a pull request into `main`. GitHub only lets it merge once CI passes, and only as a merge commit.
- A human reviews every pull request and merges it by hand. Auto-merge is off.
- **Broken `main`:** whoever broke it reverts first and fixes second, so nobody else is blocked.

## Public repository: synthetic data only

This repository is public. Only commit synthetic data. Never commit real Patient data, Session exports, or screenshots that show real IDs.
