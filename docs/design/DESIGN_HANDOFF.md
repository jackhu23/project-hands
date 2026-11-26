# HANDS — Design Handoff (Direction C: "Carle Health, full colour")

This is the approved redesign of the HANDS tablet app. Implement it **before** building more features, so all new screens use this theme.

> **For Claude Code:** read this file first, then `CONTEXT.md` (the project glossary; use its terms in code and copy). `lib/theme.dart` holds every token; don't hard-code colours elsewhere. The `reference_mockups/*.dc.html` files are the exact mockups: open them in a browser to see layout and spacing (logos load from `../../../assets/logos/`). The `{{ }}` holes and `<sc-for>` / `<sc-if>` tags in them are mockup templating, not something to port.

---

## 1. Target & assumptions

- **Platform:** Flutter (the current prototype is Flutter). Landscape tablet, designed at **1280 × 800 logical px**. Lock orientation to landscape.
- **Users:** a Patient (pseudonymous ID, e.g. `P-0142`) uses the app; an Occupational Therapist (OT) sets it up behind a lock.
- **Brand:** Carle Health. The UI copies the look of carle.org: teal gradient banners, red uppercase labels, cards with red line icons, Nunito type.
- **Logos:** `assets/logos/` holds PNGs cut from website screenshots for prototyping only (~344 px wide, soft at high DPI). **Get official vector logos and usage approval from Carle marketing (and the Carle Illinois College of Medicine if the co-brand is used) before any demo outside the team.**

## 2. Information architecture

```
Home (Today's plan)
├── Balloon Touch            ← each Exercise owns its own tabs
│   ├── Practice tab         (Watch how + run setup + Start)
│   │   └── Exercise Run     (full-screen; Pause menu holds End/Replay demo)
│   │       └── Run complete → Back to today's plan / Go again
│   └── My progress tab      (metrics + chart + recent runs for THIS exercise)
├── Tracing                  (same structure; to be built)
└── [Spring: 3rd Exercise]   (placeholder card)

Therapist (lock icon, top-right of Home) → OT-only settings: patient ID, Plan, finger,
difficulty limits, demo-video default, "Clear all data", float animation toggle.
```

Key changes from the old prototype:
1. **History is no longer on Home.** Progress lives inside each Exercise as a "My progress" tab.
2. **Destructive and clinical settings move behind the Therapist lock** ("Clear all data", designated finger).
3. **The run screen has no Finish/Home buttons.** Only Pause, which opens a menu: *Keep going* / *Watch the demo again* / *End this run*.
4. **Home shows Today's plan**, a checklist set by the therapist.

### New domain concept: Plan (add to CONTEXT.md)

> **Plan**: The list of Exercise Runs a therapist sets for a Patient for one day, each with an Exercise, a Difficulty Level and a number of Trials. Home shows it as "Today's plan".
> _Avoid_: Prescription (patients read it as medication), program, schedule.

Plan item states: `done` (ticked, struck through, muted), `next` (white row, red ring, "NEXT" label), `upcoming` (outline ring). Edge cases to design in code: **no plan set** (show "Your therapist hasn't set a plan yet" and let the patient pick any Exercise) and **all done** (headline "All done for today", item list stays visible, Exercise cards still usable).

On-screen copy uses "Today's plan". Never "prescription" in UI text.

## 3. Design tokens

All tokens live in `lib/theme/hands_theme.dart`. Summary:

