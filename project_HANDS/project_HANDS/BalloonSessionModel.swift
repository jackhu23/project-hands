//
//  BalloonSessionModel.swift
//  project_HANDS
//
// 
//

import Foundation
import Observation

@Observable
class BalloonSessionModel {
    private(set) var session: BalloonSession? = nil
    func startSession(patientId: UUID, repetitions: Int) {
        session = BalloonSession(
            id: UUID(),
            patientId: patientId,
            plannedRepetitions: repetitions,
            startedAt: Date()
        )
    }
    
    
    func presentNextTarget(
        exerciseWidth: Double,
        exerciseHeight: Double,
        bodyWidth: Double = 120
    ) {
        // create only when a target when a session exists,
        // no target is currently active, and repetitions remain.
        guard var currentSession = session,
              activeTarget == nil,
              completedTargets < currentSession.plannedRepetitions
        else {
            return
        }

        // Match the proportions used by BalloonIllustrationView.
        let bodyHeight = bodyWidth * 1.25
        let knotHeight = bodyWidth * 0.085

        // Leave room for the balloon's largest animated size.
        let maximumScale = 1.03
        let edgeMargin = 24.0

        let horizontalInset =
            (bodyWidth / 2) * maximumScale + edgeMargin

        // Use extra space on both vertical edges to accommodate the knot.
        let verticalInset =
            (bodyHeight / 2 + knotHeight) * maximumScale + edgeMargin

        // Wait for an exercise area large enough to contain the balloon.
        guard bodyWidth > 0,
              exerciseWidth > horizontalInset * 2,
              exerciseHeight > verticalInset * 2
        else {
            return
        }

        let randomX = Double.random(
            in: horizontalInset...(exerciseWidth - horizontalInset)
        )

        let randomY = Double.random(
            in: verticalInset...(exerciseHeight - verticalInset)
        )

        let target = BalloonTarget(
            id: UUID(),
            sessionId: currentSession.id,
            repetitionNumber: completedTargets + 1,
            centerX: randomX,
            centerY: randomY,
            bodyWidth: bodyWidth,
            bodyHeight: bodyHeight,
            presentedAt: Date(),
            presentedAtUptime: ProcessInfo.processInfo.systemUptime
        )

        currentSession.targets.append(target)
        session = currentSession
    }
    
    
    
    func completeTarget(
        targetId: UUID,
        exerciseWidth: Double,
        exerciseHeight: Double
    ) {
        guard var currentSession = session,
              activeTarget?.id == targetId,
              let index = currentSession.targets.firstIndex(
                  where: { $0.id == targetId && $0.status == .active }
              )
        else {
            return
        }

        let bodyWidth = currentSession.targets[index].bodyWidth

        currentSession.targets[index].status = .completed
        currentSession.targets[index].completedAt = Date()

        session = currentSession

        presentNextTarget(
            exerciseWidth: exerciseWidth,
            exerciseHeight: exerciseHeight,
            bodyWidth: bodyWidth
        )
    }
    
    
    // this demo keeps its session only in memory
    func returnHome() {
        session = nil
    }

    var activeTarget: BalloonTarget? {
        session?.targets.last(where: { target in
            target.status == .active
        })
    }
    
    var completedTargets: Int {
        session?.targets.filter{target in
            target.status == .completed}.count ?? 0
    }
}
