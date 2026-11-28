# Spec: All runs screen — Option B ("Summary table + run table")

**Status:** approved · **Canvas reference:** artboard "All runs · B · Summary table + run table" (`carle2-all-runs-b.dc.html`)
**Theme:** `lib/theme/hands_theme.dart` (Direction C). Terms are as defined in `CONTEXT.md` (Exercise Run, Difficulty Level, Pop, Overlapping Touch, Accuracy).
**Replaces:** the old History page ("Summary of completed runs" + run list).

---

## 1. Purpose

Show every Exercise Run for one Exercise. At the top is a short per-level count summary. Below it is a scannable table that opens any run's summary.

**Removed from the summary** (shown elsewhere: Run summary and My progress):
- Accuracy
- Reaction Time
- Pop touch duration

The summary now only answers *how many runs, how many finished, how many stopped, and how often Overlapping Touches happen*.

## 2. Navigation

| From | Trigger | Route |
|---|---|---|
| My progress tab | "See all runs ›" link next to the "Recent runs" heading (**new**, min 48 px tall, `tealLink` 17/800) | push `/exercise/:id/runs` |
| This screen | Tap any table row | push `/exercise/:id/runs/:runId` (Run summary) |
| This screen | Header back button | pop → My progress |

## 3. Layout (1280 × 800 landscape)

```
┌────────────────────────────────────────────────────────────────────────────┐
│ HEADER 112  (←)  BALLOON TOUCH / All runs                    [Carle Health] │
├───────────────────────────┬────────────────────────────────────────────────┤
│ LEFT 380 px               │ RIGHT (flex)                                   │
│ ┌ SUMMARY ──────────────┐ │ Every run                 [All|Level 2|Level 4]│
│ │      All  L2   L4     │ │ ┌ DATE&TIME LEVEL POPPED ACC TIME STATUS › ┐  │
│ │ Runs   7   5    2     │ │ │ 27 Nov    Level 2 10 of 10 77% 0:31 [✓] › │  │
│ │ Compl. 6   5    1     │ │ │ 2:05 PM                                    │  │
│ │ Stopped1   0    1     │ │ │ …  (scrolls; header stays fixed)          │  │
│ │ Overl. 0.1 0.2 0.0    │ │ │                                            │  │
│ └───────────────────────┘ │ │                                            │  │
│ ┌ RUNS BY LEVEL ────────┐ │ │                                            │  │
│ │ Level 2 ████████   5  │ │ │                                            │  │
│ │ Level 4 ██▒▒       2  │ │ │                                            │  │
│ │ ■ Completed ■ Stopped │ │ └────────────────────────────────────────────┘  │
│ └───────────────────────┘ │                                                │
└───────────────────────────┴────────────────────────────────────────────────┘
```

- Page padding: 24 px top, 48 px sides, 26 px bottom. Column gap 24. Left column fixed at **380 px**; the right column flexes.
- Left column cards are stacked with a 16 px gap. The right column has the title row, a 12 px gap, then the table card, which fills the remaining height.

## 4. Components

### 4.1 Header
Same as the other exercise screens:
- Height 112, `HandsGradients.brand`, horizontal padding 48.
- Back button: 56 px circle, white @16 % fill, white @30 % border. Semantics label: "Back to my progress".
- Eyebrow: `BALLOON TOUCH` (14/800, letter-spacing 1.5, `#FFC9D2`). Use the Exercise name for other Exercises.
- Title: "All runs" (36/900, white).
- White Carle Health logo, 34 px tall, on the right.

### 4.2 Summary card (left, top)
- Card: white, 1.5 px `HandsColors.border` (`#D4DEE3`), radius 12, clip contents.
- Eyebrow `SUMMARY` (14/800, letter-spacing 1.5, `HandsColors.red`), padding 16/20/10.
- **Table:**
  - Columns: label, **All**, then one column per Difficulty Level that has at least one run, in ascending order (e.g. Level 2, Level 4).
    - If more than 3 levels have runs, the left column won't fit. Abbreviate the headers to `L1`–`L4` and reduce the value size to 20.
  - Header row: background `HandsColors.panel` (`#E5EBEE`), 14/800, `tealLink`, values right-aligned, padding 10/12 (outer cells 20).
  - Body rows: padding 14/12 (outer cells 20), 1 px `#E5EBEE` divider between rows.
    - Label: 16/700, `ink`.
    - Values: **24/900**, right-aligned. The **All** column is `tealLink`; level columns are `ink`.
    - "Stopped early" values greater than 0 are `redDeep` (`#A50D26`).

| Row label | Value |
|---|---|
| Runs | count of Exercise Runs (completed + stopped) |
| Completed | count with status `completed` |
| Stopped early | count with status `stopped` |
| Overlapping touches / run | (total Overlapping Touch Actions) ÷ Runs, 1 decimal; `—` when Runs = 0 |

The label "Overlapping touches / run" wraps onto two lines; that's expected.

### 4.3 Runs by level card (left, bottom)
- Background `panel`, radius 12, padding 16/20, gap 12.
- Eyebrow `RUNS BY LEVEL` (red).
- One row per level with runs:
  - Label "Level n" (64 px wide, 16/800).
  - Track: 18 px tall, radius 9, white, clip contents.
  - Count on the right (24 px wide, 16/900).
- Inside the track:
  - Completed segment: width = completed ÷ **max Runs of any level**, `HandsGradients.brandButton` horizontal.
  - Then the stopped segment: width = stopped ÷ the same max, `#F0A3B0`.
  - Scaling to the busiest level (not to 100 %) keeps levels comparable.
