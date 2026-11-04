import SwiftUI

struct BalloonSetupView: View {
    @Binding var repetitions: Int
    let onStart: () -> Void
    @State private var showsSettings = false

    var body: some View {
        GeometryReader { geometry in
            let sideBySide = geometry.size.width >= 700 && geometry.size.width > geometry.size.height
            let cardHeight = sideBySide
                ? max(320, min(480, geometry.size.height - 210))
                : CGFloat(340)

            ScrollView {
                VStack(spacing: 24) {
                    header

                    if sideBySide {
                        HStack(spacing: 40) {
                            balloonCard(height: cardHeight)
                            repetitionCard(height: cardHeight)
                        }
                        .frame(maxWidth: 1040)
                    } else {
                        VStack(spacing: 24) {
                            balloonCard(height: cardHeight)
                            repetitionCard(height: cardHeight)
                        }
                        .frame(maxWidth: 520)
                    }

                    Button(action: onStart) {
                        Text("Start Now")
                            .font(.custom("PaytoneOne-Regular", size: 28, relativeTo: .title))
                            .foregroundStyle(Color("Ivory"))
                            .frame(maxWidth: .infinity, minHeight: 58)
                            .background(Color("OliveGreen"), in: Capsule())
                            .overlay {
                                Capsule().stroke(Color("Ivory"), lineWidth: 2)
                            }
                            .contentShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: 380)
                    .accessibilityHint("Starts a balloon session with the selected number of repetitions.")
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height)
            }
        }
        .background(Color("WarmCream").ignoresSafeArea())
        .sheet(isPresented: $showsSettings) {
            settings
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("H.A.N.D.S")
                    .font(.custom("PaytoneOne-Regular", size: 30, relativeTo: .largeTitle))
                    .foregroundStyle(Color("ForestSage"))
                Text("Balloon Practice")
                    .font(.custom("PaytoneOne-Regular", size: 24, relativeTo: .title2))
                    .foregroundStyle(Color("Charcoal"))
            }
            Spacer(minLength: 16)
            Button {
                showsSettings = true
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color("ForestSage"))
                    .frame(width: 64, height: 64)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Practice settings")
        }
    }

    private func balloonCard(height: CGFloat) -> some View {
        VStack(spacing: 16) {
            Spacer(minLength: 8)
            BalloonIllustrationView(
                isInteractive: false,
                bodyWidth: min(180, height * 0.38)
            )
            Spacer(minLength: 8)
            Text("Touch the balloon")
                .font(.custom("PaytoneOne-Regular", size: 24, relativeTo: .title2))
                .foregroundStyle(Color("ForestSage"))
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color("Ivory"), in: RoundedRectangle(cornerRadius: 32))
    }

    private func repetitionCard(height: CGFloat) -> some View {
        VStack(spacing: 20) {
            Spacer(minLength: 0)
            Text("Number of repetitions")
                .font(.custom("PaytoneOne-Regular", size: 24, relativeTo: .title2))
                .multilineTextAlignment(.center)
                .foregroundStyle(Color("Charcoal"))

            Text("\(repetitions)")
                .font(.custom("PaytoneOne-Regular", size: 48, relativeTo: .largeTitle))
                .foregroundStyle(Color("Charcoal"))
                .frame(width: min(180, height * 0.38), height: min(180, height * 0.38))
                .background(Color("WarmCream"), in: RoundedRectangle(cornerRadius: 28))
                .accessibilityLabel("\(repetitions) repetitions")
                .accessibilityAddTraits(.updatesFrequently)

            HStack(spacing: 16) {
                repetitionButton(symbol: "minus", label: "Decrease repetitions", disabled: repetitions <= 1) {
                    repetitions = max(1, repetitions - 1)
                }
                repetitionButton(symbol: "plus", label: "Increase repetitions", disabled: repetitions >= 30) {
                    repetitions = min(30, repetitions + 1)
                }
            }
            .padding(.horizontal, 16)
            .background(Color("WarmCream"), in: Capsule())
            Spacer(minLength: 0)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .background(Color("Ivory"), in: RoundedRectangle(cornerRadius: 32))
    }

    private func repetitionButton(
        symbol: String, label: String, disabled: Bool, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(Color("Charcoal").opacity(disabled ? 0.3 : 1))
                .frame(width: 60, height: 50)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel(label)
    }

    private var settings: some View {
        VStack(spacing: 28) {
            Text("Practice settings")
                .font(.custom("PaytoneOne-Regular", size: 28, relativeTo: .title))
            Stepper("Repetitions: \(repetitions)", value: $repetitions, in: 1...30)
                .font(.custom("PaytoneOne-Regular", size: 20, relativeTo: .headline))
            Button("Done") {
                showsSettings = false
            }
            .font(.custom("PaytoneOne-Regular", size: 20, relativeTo: .headline))
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .foregroundStyle(Color("Charcoal"))
        .background(Color("WarmCream"))
        .tint(Color("OliveGreen"))
        .presentationDetents([.medium])
    }
}

#Preview {
    BalloonSetupView(repetitions: .constant(5), onStart: {})
}
