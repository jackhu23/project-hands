// HANDS design tokens, Direction C "Carle Health, full colour".
// Source of truth: docs/design/DESIGN_HANDOFF.md. Every value comes from the
// approved mockups; screens take colours, gradients, sizes and text from here.

import 'package:flutter/material.dart';

/// Colour tokens.
abstract final class HandsColors {
  // Brand teal (headers, primary actions, gradient)
  static const tealBright = Color(0xFF0A8199); // gradient start
  static const tealMid = Color(0xFF00627C); // gradient middle, toggles
  static const tealDeep = Color(
    0xFF003A4E,
  ); // gradient end, text on light buttons
  static const tealHeading = Color(0xFF00657F); // card and section titles
  static const tealLink = Color(0xFF00546B); // links, metric numbers

  // Carle red (labels, icons, highlights; never for errors or Misses)
  static const red = Color(0xFFC8102E); // eyebrow labels, line icons
  static const redDeep = Color(0xFFA50D26); // text on pink pills
  static const redDarkest = Color(0xFF7A0A1C); // body text on pink note card
  static const redLight = Color(0xFFF0566F); // balloon highlight
  static const redShadow = Color(0xFF8E0B21); // balloon shading
  static const balloonOutline = Color(0xFF3A0D16); // balloon outline, string
  static const redOnTeal = Color(0xFFFFC9D2); // eyebrow labels on the gradient

  // Neutrals
  static const ink = Color(0xFF0B2D3C); // body text
  static const inkMuted = Color(0xFF3F5966); // secondary text
  static const white = Color(0xFFFFFFFF);
  static const panel = Color(0xFFE5EBEE); // highlighted card, track backgrounds
  static const border = Color(0xFFD4DEE3); // card borders
  static const borderStrong = Color(0xFF8FA9B4); // highlighted or dashed card
  static const borderControl = Color(0xFFC5D3DA); // unselected chips
  static const onTealMuted = Color(0xFFD3E8EE); // secondary text on gradient
  static const shadow = Color(0x1F003A4E); // card drop shadow, tealDeep at 12%
  static const shadowStrong = Color(0x47003A4E); // selected level, Start: 28%

  // Translucent white on the gradient (patient chip, Plan panel)
  static const onTealFill = Color(0x1FFFFFFF);
  static const onTealLine = Color(0x47FFFFFF);

  // Tints
  static const pinkPill = Color(0xFFFCE4E8); // label pills, "End this run"
  static const pinkCard = Color(0xFFF9E6E9); // "From your therapist" card

  // Run screen play area (radial: centre to edge)
  static const stageCentre = Color(0xFFFFFFFF);
  static const stageMid = Color(0xFFF3F8FA);
  static const stageEdge = Color(0xFFE3EDF1);
}

/// Gradients.
abstract final class HandsGradients {
  /// Header, hero and full-screen gradient (CSS: linear-gradient(105deg, …)).
  static const brand = LinearGradient(
    begin: Alignment(-1.0, -0.27),
    end: Alignment(1.0, 0.27),
    colors: [HandsColors.tealBright, HandsColors.tealMid, HandsColors.tealDeep],
    stops: [0.0, 0.45, 1.0],
  );

  /// Two-stop version for buttons, selected chips, stat cards, bars.
  static const brandButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [HandsColors.tealBright, HandsColors.tealDeep],
  );

  /// Vertical bar fill for chart columns.
  static const barTeal = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [HandsColors.tealBright, HandsColors.tealDeep],
  );

  /// Latest-run chart column.
  static const barRed = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [HandsColors.redLight, HandsColors.red],
  );

  /// Balloon body (radial, highlight upper-left).
  static const balloon = RadialGradient(
    center: Alignment(-0.3, -0.4),
    radius: 0.8,
    colors: [HandsColors.redLight, HandsColors.red, HandsColors.redShadow],
    stops: [0.0, 0.55, 1.0],
  );

  /// Run-screen play area.
  static const stage = RadialGradient(
    radius: 0.9,
    colors: [
      HandsColors.stageCentre,
      HandsColors.stageMid,
      HandsColors.stageEdge,
    ],
    stops: [0.0, 0.6, 1.0],
  );
}

