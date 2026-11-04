//
//  ExerciseScreen.swift
//  project_HANDS
//
//
//

import Foundation
import SwiftUI

struct ExerciseScreen: View {
    
    let completedTargets: Int
    let plannedRepetitions: Int
    let onHome: () -> Void

    let activeTarget: BalloonTarget?
    let onAreaReady: (CGSize) -> Void
    let onTargetReleased: (UUID, CGSize) -> Void

    var body: some View {

        VStack(spacing: 20) {

            HStack(spacing: 24) {

                Text("H.A.N.D.S")
                    .font(.custom("PaytoneOne-Regular", size: 24, relativeTo: .title2))
                    .foregroundStyle(Color("ForestSage"))

                VStack(spacing: 8) {

                    HStack {
                        Text("Your progress")

                        Spacer()

                        Text("\(completedTargets) / \(plannedRepetitions)")
                            .fixedSize()
                    }
                    .font(.custom("PaytoneOne-Regular", size: 17, relativeTo: .subheadline))
                    .foregroundStyle(Color("Charcoal"))

                    ProgressView(
                        value: Double(completedTargets),
                        total: Double(max(plannedRepetitions, 1))
                    )
                    .tint(Color("ForestSage"))
                }
                .frame(width: 220)

                Spacer()

                Button(action: onHome) {
                    Label("Home", systemImage: "house.fill")
                        .font(.custom("PaytoneOne-Regular", size: 17, relativeTo: .body))
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                }
                .buttonStyle(.bordered)
                .accessibilityHint("Ends this demo session and returns to Start Practice.")

                Button {
                } label: {
                    Image(systemName: "pause.fill")
                }

                Button {
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }

            
            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color("WarmCream"))

                    if let target = activeTarget {
                        BalloonIllustrationView(
                            isInteractive: true,
                            bodyWidth: CGFloat(target.bodyWidth),
                            onReleased: {
                                onTargetReleased(target.id, geometry.size)
                            }
                        )
                        .id(target.id)
                        .position(
                            x: CGFloat(target.centerX),
                            y: CGFloat(target.centerY)
                        )
                    } else if plannedRepetitions > 0 && completedTargets >= plannedRepetitions {
                        Text("Practice complete")
                            .font(
                                .custom(
                                    "PaytoneOne-Regular",
                                    size: 28,
                                    relativeTo: .title
                                )
                            )
                            .foregroundStyle(Color("ForestSage"))
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height
                            )
                    }
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height
                )
                .onChange(of: geometry.size, initial: true) { _, newSize in
                    onAreaReady(newSize)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            
        }
        .padding(24)
        .background(Color("WarmCream").opacity(0.5))
    }
}

#Preview {
    ExerciseScreen(
        completedTargets: 0,
        plannedRepetitions: 3,
        onHome: {},
        activeTarget: nil,
        onAreaReady: { _ in },
        onTargetReleased: { _, _ in }
    )
}
