# Spec: Run Summary screen (Balloon Touch)

**Status:** design approved · **Mockup:** `reference_mockups/carle2-run-summary.dc.html` · **Theme:** `lib/theme/hands_theme.dart` (Direction C)

Terms in this spec are defined in `CONTEXT.md` (Exercise Run, Trial, Action, Pop, Miss, Overlapping Touch, Accuracy, Reaction Time, Difficulty Level, Zone). "Plan" is the new term in `DESIGN_HANDOFF.md` §2.

---

## 1. Purpose

One screen that explains **one Exercise Run**. It replaces the old "Well done!" screen and is the detail view for a run in My progress.

- **Patient:** a clear, encouraging result ("10 of 10 popped") and an easy way back to Today's plan.
- **Therapist:** per-balloon Reaction Time and where each balloon and Miss happened, to spot weak Zones or slow regions.

## 2. Entry points & navigation

| From | Trigger | Navigation |
|---|---|---|
| Exercise Run | Last Trial of the run ends (popped or timed out) | **Replace** the run route: `context.go('/exercise/balloon-touch/runs/:runId')`. Back must not return into the finished run. |
| Exercise Run → Pause → **End this run** | Patient ends early | Same route. The screen shows the *stopped* variant (§6). |
| My progress → Recent runs row | Tap anywhere on the row (≥56 px tall, chevron › on the right) | **Push**: `context.push('/exercise/balloon-touch/runs/:runId')` |

Exits:
- **Back** (header, top-left): to `/exercise/balloon-touch/progress`. From a push, pop instead.
- **Back to today's plan** (primary button): `context.go('/')`.
- **Go again** (secondary button): `context.go('/exercise/balloon-touch/run')` with the **same settings** as this run (level, Trial count, finger).

Show the Go again button only when the run is from today. For past runs, hide it (or relabel it "Practise at this level", open question §10).

Route param: `runId` (Exercise Run primary key). The screen loads everything from local storage by `runId`. Nothing is passed in memory, so the same screen works for both entry points and after an app restart.

