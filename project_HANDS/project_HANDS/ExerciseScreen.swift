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
    let onFinish: () -> Void
    let isPaused: Bool
    let onPause: () -> Void
    let onResume: () -> Void

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

                Button("Finish", action: onFinish)
                    .font(
                        .custom(
                            "PaytoneOne-Regular",
                            size: 17,
                            relativeTo: .body
                        )
                    )
                    .frame(minHeight: 44)
                    .buttonStyle(.bordered)

                Button(action: onHome) {
                    Image(systemName: "house.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(Color("OliveGreen"))
                        .frame(width: 48, height: 48)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Home")
                .accessibilityHint("Pauses practice and opens your progress page.")

                Button(action: onPause) {
                    Image(systemName: "pause.fill").frame(minWidth: 44, minHeight: 44)
                }
                .accessibilityLabel("Pause")
                .disabled(isPaused)

                Button {
                } label: {
                    Image(systemName: "gearshape.fill")
                }
            }


            GeometryReader { geometry in
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color("WarmCream"))

                    if isPaused {
                        VStack(spacing: 24) {
                            Text("Paused")
                                .font(
                                    .custom(
                                        "PaytoneOne-Regular",
                                        size: 28,
                                        relativeTo: .title
                                    )
                                )
                                .foregroundStyle(Color("ForestSage"))

                            Button("Resume", action: onResume)
                                .font(
                                    .custom(
                                        "PaytoneOne-Regular",
                                        size: 22,
                                        relativeTo: .title2
                                    )
                                )
                                .buttonStyle(.borderedProminent)
                                .controlSize(.large)
                                .tint(Color("OliveGreen"))
                        }
                        .padding(32)
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .background(
                            Color("Ivory"),
                            in: RoundedRectangle(cornerRadius: 28)
                        )
                    } else if let target = activeTarget {
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
        onTargetReleased: { _, _ in },
        onFinish: {},
        isPaused: false,
        onPause: {},
        onResume: {}
    )
}
