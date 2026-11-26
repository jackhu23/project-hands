# PRD: Carle Health Redesign

## Problem Statement

The app works, but it still looks like the original prototype: an olive-and-cream theme, a bare Home screen of two square buttons, a setup screen with a hidden settings sheet, a run screen with Home and Finish buttons a Patient can hit by accident, and a separate History page reached from Home. It doesn't look like a Carle Health product. Nothing on screen tells a Patient what to do today or shows them how to do an Exercise. Destructive controls such as "Clear all data" sit where a Patient can reach them. The design team has approved a full redesign (Direction C, "Carle Health, full colour"). It should be built before any more features, so new screens are built in the new style rather than restyled later.

Some of the design (the therapist's Plan, Therapist mode, the therapist note) depends on decisions the OTs haven't made yet. Teammates and the people the app is demoed to must be able to tell what is built from what isn't.

## Solution

Rebuild every screen to match the approved mockups: Carle teal gradients, red uppercase labels, red line icons, Nunito type and the Carle Health logo. Home becomes "Today's plan" with Exercise cards. Each Exercise gets its own hub with a **Practice** tab (watch the Exercise Demo, set up the run, Start) and a **My progress** tab (Accuracy, Reaction Time, runs completed, an Accuracy-over-time chart, recent runs). The Exercise Run moves onto a branded stage with a progress pill and a single Pause button. Pause opens a menu with *Keep going*, *Watch the demo again* and *End this run*. A finished run ends on a "Well done!" screen.

Parts that depend on future work (the Plan, Therapist mode, the therapist note, Tracing) appear in their final place as clear **empty states**, never as sample data. Every section that loads data shows a **loading skeleton** while it waits and a "Couldn't load this" message with *Try again* if the data doesn't arrive. That's ready for the cloud backend. Short motion (staggered entrances, counting numbers, growing chart columns, page transitions, a shining balloon with a swaying string) makes the app feel finished. All of it respects the system "reduce motion" setting.

## User Stories

### Look and feel

1. As a Patient, I want the app to look like the rest of Carle Health, so that I trust it as part of my care.
2. As a Patient, I want large, bold, high-contrast text, so that I can read it from arm's length.
3. As a Patient with limited fine motor control, I want every button at least 56 px and primary buttons 84 px tall, so that I can hit them reliably.
4. As a Patient, I want the app to stay in landscape, so that the layout doesn't jump when the tablet tilts.
5. As a Patient, I want the app to fit my tablet whatever its size, so that nothing is cut off or overlapping.
6. As a Patient, I want screens and cards to ease in, so that the app feels calm and polished.
7. As a Patient who is sensitive to motion, I want all decorative motion to stop when "reduce motion" is on, so that the app doesn't make me uncomfortable.
8. As a teammate, I want every colour, gradient, size and text style to come from one theme, so that screens stay consistent and nobody hard-codes colours.

### Home

9. As a Patient, I want Home to open on "Today's plan" with today's date, so that I know where to start.
10. As a Patient, I want to see my Patient ID on Home, so that I know the tablet is set up for me.
11. As a Patient with no Plan set, I want Home to say "Your therapist hasn't set a plan yet" and let me pick any Exercise, so that I can still practise.
12. As a teammate demoing the app, I want unbuilt features shown as empty states rather than sample data, so that nobody thinks they work.
13. As a Patient, I want a card for each Exercise on Home, so that I can start one with a single tap.
14. As a Patient, I want Exercises that aren't ready shown as "Coming soon" cards I can't tap, so that I'm not sent to a broken screen.
15. As an OT, I want a Therapist button on Home, so that clinical and destructive settings sit apart from what the Patient uses.
16. As a teammate, I want the Therapist screen to hold "Clear all data" in debug builds, so that I can reset between demos without the Patient seeing it on Home.

### Balloon Touch hub: Practice tab

17. As a Patient, I want a header with a back button, the Exercise name and Practice / My progress tabs, so that I always know where I am.
18. As a Patient, I want to watch an Exercise Demo before I start, so that I know how to pop a balloon properly.
19. As a Patient, I want the Exercise Demo to show both a Pop and a Miss (lifting off outside the balloon), so that I understand a touch must start and end on the balloon.
20. As a Patient, I want "Show before every run" on by default, so that I'm reminded each time.
21. As a Patient who already knows how, I want to skip the Exercise Demo, so that I can start straight away.
22. As a Patient, I want to choose a Difficulty Level from four large buttons, each with a small picture of the Zones it covers, so that I can see what each level means.
23. As a Patient, I want the hub to remember my last Difficulty Level, so that I don't reset to Level 1 every time.
24. As a Patient, I want to set the number of balloons with large − and + buttons, from 1 to 30, so that I can choose how long to practise.
25. As a Patient, I want to see which finger to use ("Index · set by your therapist"), so that I use the right one.
26. As a Patient, I want one large Start button, so that starting is obvious.

### Exercise Run

27. As a Patient, I want the run on a calm branded stage with a clear play area, so that I can focus on the balloon.
28. As a Patient, I want a progress pill ("3 of 10"), so that I know how many balloons are left.
29. As a Patient, I want one Pause button and no Home or Finish buttons, so that I can't end a run by accident.
30. As a Patient, I want the balloon to shine and its string to sway gently, so that it feels alive, without the target moving.
31. As an OT, I want the balloon's body to stay 120 px wide, so that runs after the redesign are as hard as the runs already recorded.
32. As an OT, I want the Pop rule unchanged (touchdown and lift-off both on the balloon's body, not an Overlapping Touch), so that recorded Actions keep meaning the same thing.
33. As a Patient, I want a burst where the balloon pops, so that I know I did it.
34. As a Patient, I want a faint grey ring where my finger lifted off after a Miss, never red, so that I can see where I landed without feeling punished.
35. As a Patient, I want the screen to stay on during a run, so that it doesn't dim mid-reach.
36. As a Patient, I want system bars hidden during a run, so that I don't hit them by accident.
37. As a Patient, I want Pause to cover the screen with *Keep going*, *Watch the demo again* and *End this run*, so that my choices are clear.
38. As an OT, I want time spent paused, including time watching the Exercise Demo from Pause, left out of Reaction Time, so that the metric stays fair.
39. As a Patient, I want *End this run* to save the run as stopped and return me to the Practice tab, so that nothing is lost.
40. As a Patient, I want the run to pause by itself if the app leaves the screen, so that I don't come back to a timed-out balloon.
41. As a Patient, I want a "Well done!" screen when I finish, so that I feel rewarded.
42. As a Patient, I want *Go again* on that screen to start another run with the same settings, so that repeating is one tap.
43. As a Patient, I want *Back to today's plan* to take me Home.

### My progress tab

44. As a Patient, I want My progress inside the Exercise, so that I see progress for the Exercise I'm doing.
45. As a Patient, I want three cards for Accuracy, Reaction Time and Runs completed, so that I see how I'm doing at a glance.
46. As a Patient, I want to filter by Difficulty Level with chips (All levels, and only levels I've played), so that levels aren't mixed.
47. As a Patient, I want an Accuracy-over-time chart with one column per completed run, labelled with date and level, and the latest run highlighted, so that I can see my trend.
48. As a Patient, I want the numbers to count up and the columns to grow in, so that the page feels rewarding.
49. As a Patient, I want my latest four runs listed with date, level, duration and Accuracy.
50. As a Patient, I want a "From your therapist" card that says when there's no note yet, so that I know where notes will appear.
51. As a Patient, I want an empty state before my first run, so that a blank page isn't confusing.
52. As an OT, I want "See all runs" to open the full list of runs, including stopped runs marked "Stopped", so that the record is complete.
53. As an OT, I want the all-runs page to keep the detailed summary (Overlapping Touches per run, touch duration of popping Actions, run counts, per-level breakdown), so that nothing built in history is lost.
54. As an OT, I want each run to still open its run detail view, so that I can see how each Trial went.
55. As an OT, I want metrics to follow the glossary (Accuracy = Pops / (Pops + Misses); Reaction Time minus paused time), so that numbers mean the same everywhere.

### Loading and failure

56. As a Patient, I want a grey skeleton shaped like a section while it loads, so that the screen never looks broken or empty.
57. As a Patient, I want a section that hasn't loaded after 10 seconds to say "Couldn't load this" with *Try again*, so that I'm not left waiting forever.
58. As a Patient, I want one failed section not to block the rest of the screen, so that I can still start a run.
59. As a Patient, I want failure messages in neutral colours, never alarming red, so that I'm not worried.
60. As a teammate, I want every data-loading section to use the same loading wrapper, so that the cloud backend gets this behaviour for free.
61. As a Patient, I want to be told if my run couldn't be saved, so that a lost run isn't hidden.

## Implementation Decisions

- **Source of the design.** The handoff (design notes, the four reference mockups and the theme tokens) is committed under the docs as the design reference. Issues link to it. The mockups' `{{ }}` holes and `<sc-for>` / `<sc-if>` tags are mockup templating and aren't ported.
- **Theme.** The handoff's theme module replaces the current olive theme and becomes the only source of colours, gradients, sizes and text styles. Nunito (400/700/800/900) is bundled as font files rather than fetched at runtime, because clinic tablets may be offline. The theme drops the runtime font fetching. Paytone One and the old colours are removed.
- **Brand assets.** The Carle Health logos (dark, white, and the Carle Illinois co-brand) are bundled assets. Usage is approved by the team. They're low-resolution PNGs, to be replaced by official vectors when available.
- **New dependencies**, each because it improves what the Patient sees:
  - `flutter_svg` to draw the mockups' hand-drawn line icons exactly.
  - `flutter_animate` for entrances, count-ups, growing bars, the pop burst, the shine, the string sway and overlay fades.
  - `skeletonizer` for loading skeletons built from the real widgets.
  - `animations` for page and tab transitions.
  - `intl` for dates such as "THURSDAY · 26 NOVEMBER".
  - `wakelock_plus` to keep the screen on during a run.
- **Rejected dependencies.** `go_router`, `flutter_riverpod`, `fl_chart`, `google_fonts`, `lucide_icons_flutter` and `video_player` are not used. Navigation stays on `Navigator`, and the database is still passed through constructors. The chart is built from plain widgets, which match the mockup exactly.
- **Orientation and size.** The app is locked to landscape. Layouts are flexible, not a fixed 1280 × 800 canvas, because the clinic's tablet isn't chosen yet. Grids divide the width, the hero height is clamped, and text scales down rather than overflowing. Phones are not supported. The run screen uses immersive mode.
- **Shared widgets** (a widget library alongside the screens):
  - The gradient header, with back button, eyebrow, title, logo and pill tabs.
  - The eyebrow label, the label pill and the Exercise card (normal, highlighted and placeholder variants).
  - The Plan checklist with its empty state.
  - The Difficulty Level picker, with a Zone mini-diagram on each button.
  - The round stepper and the gradient button.
  - The run progress pill, the balloon, the pop burst and the Miss ring.
  - Stat cards (gradient, panel and outlined variants), the Accuracy chart and the therapist note card.
  - The Pause overlay and the Run complete screen.
  - The brand logo and the loading wrapper.
- **Screens and navigation:**
  - Home → Exercise hub (Practice | My progress) → Exercise Run → Run complete.
  - My progress → All runs → Run detail.
  - Home → Therapist.
  - The current Home, setup screen, post-run progress screen and History entry on Home are replaced. The old progress screen and the run screen's Home and Finish buttons are deleted.
- **Empty states for unbuilt features:**
  - The Plan checklist shows "Your therapist hasn't set a plan yet". No Exercise card is highlighted.
  - The therapist note card shows "No note from your therapist yet".
  - Tracing and the third Exercise are dashed, non-tappable placeholder cards ("COMING SOON", "COMING IN SPRING").
  - The Therapist screen is a stub holding "Clear all data", which stays debug-only and has no PIN yet.
  - The finger reads "Index" and is read-only.
  - No sample data appears anywhere.
- **Loading wrapper.** It's one widget that takes a future and a builder. It shows a `skeletonizer` skeleton of the section while waiting. After 10 seconds, or on an error, it shows "Couldn't load this" with a 56 px *Try again*, in `inkMuted`. It fails only its own section. Every section that loads data uses it: the hub's remembered Difficulty Level, My progress's stat cards, chart, recent runs and therapist note, and All runs and Run detail. A failed save of an Exercise Run is reported to the Patient, never swallowed.
- **Exercise Demo.** It's an in-app animation, not a video file. A highlighted fingertip moves onto a balloon on a mini stage, presses and lifts, and the real pop burst plays. Then a touch that lifts off outside the balloon shows the Miss ring. It reuses the run's balloon, burst and ring widgets, so it always matches the run.
  - It plays in the Practice tab's "Watch how" card.
  - When "Show before every run" is on (the default), Start plays it full-screen first, with *Skip*. The switch is remembered the same way the Difficulty Level is.
  - *Watch the demo again* in Pause plays it while the run stays paused, so its time is paused time.
  - Playing it records nothing.
- **Balloon.** It's drawn as in the mockup (radial gradient body, white highlight stroke, knot, string, drop shadow), scaled so the body stays 120 px wide with today's 1.25 aspect ratio, about 156 × 207 overall.
  - The existing pulse stays, including holding still while a finger is down and hit-testing against the scaled shape.
  - New: a periodic shine across the highlight and a gentle string sway. Both are paint-only, and the string isn't part of the hit area.
  - The mockup's float is not built.
  - Placement margins are unchanged.
- **Hit-testing and recording are unchanged.** Pop, Miss and Overlapping Touch keep their glossary definitions. Touches on Pause and the other controls, and touches while paused, still aren't Actions. Nothing in the schema changes.
- **Pop and Miss feedback.** A 200 px burst (red ring and eight teal rays) scales 0.4 → 1.5 and fades over 500 ms, then the next balloon appears, as today. A Miss shows a faint grey ring at the lift-off point for 300 ms. It doesn't delay the next balloon, and nothing new is recorded for it.
- **Motion rules.** Decorative motion lasts under 400 ms. During a run, only the burst, the Miss ring, the pulse, the shine and the string sway move. There's no confetti. Everything stops under "reduce motion", as the pulse does today.
- **My progress.**
  - The stat cards show Accuracy, Reaction Time and Runs completed, filtered by the selected level chip.
  - The chart has one column per completed run, in time order, labelled "17 Nov · L2". It uses the teal gradient, with the latest run in red and a value label on each column.
  - Recent runs lists the latest four, followed by "See all runs →".
  - All runs is the current history list and summary, restyled, with stopped runs marked. Run detail is the current per-Trial view, restyled.
  - New derived data, such as per-level filtering and the chart series, are pure functions next to the existing metrics.
- **Glossary.** CONTEXT.md now defines **Plan** and **Exercise Demo**. UI copy says "Today's plan" and never "prescription".

## Testing Decisions

- Tests go through public interfaces and check what the Patient sees: pump the widget, find text or semantics, tap. They never check private state or animation internals. Each change is built test-first.
- **Whole-app seam (main).** `pumpApp` starts the real app on an in-memory database. Through it, tests cover:
  - navigation between every screen;
  - each empty state;
  - the Difficulty Level picker and stepper;
  - Start with and without the Exercise Demo;
  - Pause → Keep going, Watch the demo again and End this run (which saves the run as stopped);
  - Run complete → Go again and Back to today's plan;
  - My progress filters and empty state;
  - All runs and Run detail;
  - the Therapist screen's "Clear all data".

  Prior art is the history, exercise, session and setup tests. Each issue updates the existing tests its screens break, for example finders that use "Start Now", "History" or `ListTile`.
- **Layout check.** Every screen is pumped at 1024 × 768, 1280 × 800 and 1366 × 1024 and must report no overflow. There are no golden-image tests: font rendering differs between Windows, macOS and CI.
- **Metrics seam.** Per-level filtering and the chart series are pure functions, tested on hand-built rows like the existing metrics tests. Accuracy and Reaction Time keep their existing tests.
- **Loading wrapper seam (new).** The wrapper is pumped directly:
  - with a future that never completes, it shows the skeleton, then "Couldn't load this" after 10 seconds of fake time;
  - with one that throws, it shows the failure;
  - with one that succeeds, it shows the content;
  - after a failure, *Try again* loads again.

  One app-level test uses a database whose history query never completes, to prove My progress goes through the wrapper.
- **Exercise Demo seam.** The demo widget is pumped with fake time. It plays, *Skip* dismisses it, it records nothing, and it stands still under "reduce motion".
- **Recording behaviour.** The existing Pop / Miss / Overlapping Touch and recording tests must keep passing on the new run screen. They prove the redesign didn't change the Pop rule or what's stored.
- Because the balloon animates forever, tests settle with fixed pumps rather than `pumpAndSettle`, as today.

## Out of Scope

- **The Plan**: storing it, editing it, deriving the hub defaults from it, marking items done, the "NEXT UP" highlight and the "All done for today" state. These come in PRD 0006.
- **Therapist mode**: the PIN, the Plan editor, the designated-finger setting, level and count limits, the Exercise Demo default, the float toggle, therapist notes, export, and a release-build "Clear all data". These come in PRD 0006.
- The balloon float animation.
- A filmed Exercise Demo video.
- A patient-friendly view that hides raw Accuracy, which waits on the OTs.
- Tracing and the third Exercise, beyond their placeholder cards.
- The cloud backend and sync. Only the loading and failure UI is built now.
- Phone layouts and left-hand mirroring.
- Sound.

## Further Notes

- Open questions for the OTs, carried into PRD 0006:
  - Who chooses the Difficulty Level and balloon count when a Plan exists?
  - Is there one tablet per Patient, or a "Who's practising?" screen?
  - Should Patients see Accuracy?
  - Should the float exist at all?
  - Does the app need left-hand support?
- The new Miss ring is the one change Patients will notice during a run. If the OTs think it changes how Patients behave, it's a one-line removal.
- Per ADR 0002, data stays in on-device SQLite even after the cloud arrives, so local sections will rarely show skeletons. The wrapper matters most for data the OT portal pushes down, such as the Plan and notes.
- The repository is public: screenshots and demo data must use synthetic Patient IDs.