- Legend: 12 px squares, radius 3, `#00627C` "Completed" and `#F0A3B0` "Stopped" (14/700, `inkMuted`).
- Semantics: "Level 2: 5 runs, 5 completed, 0 stopped".

### 4.4 Title row (right)
- "Every run": 22/800, `tealHeading`.
- **Level filter**, a segmented control on the right:
  - Container: white, 2 px `#C5D3DA` border, radius 25, padding 3, gap 3.
  - Segments: `All levels`, then one per level with runs. Height **42** (the touch target is padded to ≥48 by the container), horizontal padding 16, radius 21, 15/800.
  - Selected: `#003A4E` fill, white text. Unselected: transparent, `tealLink` text.
- The filter affects **only the run table**. The summary always shows every column.
- Default: All levels. The choice is not saved between visits.

### 4.5 Run table (right)
- Card: 1.5 px `border`, radius 12, clip contents. Fills the remaining height.
- **Grid columns (shared by header and rows):** `1.6fr 0.8fr 1fr 0.8fr 0.7fr 1fr 24px`, gap 12, horizontal padding 20.
- **Header row** (stays fixed; only the body scrolls):
  - Background `panel`, padding 12/20, 13/800 caps, letter-spacing 1, `inkMuted`.
  - Columns: `DATE & TIME` · `LEVEL` · `POPPED` · `ACCURACY` (right-aligned) · `TIME` (right-aligned) · `STATUS` · (empty).

**Rows** (the whole row is one tap target, min height 64, padding 8/20):

| Cell | Content | Style |
|---|---|---|
| Date & time | Line 1: `d MMM` ("27 Nov"); add the year if it's not the current year. Line 2: time (tablet's 12/24 h setting) | 17/800 `ink`; 14/400 `inkMuted` |
| Level | `Level n` | 17/800 `tealLink` |
| Popped | `{pops} of {trialCount}` | 16/700 `inkMuted` |
| Accuracy | run Accuracy `n%`; `—` if Pops + Misses = 0 | 19/900 `tealLink`, right-aligned |
| Time | run duration `m:ss` (paused time excluded) | 16/700 `inkMuted`, right-aligned |
| Status | pill, height 30, padding 0/12, radius 15, 13/800 caps, letter-spacing 1 | `COMPLETED`: bg `#E1F0F3`, text `#00546B` · `STOPPED`: bg `#FCE4E8`, text `#A50D26` |
| › | chevron icon 22 px, stroke 2.5 | `#8FA9B4` |

- Zebra striping: even rows `#FFFFFF`, odd rows `#F7FAFB`. 1 px `#E5EBEE` divider under each row.
- Order: **newest first**. Header sorting is not in v1.
- Pressed state: row background `#E5EBEE` for 120 ms (no ripple splash colour beyond that).

## 5. Data

Load by Exercise ID from local storage (drift):

```
runs = ExerciseRun where exercise = :id, order by startedAt desc
```

For each run you need: `id, startedAt, endedAt, pausedMs, difficultyLevel, trialCount, status`, plus aggregated Action counts (`pops, misses, overlapping`). Compute them with **one grouped query**, not one query per row.

**Derived values:**
- `accuracy = pops / (pops + misses)`, or null.
- `duration = endedAt − startedAt − pausedMs`.
- Summary values per §4.2, computed over all runs and per level.

Put this in an `AllRunsViewModel` (Riverpod `allRunsProvider.family(exerciseId)`) and unit-test the summary maths. Overlapping touches per run must divide by **all** runs, including stopped ones.

## 6. States

| State | Behaviour |
|---|---|
| Loading | Skeleton blocks in the card shapes |
| No runs yet | Summary shows the All column with zeros and `—`; the Runs by level card is hidden; the table body shows "No runs yet. Your runs will appear here after you practise." plus a "Go to Practice" button (`GradientButton`, height 60) |
| Filter with no matches | Not possible: filters only list levels that have runs |
| Many runs (100+) | `ListView.builder` inside the table body; header stays fixed |
| One level only | Summary has the All and Level n columns (they match); the filter shows only "All levels" and that level |

## 7. Accessibility

- Rows: `Semantics(button: true, label: "{date} {time}, level {n}, {pops} of {N} popped, accuracy {a} percent, {m} minutes {s} seconds, {completed|stopped}. Opens run summary.")`.
- Summary table: give each value cell a `Semantics` label combining the row and column, e.g. "Stopped early, Level 4: 1".
- Filter segments: `Semantics(selected: …)` and `button: true`.
- All text meets 4.5:1 contrast on its background (checked against the theme tokens).
- Rows are at least 64 px tall; segment touch areas are at least 48 px.

## 8. Suggested Flutter structure

```
lib/features/runs/
  all_runs_screen.dart
  all_runs_view_model.dart        // summary + rows (unit tests)
  widgets/
    runs_summary_table.dart
    runs_by_level_bars.dart
    level_segmented_filter.dart
    run_table.dart                // fixed header + ListView.builder rows
    run_status_pill.dart          // shared with Run summary if useful
```

## 9. Acceptance checks

1. The summary shows only Runs, Completed, Stopped early and Overlapping touches / run. No Accuracy, Reaction Time or Pop touch duration appear anywhere in the summary.
2. Summary columns = All plus each level with runs, in ascending order.
3. Changing the level filter changes the table only, not the summary.
4. Rows are newest first. Tapping a row opens that run's Run summary, and back returns here with the filter kept.
5. Stopped runs show the pink `STOPPED` pill. Their Overlapping Touches are still counted in the summary.
6. The table header stays visible while the rows scroll.
7. The empty state appears when the Exercise has no runs.
8. My progress has a "See all runs ›" link that opens this screen.
