import SwiftUI


struct BalloonBodyShape: Shape {
    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: p(0.5, 0))
        path.addCurve(to: p(1, 0.42), control1: p(0.82, 0), control2: p(1, 0.17))
        path.addCurve(to: p(0.5, 1), control1: p(1, 0.73), control2: p(0.7, 1))
        path.addCurve(to: p(0, 0.42), control1: p(0.3, 1), control2: p(0, 0.73))
        path.addCurve(to: p(0.5, 0), control1: p(0, 0.17), control2: p(0.18, 0))
        path.closeSubpath()
        return path
    }
}

private struct BalloonHighlight: Shape {
    func path(in rect: CGRect) -> Path {
        func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
            CGPoint(x: rect.minX + x * rect.width, y: rect.minY + y * rect.height)
        }
        var path = Path()
        path.move(to: p(0.53, 0.07))
        path.addCurve(to: p(0.8, 0.74), control1: p(0.98, 0.14), control2: p(0.99, 0.44))
        path.addCurve(to: p(0.53, 0.07), control1: p(0.86, 0.43), control2: p(0.77, 0.21))
        path.closeSubpath()
        return path
    }
}

private struct BalloonKnot: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.9),
                         control: CGPoint(x: rect.midX, y: rect.maxY * 0.65))
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: rect.maxY * 0.9),
                         control: CGPoint(x: rect.midX, y: rect.maxY * 1.1))
        path.addQuadCurve(to: CGPoint(x: rect.midX, y: rect.minY),
                         control: CGPoint(x: rect.midX, y: rect.maxY * 0.65))
        path.closeSubpath()
        return path
    }
}

private struct BalloonHalo: View {
    let animate: Bool
    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 20, paused: !animate)) { context in
            let wave = animate ? (sin(context.date.timeIntervalSinceReferenceDate * .pi / 2) + 1) / 2 : 0.0
            ZStack {
                Circle().fill(Color("WarmCream"))
                Circle()
                    .stroke(Color("OliveGreen").opacity(0.10 + wave * 0.08), lineWidth: 2)
                    .scaleEffect(1 + wave * 0.035)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}

struct BalloonIllustrationView: View {
    var isInteractive = false
    var bodyWidth: CGFloat = 176
    
    var onReleased: (() -> Void)? = nil
    
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.scenePhase) private var scenePhase
    @GestureState private var isPressed = false

    private var bodyHeight: CGFloat { bodyWidth * 1.25 }

    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                if !isInteractive {
                    BalloonHalo(animate: false)
                        .frame(width: bodyWidth * 1.65, height: bodyWidth * 1.65)
                }

    
                TimelineView(.animation(
                    minimumInterval: 1.0 / 30,
                    paused: reduceMotion || isPressed || scenePhase != .active
                )) { context in
                    let wave = (sin(context.date.timeIntervalSinceReferenceDate * .pi / 2) + 1) / 2
                    let scale = reduceMotion ? 1.0 : 0.98 + wave * 0.05

                    VStack(spacing: 0) {
                        BalloonBodyShape()
                            .fill(Color(isPressed ? "OliveGreen" : "ForestSage"))
                            .overlay {
                                BalloonHighlight()
                                    .fill(Color(isPressed ? "Ivory" : "OliveGreen"))
                                    .opacity(isPressed ? 0.22 : 1)
                                    .allowsHitTesting(false)
                            }
                            .overlay {
                                BalloonBodyShape()
                                    .stroke(Color("ForestSage"), lineWidth: isPressed ? 3 : 1)
                                    .allowsHitTesting(false)
                            }
                            .frame(width: bodyWidth, height: bodyHeight)
                            .shadow(color: Color("Charcoal").opacity(isPressed ? 0.08 : 0.16),
                                    radius: isPressed ? 3 : 9, x: 0, y: isPressed ? 2 : 6)
                            .contentShape(BalloonBodyShape())
                            .gesture( //detect and respond to how users interact
                                DragGesture(minimumDistance: 0)
                                    .updating($isPressed) { value, pressed, _ in

                                        let rect = CGRect(
                                            x: 0,
                                            y: 0,
                                            width: bodyWidth,
                                            height: bodyHeight
                                        )

                                        pressed = isInteractive &&
                                            BalloonBodyShape()
                                                .path(in: rect)
                                                .contains(value.startLocation)
                                    }
                                    .onEnded { value in

                                        let rect = CGRect(
                                            x: 0,
                                            y: 0,
                                            width: bodyWidth,
                                            height: bodyHeight
                                        )

                                        let beganInsideBalloon =
                                            BalloonBodyShape()
                                                .path(in: rect)
                                                .contains(value.startLocation)

                                        if isInteractive && beganInsideBalloon {
                                            onReleased?()
                                        }
                                    }
                            )
                            .allowsHitTesting(isInteractive)
                            .accessibilityLabel(isInteractive ? "Balloon touch preview" : "Balloon illustration")
                            .accessibilityHint(isInteractive ? "Touch the body, then lift your finger." : "")
    
                        BalloonKnot()
                            .fill(Color("ForestSage"))
                            .frame(width: bodyWidth * 0.085, height: bodyWidth * 0.085)
                            .allowsHitTesting(false)
                            .accessibilityHidden(true)
                    }
                    .offset(y: bodyWidth * 0.085 / 2)
                    .scaleEffect(scale)
                }
            }
            .frame(width: bodyWidth * 1.75, height: bodyWidth * 1.75)

        }
    }
}

