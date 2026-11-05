---
status: accepted
date: 2026-11-04
---

# Flutter (Dart) for the tablet app

HANDS must run on both iPad and Android tablets, and its core is capturing every finger/stylus touch point on a drawing canvas (Balloon Touch, Tracing). We chose **Flutter** because touch capture (`Listener`, finger-vs-stylus, pressure) and canvas drawing (`CustomPainter`) are built in, giving fewer third-party dependencies to keep compatible, and because it renders pixel-identically on iPad and Android, so visual behavior is reviewed once instead of per platform.

## Considered Options

- **React Native (Expo)** — the close runner-up. Rejected because smooth drawing and raw touch data need three extra libraries (Gesture Handler, Reanimated, Skia). We gave up its real advantages: a Windows developer can test on a real iPad through Expo Go; TypeScript is more widely known and more transferable to jobs; and code could be shared with a future React web dashboard if both lived in one repo.
- **Kotlin Multiplatform / Compose Multiplatform** — rejected: newer, with a thinner ecosystem and fewer learning resources.
- **Native (Swift + Kotlin)** — rejected: two separate apps to build and maintain, and the Windows developer can't build the iOS app at all.
- **Unity** — rejected: built for games; ordinary app screens (forms, settings, charts) are awkward.

## Facts that shaped the decision

- **Performance** is equivalent for this app in Flutter and React Native. Lag would come from design mistakes, such as redrawing everything on each touch point, not from the framework.
- **Only Macs can run a virtual iPad** (the iOS Simulator comes with Xcode, which is macOS-only). This is true for every framework. Everyone can use a virtual Android tablet.
- **Cross-platform dev consistency (Mac + Windows) is a setup problem, not a framework one.** Python venvs don't apply here. We pin the Flutter SDK version (FVM, `.fvmrc`), commit `pubspec.lock`, normalize line endings (`.gitattributes`), write helper scripts in Dart rather than shell, and let CI be the referee.
- **Later features (auth, cloud database, encryption) work about equally in either framework.** Firebase and Supabase support both. Most are out of MVP scope anyway: no cloud accounts and no HIPAA infrastructure.

## Consequences

- **The Windows developer tests on the Android emulator or a real Android tablet daily.** iPad checks go through the Mac teammates or a TestFlight build, which needs a $99/yr Apple Developer account.
- **Real-finger testing on a physical tablet is required** for anything involving metrics. Mouse input in an emulator doesn't resemble patient movement.
- **The whole team must learn enough Dart to review AI-written code.**
- **A future clinician web dashboard would most likely be a separate app (and probably a separate repo).** It would share a data contract (e.g. a JSON schema) with this app, not code.
- **Open question:** Flutter doesn't expose iOS "coalesced" Apple Pencil samples (up to 240 Hz) out of the box. Confirm with the OT advisors whether that level of tracing detail matters.