/// Spacing, radii, sizes (logical px, designed on a 1280×800 landscape tablet).
abstract final class HandsSizes {
  static const pagePadH = 48.0;
  static const heroPadH = 56.0;
  static const gap = 24.0;
  static const radiusCard = 12.0; // cards, buttons (Carle website style)
  static const radiusStage = 24.0; // run-screen play area
  static const radiusPill = 999.0;

  static const minTouch = 56.0; // nothing tappable smaller than this
  static const buttonPrimaryH = 84.0; // Start
  static const buttonSecondaryH = 68.0;
  static const stepperButton = 62.0;
  static const levelButtonH = 100.0;
  static const backButton = 56.0;

  static const gapXS = 8.0;
  static const gapS = 14.0;
  static const cardPad = 32.0;
  static const heroPadTop = 32.0;
  static const heroGap = 34.0; // top row to title block
  static const chipH = 52.0;
  static const pillPadH = 18.0;
  static const pillPadV = 8.0;
  static const planRowH = 54.0;
  static const dash = 6.0;
  static const borderW = 1.5;
  static const dashedBorderW = 2.0;
  static const shadowBlur = 30.0;
  static const shadowDy = 10.0;
  static const ctaIcon = 22.0;
  static const chipIcon = 22.0;
  static const entranceSlide = 0.08; // fraction of the card's height

  static const heroMaxH = 400.0;
  static const heroMinH = 320.0;
  static const cardOverlap = 70.0; // Exercise cards rise into the hero
  static const exerciseCardMaxH = 400.0;
  static const planMaxW = 540.0;
  static const logoH = 40.0;
  static const iconSize = 84.0; // red line icons on cards

  // Exercise hub (Balloon Touch mockup)
  static const headerPadTop = 24.0;
  static const headerPadBottom = 22.0;
  static const headerGap = 18.0; // title row to tabs, back button to title
  static const headerLogoH = 34.0;
  static const tabPadH = 26.0;
  static const hubPadTop = 30.0;
  static const hubPadBottom = 34.0;
  static const panelPad = 28.0;
  static const panelGap = 18.0;
  static const controlGap = 10.0;
  static const controlBorderW = 2.0;
  static const zoneDiagramW = 56.0;
  static const zoneDiagramH = 40.0;
  static const stepperValueW = 80.0;
  static const stepperIcon = 30.0;
  static const startIcon = 30.0;
  static const selectedShadowBlur = 16.0;
  static const selectedShadowDy = 6.0;

  // My progress (progress mockup)
  static const progressPadTop = 24.0;
  static const progressPadBottom = 30.0;
  static const progressGap = 20.0;
  // Below this tab height the tab scrolls: padding, chips and stat cards
  // take about 300 px, leaving progressLowerMinH for the chart.
  static const progressMinH = 600.0;
  static const progressLowerMinH = 300.0; // chart and Recent runs when it does
  static const filterChipPadH = 22.0;
  static const statPadH = 26.0;
  static const statPadV = 20.0;
  static const statShadowBlur = 20.0;
  static const statShadowDy = 8.0;
  static const chartPadTop = 20.0;
  static const chartPadBottom = 14.0;
  static const chartColumnGap = 18.0;
  static const chartColumnMaxW = 70.0;
  static const chartColumnMinW = 96.0; // a column and its gap, before scrolling
  static const chartColumnMinH = 6.0;
  static const chartValueH = 28.0; // value label above a column
  static const chartRadius = 8.0;
  static const chartAxisW = 2.0;
  static const noteGap = 14.0;
  static const sideCardPadH = 20.0; // therapist note and Recent runs
  static const notePadV = 16.0;
  static const noteIcon = 30.0;
  static const rowPadV = 7.0;

  // Run stage (run-stage mockup)
  static const runBandH = 104.0; // top band: logo, progress pill, Pause
  static const runBandPadH = 36.0;
  static const runLogoH = 30.0;
  static const runPillW = 420.0;
  static const runPillH = 64.0;
  static const runPillPadH = 24.0;
  static const runBarH = 14.0;
  static const pausePadH = 28.0;
  static const pauseIcon = 22.0;
  static const stageInset = 24.0; // play area to the screen's sides and bottom
  static const burst = 200.0; // Pop burst's box; shards fly past it
  static const missRing = 56.0;

  static const balloonW = 134.0;
  static const balloonH = 178.0; // includes string; hit area is the body only
}

