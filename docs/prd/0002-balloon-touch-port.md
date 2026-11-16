# PRD: Balloon Touch Port

## Problem Statement

The only working Exercise, Balloon Touch, exists as a SwiftUI demo on the `feature/balloon-demo` branch. It runs only on iPads, so the Windows developer and every Android tablet are left out, and it lives outside the Flutter app that the foundation (PRD 0001) set up on `main`. The project lead wants the Exercise on the new stack, behaving the same on iPad and Android, before deciding what to improve.

## Solution

Port the demo to the Flutter app as it is, and only then improve it. The port copies the demo's screens, layout, colours, font, sizes and behaviour, including its quirks, so it can be compared side by side with the Swift demo. There are two deliberate changes from the demo:

1. **A home screen** with one Exercise button, because the app will offer more than one Exercise.
2. **A stricter popping rule:** an Action pops the balloon only if it both starts and ends on the balloon's body. The demo pops it wherever the finger lifts.

Everything stays in memory, as in the demo. Recording Actions and Touch Samples, storage, and metrics come in a later PRD.

The Swift demo stays untouched on `feature/balloon-demo` as the reference.

## User Stories

1. As a Patient, I want the app to open on a plain home screen with one large square button labelled with the Exercise name ("Balloon Touch"), so that I can start the Exercise in one tap.
2. As a Patient, I want a back button on the Balloon Touch setup screen (and the system back gesture) to return me to the home screen, so that I'm never stuck in setup.
3. As a Patient, I want to choose 1 to 30 balloons with large + and − buttons, so that the Exercise Run fits my energy that day.
4. As a Patient, I want the − button disabled at 1 and the + button disabled at 30, so that I can't pick an impossible count.
5. As a Patient, I want the setup screen's gear to open a settings sheet with the same balloon count, as in the demo.
6. As a Patient, I want the setup screen side by side in landscape and stacked in portrait, so that it fits however the tablet is held.
7. As a Patient, I want "Start Now" to start the Exercise with my chosen count.
8. As a Patient, I want one balloon at a time at a random spot in the exercise area, never clipped by the edges, so that I have to reach for each one.
9. As a Patient, I want the balloon to pulse gently, so that my eye is drawn to it.
10. As a Patient, I want the balloon to darken and stop pulsing while my finger is on it, so that I know my touch registered.
11. As a Patient, I want the balloon to pop only when my touch starts and ends on it, so that a slip off the balloon doesn't count.
12. As a Patient, I want a touch that starts outside the balloon, ends outside it, or is cancelled by the system to do nothing, so that stray contacts don't count.
13. As a Patient, I want a second finger that lands while the first is down to be ignored, so that only my deliberate touch counts.
14. As a Patient, I want the next balloon to appear at a new spot right after a pop, so that the Exercise Run keeps flowing.
15. As a Patient, I want to see "Your progress", a count of popped balloons out of the total, and a progress bar, so that I know how far I am.
16. As a Patient, I want Pause to replace the balloon with a "Paused" panel and a Resume button, so that I can rest.
17. As a Patient, I want the Exercise Run to pause when I lock the tablet or switch apps, so that the balloon isn't waiting while I'm away.
18. As a Patient, I want Home and Finish to pause the Exercise Run and open the progress page, as in the demo.
19. As a Patient, I want the progress page to show my count, a progress bar, a balloon illustration and "Session paused" or "Session finished", so that I know where I stand.
20. As a Patient, I want "Resume Session" on a paused progress page to return me to the same balloon, so that I can carry on.
21. As a Patient, I want "Start New Session" to return me to setup, so that I can begin again.
22. As a Patient, I want the progress page to open by itself once every balloon is popped, showing "Session finished".
23. As a Patient, I want the Exercise to look the same on an iPad and an Android tablet, so that switching tablets doesn't change the task.
24. As a HANDS developer, I want widget tests for the popping rule and the screen flow, so that iPad and Android follow the same rules by construction.

## Implementation Decisions