| Token | Hex | Use |
|---|---|---|
| tealBright | `#0A8199` | gradient start |
| tealMid | `#00627C` | gradient middle, toggles |
| tealDeep | `#003A4E` | gradient end, text on white buttons |
| tealHeading | `#00657F` | card & section titles |
| tealLink | `#00546B` | links, metric numbers |
| red | `#C8102E` | eyebrow labels, line icons, video play button. **Not** for errors or Misses |
| redDeep | `#A50D26` | text on pink pills |
| redLight / redShadow | `#F0566F` / `#8E0B21` | balloon gradient |
| redOnTeal | `#FFC9D2` | eyebrow text on the gradient |
| ink | `#0B2D3C` | body text |
| inkMuted | `#3F5966` | secondary text |
| panel | `#E5EBEE` | highlighted card, progress-bar track |
| border / borderStrong / borderControl | `#D4DEE3` / `#8FA9B4` / `#C5D3DA` | card / highlighted card / chips |
| onTealMuted | `#D3E8EE` | secondary text on gradient |
| pinkPill / pinkCard | `#FCE4E8` / `#F9E6E9` | label pills, therapist note card |

**Brand gradient** (headers, hero, Start button, selected level, Pause, full-screen overlays): `105°`, `#0A8199 0% → #00627C 45% → #003A4E 100%`.

**Type:** Nunito (400/700/800/900). Hero 64/900 · screen title 38/900 · card title 34/800 · section 24/800 · body 19/400 (line-height 1.45) · eyebrow 16/800 ALL CAPS, letter-spacing 1.5 · metrics 50/900.

**Shape:** cards and buttons have a 12 px radius (matching carle.org, which is not very round). Pills are fully round. The run-screen play area has a 24 px radius.

**Touch targets:** minimum 56 px; primary buttons 84 px tall. Patients have limited fine motor control.