/// Motion timings. Decorative motion stays under 400 ms.
abstract final class HandsMotion {
  static const entrance = Duration(milliseconds: 300);
  static const stagger = Duration(milliseconds: 80);
  static const countUp = Duration(milliseconds: 380); // numbers and columns
  static const burst = Duration(milliseconds: 500); // the next balloon waits
  static const missRing = Duration(milliseconds: 300);
  static const balloonLife = Duration(seconds: 3); // shine and string sway
}

/// Text styles, in the bundled Nunito.
abstract final class HandsText {
  static const font = 'Nunito';

  static TextStyle _n(
    double size,
    FontWeight w,
    Color c, {
    double? ls,
    double? h,
  }) => TextStyle(
    fontFamily: font,
    fontSize: size,
    fontWeight: w,
    color: c,
    letterSpacing: ls,
    height: h,
  );

  static final heroTitle = _n(
    64,
    FontWeight.w900,
    HandsColors.white,
    ls: -0.5,
    h: 1.05,
  );
  static final screenTitle = _n(38, FontWeight.w900, HandsColors.white);
  static final cardTitle = _n(34, FontWeight.w800, HandsColors.tealHeading);
  static final sectionTitle = _n(24, FontWeight.w800, HandsColors.tealHeading);
  static final body = _n(19, FontWeight.w400, HandsColors.ink, h: 1.45);
  static final bodyOnTeal = _n(22, FontWeight.w400, HandsColors.onTealMuted);
  static final eyebrow = _n(16, FontWeight.w800, HandsColors.red, ls: 1.5);
  static final eyebrowOnTeal = _n(
    14,
    FontWeight.w800,
    HandsColors.redOnTeal,
    ls: 1.5,
  );
  static final pill = _n(15, FontWeight.w800, HandsColors.redDeep, ls: 1.0);
  static final chip = _n(18, FontWeight.w800, HandsColors.white);
  static final button = _n(30, FontWeight.w900, HandsColors.white);
  static final buttonSmall = _n(20, FontWeight.w900, HandsColors.tealDeep);
  static final metric = _n(50, FontWeight.w900, HandsColors.tealLink);
  static final levelNumber = _n(24, FontWeight.w900, HandsColors.tealLink);
  static final stepperValue = _n(42, FontWeight.w900, HandsColors.ink);
  static final caption = _n(16, FontWeight.w400, HandsColors.inkMuted);
  static final tab = _n(18, FontWeight.w800, HandsColors.white);
  static final link = _n(20, FontWeight.w800, HandsColors.tealDeep);
  static final filterChip = _n(17, FontWeight.w800, HandsColors.tealLink);
  static final statLabel = _n(15, FontWeight.w800, HandsColors.red, ls: 1.5);
  static final chartValue = _n(17, FontWeight.w900, HandsColors.ink);
  static final chartLabel = _n(14, FontWeight.w700, HandsColors.inkMuted);
  static final noteLabel = _n(
    14,
    FontWeight.w800,
    HandsColors.redDeep,
    ls: 1.5,
  );
  static final note = _n(17, FontWeight.w400, HandsColors.redDarkest);
  static final rowTitle = _n(16, FontWeight.w800, HandsColors.ink);
  static final rowValue = _n(19, FontWeight.w900, HandsColors.tealLink);
  static final runCount = _n(22, FontWeight.w900, HandsColors.ink);
}

/// App-wide ThemeData. Screens still use the gradients and tokens above.
final handsTheme = () {
  final base = ThemeData(useMaterial3: true, fontFamily: HandsText.font);
  return base.copyWith(
    scaffoldBackgroundColor: HandsColors.white,
    colorScheme: const ColorScheme.light(
      primary: HandsColors.tealMid,
      onPrimary: HandsColors.white,
      secondary: HandsColors.red,
      onSecondary: HandsColors.white,
      surface: HandsColors.white,
      onSurface: HandsColors.ink,
      outline: HandsColors.border,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: HandsColors.ink,
      displayColor: HandsColors.ink,
    ),
    cardTheme: CardThemeData(
      color: HandsColors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(HandsSizes.radiusCard),
        side: const BorderSide(color: HandsColors.border, width: 1.5),
      ),
    ),
    switchTheme: SwitchThemeData(
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? HandsColors.tealMid
            : HandsColors.borderControl,
      ),
      thumbColor: const WidgetStatePropertyAll(HandsColors.white),
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
  );
}();
