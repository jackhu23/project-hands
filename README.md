# Project H.A.N.D.S. — Balloon Practice Demo

Project H.A.N.D.S. is an iPad-focused SwiftUI prototype for a balloon-touch exercise. This repository currently contains a working demo of the exercise flow.

## What the demo does

1. On the setup screen, choose **1–30 repetitions** and tap **Start Now**.
2. The exercise shows **one balloon at a time** at a random position within the exercise area.
3. The balloon gently changes size to draw attention. A touch that begins inside the balloon body and ends when the finger lifts completes one repetition. The next balloon then appears at a new position.
4. The screen shows the number of completed balloons and a progress bar.
5. **Pause** shows a paused overlay on the exercise screen. **Home** and **Finish** pause an unfinished session and open the progress page. From there, **Resume Session** continues the same in-memory session, while **Start New Session** returns to setup.
6. After the planned balloons are completed, the app opens the progress page with the final count and a **Start New Session** button.

## Run the app

1. Open `project_HANDS/project_HANDS.xcodeproj` in Xcode.
2. Select the `project_HANDS` app scheme and an iPad simulator or connected iPad.
3. Build and run the app.

The app target's deployment setting is iOS/iPadOS **18.6 or later**. The interface is designed primarily for iPad, although the Xcode target also includes iPhone.

## Main files

| File | Purpose |
| --- | --- |
| [ContentView.swift](project_HANDS/project_HANDS/ContentView.swift) | Chooses between setup, exercise, and progress screens and connects their button actions. |
| [BalloonSetupView.swift](project_HANDS/project_HANDS/BalloonSetupView.swift) | Displays the balloon introduction and repetition controls. |
| [ExerciseScreen.swift](project_HANDS/project_HANDS/ExerciseScreen.swift) | Displays the active exercise, progress, and pause controls. |
| [BalloonIllustrationView.swift](project_HANDS/project_HANDS/BalloonIllustrationView.swift) | Draws and animates the balloon and handles its touch-and-release interaction. |
| [BalloonSessionModel.swift](project_HANDS/project_HANDS/BalloonSessionModel.swift) | Creates targets and manages progress, pause, resume, and completion in memory. |
| [BalloonModels.swift](project_HANDS/project_HANDS/BalloonModels.swift) | Defines the session, target, and touch-attempt data types used by the exercise. |
| [BalloonSessionHomeView.swift](project_HANDS/project_HANDS/BalloonSessionHomeView.swift) | Displays paused or finished progress and the Resume/Start New actions. |
| [StoredBalloonSession.swift](project_HANDS/project_HANDS/StoredBalloonSession.swift) | Defines SwiftData session and target types for future persistence. |

Color assets are in `project_HANDS/project_HANDS/Assets.xcassets`. `project_HANDS/FontInfo.plist` registers `project_HANDS/project_HANDS/PaytoneOne-Regular.ttf`; its license is included in `project_HANDS/project_HANDS/PaytoneOne-OFL.txt`.

## Current data and scope

- The exercise session and its targets currently live **in memory**. The project registers SwiftData models, but it does not yet insert, save, fetch, or restore session records. Progress is lost when the app restarts.
- The participant ID is a temporary demo UUID. There is no patient sign-in, occupational therapist account, or prescription workflow.
- A `BalloonTouchAttempt` type exists, but the demo does not yet record every hit or miss. The displayed count is **completed balloons**, not a measured accuracy score.
- Cloud synchronization, and a session-history screen are not implemented yet. Gear icons outside the setup screen do not currently open settings.
