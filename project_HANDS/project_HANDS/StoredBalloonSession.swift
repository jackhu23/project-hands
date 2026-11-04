//
//  StoredBalloonSession.swift
//  project_HANDS
//
//
//

import Foundation
import SwiftData

@Model
final class StoredBalloonSession {

    @Attribute(.unique)
    var id: UUID

    var patientId: UUID
    var plannedRepetitions: Int

    var status: String

    var startedAt: Date
    var endedAt: Date?

    @Relationship(deleteRule: .cascade)
    var targets: [StoredBalloonTarget] = []

    init(
        id: UUID,
        patientId: UUID,
        plannedRepetitions: Int,
        status: String,
        startedAt: Date,
        endedAt: Date? = nil
    ) {
        self.id = id
        self.patientId = patientId
        self.plannedRepetitions = plannedRepetitions
        self.status = status
        self.startedAt = startedAt
        self.endedAt = endedAt
    }
}



@Model
final class StoredBalloonTarget {

    @Attribute(.unique)
    var id: UUID

    var sessionId: UUID
    var repetitionNumber: Int

    // position
    var centerX: Double
    var centerY: Double

    // size
    var bodyWidth: Double
    var bodyHeight: Double


    var presentedAt: Date
    var presentedAtUptime: TimeInterval
    var completedAt: Date?


    var status: String

    init(
        id: UUID,
        sessionId: UUID,
        repetitionNumber: Int,
        centerX: Double,
        centerY: Double,
        bodyWidth: Double,
        bodyHeight: Double,
        presentedAt: Date,
        presentedAtUptime: TimeInterval,
        completedAt: Date? = nil,
        status: String
    ) {
        self.id = id
        self.sessionId = sessionId
        self.repetitionNumber = repetitionNumber
        self.centerX = centerX
        self.centerY = centerY
        self.bodyWidth = bodyWidth
        self.bodyHeight = bodyHeight
        self.presentedAt = presentedAt
        self.presentedAtUptime = presentedAtUptime
        self.completedAt = completedAt
        self.status = status
    }
}