- **Faithful port.** Copy the demo's behaviour and look, including its quirks (listed below). The two exceptions are the home screen and the popping rule.
- **Same look on every OS.** One custom look on both, not Cupertino on iOS and Material on Android. Bundle the Paytone One font (OFL licence, include the licence file). Material icons stand in for the SF Symbols (gear, house, pause, plus, minus).
- **Colours**, copied from the demo:

  | Name | Hex |
  | --- | --- |
  | Charcoal | `#34372E` |
  | ForestSage | `#4E5946` |
  | Ivory | `#FFFCF6` |
  | OliveGreen | `#637B48` |
  | SandBeige | `#E9E1D0` |
  | WarmCream | `#F7F3EA` |

- **Home screen:** white background, one large square button in the top-left labelled "Balloon Touch". It's deliberately bare and will be redesigned later.
- **Balloon shape:** port the demo's Bézier body, highlight and knot exactly. The body is 1.25 times as tall as it is wide, and the knot is 0.085 times the body width.
- **Balloon size and placement:** body width 120 logical pixels, 24-pixel edge margin, insets sized for the largest pulse (×1.03) and the knot, and a uniformly random centre. Logical pixels match iOS points, so the numbers carry over directly.
- **Pulse:** scale 0.98 to 1.03 on a 4-second sine. It stops while pressed, while the app is in the background, and when the OS "reduce motion" setting is on.
- **Popping rule:** an Action pops the balloon if it starts on the balloon's body shape and lifts on the body shape, tested against the drawn shape (not a circle, no slack). The knot and halo don't count. Finger, stylus and mouse all count. Only the first pointer is tracked. A cancelled pointer does nothing.
- **Session state:** in memory only, mirroring the demo's model. States are running, paused, completed and stopped. Each Trial (balloon) is active, completed or unfinished, with its position, size and presentation time. Names follow CONTEXT.md (Session, Exercise Run, Trial, Patient), not the demo's (repetition, target, participant). The Patient ID is a temporary random ID, as in the demo.
- **Lifecycle:** leaving the foreground pauses a running Exercise Run.

### Known quirks carried over

These are copied on purpose and are candidates for the improvement round:

- Finish does the same as Home (pauses and opens the progress page). It doesn't end the Session.
- The gear button on the Exercise screen does nothing. The gear on the progress page is decoration.
- The setup gear's settings sheet repeats the + and − control.
- The "interrupted" and "unfinished" Trial states are never shown.
- The balloon is 120 logical pixels everywhere, so its physical size varies by tablet (about 19 to 23 mm).
- Nothing is saved: closing the app loses the Session.

## Testing Decisions

- Tests go through public interfaces: pump the app, find what the Patient sees, tap and drag with real gestures. They don't reach into private state.
- **The popping rule** gets one widget test per case: start and end on the body (pops), start outside, end outside, start on the knot, cancelled pointer, and a second finger.
- **Flow tests:** home → setup → Exercise → progress page, plus pause and resume, Home, Finish, completion, Start New Session, and going back from setup.
- **Placement:** the session logic is tested with a seeded random source to check that every balloon lies fully inside the area at the maximum pulse scale.
- **Layout:** the setup screen is pumped at landscape and portrait iPad sizes and an Android tablet size.
- **Device check:** no physical tablet is available yet. The project lead runs each pull request on the Android emulator before merging, and that pass also collects ideas for the improvement round.

## Out of Scope

- Recording Actions and Touch Samples, storage, metrics and real-time feedback.
- Fixing the known quirks above.
- Redesigning the home screen, and any second Exercise (Tracing).
- Physical sizing in millimetres and OT-set difficulty.
- Deleting, tagging or changing the `feature/balloon-demo` branch.

## Further Notes

- The Swift reference lives on `feature/balloon-demo` under `project_HANDS/project_HANDS/`. `BalloonIllustrationView.swift` and `BalloonSessionModel.swift` hold the numbers this port copies.
- The foundation PRD said one Exercise was due by mid-November 2026. This port is that Exercise.