## 3. Layout (1280 × 800 landscape)

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ HEADER 112px  brand gradient                                                  │
│ (←)  BALLOON TOUCH · RUN SUMMARY                              [Carle Health]  │
│      27 Nov 2026 · 14:05 · Level 2                                            │
├───────────────────────────────────────────────┬──────────────────────────────┤
│ LEFT 3/5                                       │ RIGHT 2/5                    │
│ ┌ Result banner (gradient) ──────────────────┐ │ ┌ Where the balloons were ─┐ │
│ │ BALLOONS POPPED        [PLAN ITEM DONE]    │ │ │  400×250 mini stage      │ │
│ │ 10 of 10           Index finger · 0:31     │ │ │  Zone outlines, dots,    │ │
│ └────────────────────────────────────────────┘ │ │  miss rings              │ │
│ ┌ ACCURACY ─────────┐ ┌ REACTION TIME ──────┐ │ │  legend: ● Pop  ○ Miss   │ │
│ │ 77%               │ │ 2.21 s              │ │ └──────────────────────────┘ │
│ │ 10 pops · 3 misses│ │ Average per balloon │ │ ┌ Pink detail card ────────┐ │
│ │ · L2 average 31%  │ │ · L2 average 2.66 s │ │ │ THIS RUN / BALLOON n     │ │
│ └───────────────────┘ └─────────────────────┘ │ └──────────────────────────┘ │
│ ┌ Reaction time per balloon ─────────────────┐ │                              │
│ │  bars 1…N (tap a bar or a balloon)         │ │ [ Back to today's plan → ]  │
│ └────────────────────────────────────────────┘ │ [        Go again        ]   │
└───────────────────────────────────────────────┴──────────────────────────────┘
```

- Page padding: 24 px top, 48 px sides, 28 px bottom. Column gap 24 px, vertical gaps 16–18 px.
- Grid: 5 equal columns. The left section spans 3, the right spans 2.
- The Reaction time chart card takes the remaining height in the left column. The buttons sit at the bottom of the right column.

## 4. Components

### 4.1 Header
- Height 112, `HandsGradients.brand`, horizontal padding 48.
- Back: 56 px circle, `white @16%` fill, `white @30%` 1 px border, arrow-left icon (white, 2.5 stroke). Semantics label: "Back to my progress".
- Eyebrow: `BALLOON TOUCH · RUN SUMMARY` (`HandsText.eyebrowOnTeal`). Use the Exercise's name for other Exercises.
- Title (36/900, white): `{date} · {time} · Level {n}`, for example "27 Nov 2026 · 14:05 · Level 2". Always the actual date, never "Today". Format with `intl`: `DateFormat('d MMM y')` and the tablet's 12/24 h setting for the time.
- Right: white Carle Health logo, 34 px tall.

### 4.2 Result banner
- `HandsGradients.brandButton`, radius 12, padding 22/28, shadow `0 8 20 rgba(0,58,78,.22)`.
- Left: eyebrow `BALLOONS POPPED` (redOnTeal), value `{pops} of {trialCount}` (54/900, white).
- Right, stacked and right-aligned:
  - Status pill (pink `#FCE4E8`, text `#A50D26`, 14/800 caps, height 34):
    - completed and linked to a Plan item → `PLAN ITEM DONE`
    - completed, no Plan item → `RUN COMPLETE`
    - ended early → `RUN STOPPED`
  - Meta line (17/700, `#D3E8EE`): `{Finger} finger · {m:ss} total` (run duration minus paused time).

### 4.3 Stat cards (2-up grid, gap 16)
Both cards: `HandsColors.panel` background, radius 12, padding 16/22.

| Card | Eyebrow (red caps) | Value (44/900, tealLink) | Sub line (15, inkMuted) |
|---|---|---|---|
| Accuracy | `ACCURACY` | `round(accuracy*100)%` | `{pops} pops · {misses} misses · Level {n} average {avg}%` |
| Reaction Time | `REACTION TIME` | `{meanRT:0.00} s` | `Average per balloon · Level {n} average {avg:0.00} s` |

- Leave out the "Level n average" part when there is no earlier completed run at that level. Don't show "0%".
- If there were Overlapping Touches, add `· {k} overlapping touches` to the Accuracy sub line. They are counted and shown but excluded from Accuracy.
- Don't colour the numbers green or red against the average. Keep it neutral. Patients may compare harshly.

### 4.4 Reaction time per balloon (chart)
- Card: white, 1.5 px `border`, radius 12, padding 16/22/12.
- Title "Reaction time per balloon" (20/800 tealHeading). Hint on the right: "Tap a bar or a balloon" (15, inkMuted).
- One column per Trial, in the order presented, gap 10, max column width 34, top radius 6, column height ∝ RT (the tallest column fills the plot height).
  - Default fill: `HandsGradients.barTeal`. Selected: `HandsGradients.barRed`. When one is selected, the others drop to 40 % opacity.
  - Value label above each column: RT to 1 decimal (13/800, inkMuted).
  - X labels: Trial number 1…N (13/700).
- A Trial that was **not popped** (timed out or run stopped): no column, a "–" label, and its number still shown.
- The whole column is the tap target, full plot height.
- Build: `fl_chart` `BarChart` with `BarTouchData` handling selection, or plain `Row` + `Flexible` + `GestureDetector` (simpler, and the mockup is plain boxes).

### 4.5 "Where the balloons were" map
- Card: white, 1.5 px `border`, radius 12, padding 16/18. Title 20/800 tealHeading.
- Mini stage: **400 × 250**, radius 10, `HandsGradients.stage` background. This is the run's play area scaled down; keep the aspect ratio of the real play area.
- **Zone outlines** (`CustomPainter`): ellipses centred on the stage using **the same Zone geometry as the game**, scaled. Zones 1–2 are drawn 1.5 px dashed `#8FA9B4` (dash 4, gap 5) with a 6 % teal fill. Zone 3's edge is dashed `#C5D3DA`. Zone 4 (outside) has no outline.
- **Pop dots:** 30 px circles at each balloon's **body centre**, `tealMid` fill, 2 px white border, Trial number in white 13/900.
  - Selected: `red` fill, 3 px white border plus a 3 px red outer ring. Others drop to 50 % opacity.
- **Not-popped Trials:** same position, white fill, 2 px `inkMuted` dashed border, number in inkMuted.
- **Miss markers:** 16 px rings, 2 px `#6B8490`, no fill, at each Miss Action's **lift-off** point. Not tappable. Not red: a Miss is information, not an error.
- **Overlapping Touches:** not drawn (they'd add clutter). They're counted in the stat card.
- Legend under the map (14/700 inkMuted): `● Pop` (tealMid swatch), `○ Miss (where the finger lifted)`.
- Coordinates: store positions **normalised to the play area (0–1)** at record time. Map with `x * 400, y * 250`. Never store raw pixels alone, because tablets differ.

### 4.6 Detail card (pink)
- `HandsColors.pinkCard`, radius 12, padding 14/18.
- **Nothing selected:** title `THIS RUN`, text `Your fastest balloon was number {i} ({rt} s){zoneHint}.`. zoneHint is ", near the centre" for Zone 1, otherwise ", in zone {z}".
- **Trial selected:** title `BALLOON {i}`, text `{rt} s to pop · Zone {z} · {missText}`:
  - 0 Misses on that Trial → `popped first try`
  - k Misses → `{k} miss before the pop` (plural "misses")
  - not popped → `not popped · {timed out | run stopped}`
- Selection: tapping a dot or bar selects that Trial. Tapping it again, or tapping the card, clears it. Selection is local UI state only and isn't saved.

### 4.7 Buttons (bottom of the right column)
- **Back to today's plan**: `GradientButton`, height 72, radius 12, 22/900 white, arrow-right icon.
  - If there's no Plan, the label is "Back to exercises".
- **Go again**: height 60, radius 12, 2 px `borderStrong`, tealDeep 19/800 (visibility rules in §2).

## 5. Data required

Load everything by `runId`. Minimum stored per entity:

**ExerciseRun:** `id, sessionId, exercise ('balloon_touch'), difficultyLevel, trialCount, finger, startedAt, endedAt, pausedMs, status ('completed' | 'stopped'), planItemId?`

**Trial:** `id, runId, index (1…N), zone (1–4), centerX, centerY (normalised 0–1 in the play area), appearedAt, outcome ('popped' | 'timed_out' | 'not_reached'), pausedMsDuringTrial`

**Action:** `id, trialId, downAt, upAt, downX, downY, upX, upY (normalised), pointerKind ('finger'|'stylus'), outcome ('pop'|'miss'|'overlapping')`

(**TouchSample** rows exist too, per CONTEXT.md, but this screen doesn't need them.)

### Derived values (compute in a `RunSummary` view model, unit-tested)

| Value | Definition |
|---|---|
| pops | count of Actions with outcome `pop` (= Trials popped) |
| misses | count of Actions with outcome `miss` |
| overlapping | count of Actions with outcome `overlapping` |
| accuracy | `pops / (pops + misses)`; null if both are 0 |
| rt(trial) | `popAction.downAt − trial.appearedAt − pausedMsDuringTrial` (touchdown of the popping Action, per CONTEXT.md) |
| meanRT | mean of rt over popped Trials |
| duration | `endedAt − startedAt − pausedMs` |
| levelAvgAccuracy | mean accuracy of **other completed runs** at the same Exercise + Level **before** this run's `startedAt` (pooled pops ÷ (pops + misses)); null if none |
| levelAvgRT | mean of those runs' meanRT; null if none |
| fastestTrial | popped Trial with the lowest rt (ties: lowest index) |
| missesPerTrial | Miss Actions grouped by trialId |

The "before this run" rule keeps a past run's summary the same over time, and it stops a new run from being compared with itself.

## 6. States & edge cases

| Case | Behaviour |
|---|---|
| Completed, from a Plan | Pill `PLAN ITEM DONE`; mark the Plan item done **when the run is saved**, not when this screen opens |
| Completed, no Plan | Pill `RUN COMPLETE`; primary button "Back to exercises" |
| Stopped early | Pill `RUN STOPPED`; banner `{pops} of {trialCount}`; Trials not reached shown as not-popped dots/"–" bars; Plan item **not** done |
| Zero Pops | Accuracy shows `0%` if there are Misses, `—` if there were no Actions; RT shows `—`; detail card: "No balloons popped this time." |
| First run at this level | Hide "Level n average …" fragments |
| Very long run (N > 20) | Columns narrow to fit (min 12 px); value labels hidden when columns are < 24 px wide (still shown in the detail card) |
| Loading | Skeleton blocks in the card shapes (no spinner) |
| Run not found | Message plus "Back to my progress" |

## 7. Accessibility

- All targets ≥ 56 px. Each map dot gets a 44 px invisible hit target around it (`SizedBox` + `GestureDetector`, `HitTestBehavior.opaque`). Bar columns span the full plot height.
- `Semantics` for each dot and bar: `"Balloon {i}, {rt} seconds, zone {z}, {first try | n misses | not popped}"`, `button: true`, `selected:` state.
- Don't rely on colour alone: selection also changes the ring and border, and the detail card text updates.
- Text contrast follows the theme tokens (all ≥ 4.5:1).
- Respect `MediaQuery.disableAnimations`: no fades, so selection changes instantly.

## 8. Motion

- On entry from a run: the result banner fades and slides up 12 px over 250 ms, the cards follow with 60 ms stagger, and the bars grow from 0 over 400 ms `easeOutCubic`. **Only when arriving from a run**; opening from My progress shows everything at once.
- Selection: 150 ms opacity/colour change.
- No confetti or celebration effects (the PDF asks for minimal animation).

## 9. Changes to other screens (already in the mockups)

1. **Exercise Run** (`carle2-run-stage.dc.html`): the old "Well done!" overlay is removed. When the last Trial ends, save the run and then go to the summary. Keep the pop burst on the final balloon (≈500 ms) before navigating, so the last Pop still gets feedback.
2. **My progress** (`carle2-progress.dc.html`): each Recent runs row is a tappable row (min height 56, chevron › at the right, `Semantics(label: "Open run summary, {date}, level {n}, {acc}%")`). Consider a "See all runs" list later; the tab only shows the latest 4.

## 10. Open questions

1. Is the map and per-balloon chart for patients, or only in Therapist mode? (Option: patients see the banner + 2 stat cards, therapists see everything.)
2. Does "Go again" count toward today's Plan, or is it an extra run?
3. For past runs, hide "Go again" or offer "Practise at this level"?
4. Should therapists be able to add a note to a specific run from this screen?
5. Tracing will need its own version: a path overlay instead of the dot map, and deviation instead of per-balloon RT. Keep the header, banner, stat cards and buttons shared.

## 11. Suggested Flutter structure

```
lib/features/runs/
  run_summary_screen.dart        // layout (§3)
  run_summary_view_model.dart    // derived values (§5) — unit tests here
  widgets/
    run_result_banner.dart
    run_stat_card.dart
    reaction_time_bars.dart
    balloon_position_map.dart    // CustomPainter zones + positioned dots
    trial_detail_card.dart
```

Riverpod: `runSummaryProvider.family<RunSummary, int>(runId)` reads from drift. The screen keeps `selectedTrialIndex` in local state (`StatefulWidget` or a `StateProvider.autoDispose`).

**Tests:**
- `RunSummary` maths: accuracy excludes Overlapping Touches; RT subtracts paused time; level average excludes the current and later runs; stopped run.
- Golden test at 1280×800 for completed, stopped and zero-pop states.