**Contrast:** all text pairs above pass WCAG AA 4.5:1 (white on the gradient's lightest stop is ≈4.6:1, so keep text on the gradient ≥ 18 px bold).

## 4. Screens

### 4.1 Home — `reference_mockups/carle2-home.dc.html`
- **Hero** (400 px tall, brand gradient, 56 px side padding):
  - Top row: white Carle Health logo (40 px tall), left. Right: patient chip (translucent white, person icon, "Patient P-0142") and **Therapist** button (`panel` background, lock icon).
  - Left block: pink pill with the date in caps ("THURSDAY · 26 NOVEMBER", no dot), **"Today's plan"** (64/900), then "Set by your therapist. **1 of 3 done**".
  - Right block: Plan checklist, 540 px wide, translucent panel; rows 54 px. Each row reads "Exercise · Level N · N balloons" (Tracing: "Tracing · 1 run").
- **Exercise cards** (3-column grid, overlapping the hero by ~70 px, 400 px tall, drop shadow):
  1. Balloon Touch: `panel` background with `borderStrong` border (highlighted because it's next). Red line balloon icon, eyebrow "NEXT UP · RUN 2 OF 2", title, "Level 2 · 10 balloons · index finger", "Start →" bottom-right.
  2. Tracing: white, eyebrow "LATER TODAY · 1 RUN", "Go →".
  3. Placeholder: dashed `borderStrong`, "COMING IN SPRING" / "New exercise". Not tappable.
- The highlighted card follows the Plan's `next` item.

### 4.2 Balloon Touch hub (Practice tab) — `reference_mockups/carle2-balloon-touch.dc.html`
- **Header** (brand gradient): round back button (56 px) → Home; "EXERCISE" eyebrow (redOnTeal) + "Balloon Touch" (38/900); white Carle Health logo right. Tabs as pills: active = white fill with tealDeep text, inactive = white outline.
- **Left card ("STEP 1 · WATCH HOW")**, `panel` background: video area with a gradient placeholder and a 100 px red play button; "Show before every run" switch (default on, therapist can override).
- **Right card ("STEP 2 · SET UP YOUR RUN")**:
  - Difficulty Level: 4 buttons (100 px tall), each with a mini nested-ellipse Zone diagram (rings beyond Level N drawn at 25 % opacity). Selected = brand gradient + shadow, white glyph. Default comes from the Plan.
  - Balloons stepper: round −/+ (62 px), value 42/900. Range 1–30. Default from the Plan.
  - "Finger: Index · set by your therapist" (read-only for patients).
  - **Start** button: full width, 84 px, brand gradient, "Start →".
- If the Plan fixes level and count, show them read-only (open question in §8).

### 4.3 Exercise Run — `reference_mockups/carle2-run-stage.dc.html` ("Branded stage")
- Whole screen = brand gradient. **Top band 104 px**: Carle Health logo top-left (in a 240 px slot); centred **progress pill** (420 × 64, white, "3 of 10" + 14 px track `panel` with a gradient fill); **Pause** pill right (white, tealDeep text, 64 px).
- **Play area:** inset 24 px left/right/bottom, top at 104 px; 24 px radius; radial `stage` gradient; subtle inner shadow. Balloons appear only inside this area.
- **Balloon:** 134 × 178 including string; body is a radial-gradient red ellipse (rx 46, ry 56 in a 120×160 viewBox) with a white highlight stroke; drop shadow `rgba(142,11,33,.25)`.
  - **Hit-testing (from CONTEXT.md):** an Action is a **Pop** only if touchdown *and* lift-off are both inside the balloon **body ellipse** (not the string or knot) and it isn't an Overlapping Touch. Use pointer events (`Listener`), not `GestureDetector.onTap`, so you get exact down/up positions, pressure, pointer kind (finger/stylus) for Touch Samples, and multi-pointer detection for Overlapping Touches.
  - Optional **float**: ±6 px vertical, 3 s ease-in-out loop. **Therapist toggle, default OFF for clinical runs.** A moving target affects the Pop rule and Reaction Time.
- **Pop feedback:** at the balloon centre, a 200 px burst (red ring r46 + 8 teal rays) scales 0.4→1.5 and fades out over 500 ms, then the next balloon appears. No sound by default (could be a setting).
- **Miss feedback (proposed):** faint grey ring at the lift-off point, 300 ms. Never red.
- **Pause** (also stops the Reaction Time clock, per CONTEXT.md): full-screen gradient overlay at 96 % opacity, "Paused" (52/900), buttons: **Keep going** (white, 88 px), **Watch the demo again** (outline), **End this run** (pink pill background, redDeep text). Ending saves the run as stopped.
- **Run complete:** full-screen brand gradient, pink "RUN COMPLETE" pill, "Well done!" (64/900), "You popped all N balloons.", buttons **Back to today's plan** (outline) and **Go again** (white). Logo at the bottom centre. Mark the Plan item done.

### 4.4 My progress tab — `reference_mockups/carle2-progress.dc.html`
- Same header as the hub with the "My progress" tab active.
- **Filter chips:** All levels / Level N (only levels with runs). Selected = tealDeep fill.
- **3 stat cards:** Accuracy (brand gradient card, white number), Reaction Time (`panel`), Runs completed (white, bordered). Eyebrow labels in red (redOnTeal on the gradient card).
- **Accuracy over time:** a column chart, one column per completed run in time order, with labels "17 Nov · L2". Columns use the teal gradient; the latest run uses the red gradient. Value label above each column.
- **Right column:** pink "FROM YOUR THERAPIST" note card (speech-bubble icon, text set in Therapist mode), then "Recent runs" (latest 4: date, "Level N · m:ss", accuracy %).
- Metrics must follow CONTEXT.md: **Accuracy = Pops / (Pops + Misses)**, Overlapping Touches excluded. **Reaction Time** = balloon appearing → touchdown of the popping Action, minus paused time.
- **Open question:** should patients see raw Accuracy? Low numbers can discourage. Consider a patient view ("balloons popped") and a therapist view (full metrics).

### 4.5 Therapist mode (not yet mocked)
Entered via the lock button. Should require a PIN. Holds: patient ID, today's Plan editor, designated finger, level/count limits, demo-video default, balloon float toggle, therapist note, export, **Clear all data** (with confirmation). Use the same tokens; it can be denser (OT-only).

## 5. Components to build (suggested `lib/widgets/`)

| Widget | Notes |
|---|---|
| `GradientHeader` | back button, eyebrow, title, logo, tab pills |
| `EyebrowLabel` | red ALL CAPS, 1.5 letter-spacing; `onTeal` variant |
| `LabelPill` | pink pill, redDeep caps text |
| `ExerciseCard` | icon, eyebrow, title, body, CTA link; `highlighted`, `placeholder` variants |
| `PlanChecklist` + `PlanItemRow` | done / next / upcoming states |
| `PillTabs` | Practice / My progress |
| `LevelPicker` | 4 buttons with a Zone mini-diagram (`CustomPainter`) |
| `RoundStepper` | −/+ with bounds |
| `GradientButton` | primary 84 px; also used for Pause |
| `RunProgressPill` | "x of N" + gradient bar |
| `BalloonTarget` | `CustomPainter` body + string, ellipse hit-test, optional float |
| `PopBurst` | 500 ms burst animation |
| `StatCard` | gradient / panel / outlined variants |
| `AccuracyChart` | column chart (fl_chart `BarChart` with gradient rods) |
| `TherapistNoteCard` | pink card |
| `PauseOverlay`, `RunCompleteScreen` | full-screen gradient |

Icons: thin **stroke** line icons (2–3 px) in red on cards, matching carle.org's red outline icons. No emoji, no filled clip-art.

## 6. Dependencies (Flutter)

Add with `flutter pub add <name>` to get current versions:

| Package | Why |
|---|---|
| `google_fonts` | Nunito. For offline clinic tablets, bundle the font files instead (`GoogleFonts.config.allowRuntimeFetching = false` + add Nunito TTFs under `assets/fonts/`). |
| `go_router` | Declarative routes: `/`, `/exercise/:id/practice`, `/exercise/:id/progress`, `/exercise/:id/run`, `/therapist` |
| `flutter_riverpod` | State: current patient, today's Plan, active run, settings |
| `drift` + `drift_flutter` (dev: `drift_dev`, `build_runner`) | Local SQLite for Sessions, Exercise Runs, Trials, Actions and Touch Samples (relational data and queries for progress). `sqflite` is the lighter alternative. |
| `shared_preferences` | Small settings (demo toggle, float toggle, therapist PIN hash) |
| `fl_chart` | Accuracy-over-time chart |
| `video_player` | "Watch how" demo videos (bundled assets) |
| `flutter_svg` | If you export icons and logo as SVG |
| `flutter_animate` | Pop burst, balloon float, overlay fades (or use plain `AnimationController`) |
| `intl` | Dates like "Thursday · 26 November" |
| `wakelock_plus` | Keep the screen on during a run |
| `lucide_icons_flutter` (optional) | Thin stroke icon set close to the mockups |
| `crypto` (optional) | Hash the therapist PIN |

Also:
- `SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight])`
- `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` on the run screen
- `CardThemeData` in `hands_theme.dart` needs Flutter ≥ 3.27. On older versions, use `CardTheme`.

## 7. Suggested implementation order

1. Add dependencies, assets (`pubspec.yaml`: `assets/logos/`), `hands_theme.dart`, orientation lock.
2. Build the shared widgets (§5), starting with `GradientHeader`, `ExerciseCard`, `GradientButton`.
3. Routes and screens: Home → Balloon Touch Practice → Run → Progress.
4. Move the existing balloon game logic into the Branded stage run screen; check that Pop, Miss and Overlapping Touch are classified as CONTEXT.md defines them.
5. Plan model and storage; drive Home and hub defaults from it.
6. Therapist mode (PIN, Plan editor, Clear all data).
7. Tracing, reusing the same shell (header, Practice/My progress tabs, stage run screen).

## 8. Open questions for the team / OTs

1. Does the patient or the therapist choose Difficulty Level and balloon count when a Plan exists?
2. Is one tablet per patient, or does the OT pick a patient each Session? The answer decides whether a "Who's practising?" screen is needed.
3. Should patients see Accuracy percentages?
4. Should the balloon float animation exist at all (Reaction Time validity)?
5. Left-hand support: mirror the Pause/progress positions?
6. Which brand rules and logo files do Carle and the College require, and who approves them?
