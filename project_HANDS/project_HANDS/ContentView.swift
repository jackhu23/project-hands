//
//  ContentView.swift
//  project_HANDS
//
// 
//

import SwiftUI

struct ContentView: View {

    @State private var sessionModel = BalloonSessionModel()

    // temporary patient ID for this demo.
    // reused while this view remains alive.
    @State private var demoPatientId = UUID()
    
    @State private var repetitions = 1

    var body: some View {
        Group {
            


            if let session = sessionModel.session {
                
                
                ExerciseScreen(
                    completedTargets: sessionModel.completedTargets,
                    plannedRepetitions: session.plannedRepetitions,
                    onHome: {
                        sessionModel.returnHome()
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
                    }
                )

                .padding(32)
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
    }
}

#Preview {
    ContentView()
}
