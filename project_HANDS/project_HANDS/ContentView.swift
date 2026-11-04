//
//  ContentView.swift
//  project_HANDS
//
// 
//

import SwiftUI
import SwiftData

struct ContentView: View {

    @State private var sessionModel = BalloonSessionModel()

    // temporary patient ID for this demo.
    // reused while this view remains alive.
    @State private var demoPatientId = UUID()
    
    @State private var repetitions = 1
    @State private var showingSessionHome = false
    @Environment(\.modelContext)
    private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if let session = sessionModel.session {
                if showingSessionHome || session.status == .completed || session.status == .stopped {
                    BalloonSessionHomeView(
                        completed: sessionModel.completedTargets,
                        planned: session.plannedRepetitions,
                        canResume: session.status == .paused,
                        onResume: {
                            sessionModel.resumeSession()
                            showingSessionHome = false
                        },
                        onStartNew: {
                            if session.status == .paused {
                                sessionModel.finishSession()
                            }
                            sessionModel.returnHome()
                            showingSessionHome = false
                        }
                    )
                } else {
                    ExerciseScreen(
                        completedTargets: sessionModel.completedTargets, plannedRepetitions: session.plannedRepetitions, onHome: {
                            sessionModel.pauseSession()
                            showingSessionHome = true
                        },
                        activeTarget: sessionModel.activeTarget,
                        onAreaReady: { size in
                            sessionModel.presentNextTarget(
                                exerciseWidth: Double(size.width),
                                exerciseHeight: Double(size.height)
                            )
                        },
                        onTargetReleased: { targetId, size in
                            sessionModel.completeTarget(
                                targetId: targetId,
                                exerciseWidth: Double(size.width),
                                exerciseHeight: Double(size.height)
                            )
                        },
                        onFinish: {
                            sessionModel.pauseSession()
                            showingSessionHome = true
                        },
                        isPaused: session.status == .paused,
                        onPause: {
                            sessionModel.pauseSession()
                        },
                        onResume: {
                            sessionModel.resumeSession()
                        }
                    )
                    .padding(32)
                }
            } else {
                BalloonSetupView(repetitions: $repetitions) {
                    sessionModel.startSession(
                        patientId: demoPatientId,
                        repetitions: repetitions
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("WarmCream").ignoresSafeArea())
        .tint(Color("OliveGreen"))
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase != .active {
                sessionModel.pauseSession()
            }
        }
    }
}

#Preview {
    ContentView()
}
