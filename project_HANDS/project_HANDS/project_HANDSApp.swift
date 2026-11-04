//
//  project_HANDSApp.swift
//  project_HANDS
//
//
//


import SwiftUI
import SwiftData

@main
struct project_HANDSApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(
            for: [
                StoredBalloonSession.self,
                StoredBalloonTarget.self
            ]
        )
    }
}
