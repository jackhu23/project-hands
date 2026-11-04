import SwiftUI

struct BalloonSessionHomeView: View {
    let completed: Int
    let planned: Int
    let canResume: Bool
    let onResume: () -> Void
    let onStartNew: () -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 16) {
                    HStack {
                        Text("H.A.N.D.S")
                            .font(.custom("PaytoneOne-Regular", size: 30, relativeTo: .largeTitle))
                            .foregroundStyle(Color("ForestSage"))
                        Spacer()
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color("ForestSage"))
                            .accessibilityHidden(true)
                    }
                    .padding(.bottom, 8)

                    VStack(spacing: 16) {
                        HStack {
                            Text("Your progress")
                            Spacer()
                            Text("\(completed)/\(planned)")
                        }
                        .font(.custom("PaytoneOne-Regular", size: 24, relativeTo: .title2))
                        .foregroundStyle(Color("ForestSage"))

                        GeometryReader { bar in
                            ZStack(alignment: .leading) {
                                Capsule().fill(Color("SandBeige"))
                                Capsule().fill(Color("ForestSage"))
                                    .frame(width: bar.size.width * Double(completed) / Double(max(planned, 1)))
                            }
                        }
                        .frame(height: 14)
                        .accessibilityLabel("Progress")
                        .accessibilityValue("\(completed) of \(planned) balloons")

                        Spacer(minLength: 0)
                        BalloonIllustrationView(
                            isInteractive: false,
                            bodyWidth: min(140, geometry.size.height * 0.20)
                        )
                        Text(canResume ? "Session paused" : "Session finished")
                            .font(.custom("PaytoneOne-Regular", size: 25, relativeTo: .title2))
                            .foregroundStyle(Color("ForestSage"))
                        Text("You completed \(completed) of \(planned) balloons.")
                            .font(.custom("PaytoneOne-Regular", size: 17, relativeTo: .body))
                            .foregroundStyle(Color("ForestSage"))
                            .multilineTextAlignment(.center)
                        Spacer(minLength: 0)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .frame(height: max(400, min(510, geometry.size.height * 0.60)))
                    .background(Color("Ivory"), in: RoundedRectangle(cornerRadius: 30))

                    if canResume {
                        Button(action: onResume) {
                            Text("Resume Session")
                                .font(.custom("PaytoneOne-Regular", size: 22, relativeTo: .title2))
                                .foregroundStyle(Color("Ivory"))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color("OliveGreen"), in: Capsule())
                                .overlay { Capsule().stroke(Color("Ivory"), lineWidth: 2) }
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .frame(maxWidth: 300)
                        .accessibilityHint("Continue the paused session at the same balloon.")
                    }

                    Button(action: onStartNew) {
                        Text("Start New Session")
                            .font(.custom("PaytoneOne-Regular", size: 22, relativeTo: .title2))
                            .foregroundStyle(Color("ForestSage"))
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .overlay { Capsule().stroke(Color("OliveGreen"), lineWidth: 2) }
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: 300)
                    .accessibilityHint(canResume ? "End this session and choose a new one." : "Choose a new session.")
                }
                .font(.custom("PaytoneOne-Regular", size: 23, relativeTo: .title2))
                .padding(28)
                .frame(maxWidth: 1000, minHeight: geometry.size.height)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color("WarmCream").ignoresSafeArea())
    }
}
