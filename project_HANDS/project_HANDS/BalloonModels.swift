//
//  BalloonModels.swift
//  project_HANDS
//
// 
//

import Foundation


//one balloon presented during a session
struct BalloonTarget: Identifiable, Codable {
    enum Status: String, Codable {
        case active
        case completed
        case interrupted // stopped because of a pause, device lock, or app switch
        case unfinished // user finished the session but that balloon was still incomplete
    }
    let id: UUID
    let sessionId: UUID
    let repetitionNumber: Int
    
    
    // Position of the balloon body's center within the exercise area.
    // Measured in points, starting from the area's top-left corner.
    let centerX: Double
    let centerY: Double
    // Balloon body's size before applying the pulse animation.
    // These dimensions exclude the knot and shadow.
    let bodyWidth: Double
    let bodyHeight: Double
    
    
    let presentedAt: Date
    let presentedAtUptime: TimeInterval
    
    var completedAt: Date? = nil
    var status: Status = .active
}


//record of one attempt to touch a balloon
struct BalloonTouchAttempt: Identifiable, Codable {
    enum Outcome: String, Codable {
        case hit
        case miss
        case excluded
    }
    
    let id: UUID
    let targetId: UUID
    
    //finger first touched
    let downX: Double
    let downY: Double
    
    //finger lifted, optional
    let upX: Double?
    let upY: Double?
    
    let downTime: TimeInterval
    let endTime: TimeInterval
    
    let outcome: Outcome
    let exclusionReason: String?
}

struct BalloonSession: Identifiable {
    let id: UUID
    
    let patientId: UUID
    let plannedRepetitions: Int
    let startedAt: Date
    
    
    var targets: [BalloonTarget] = []
    var touchAttempts: [BalloonTouchAttempt] = []
    
}

