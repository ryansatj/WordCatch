import SwiftUI

struct OnboardingScreen: View {

    let onContinue: () -> Void

    var body: some View {

        ZStack {

            CelebrationBackground()

            VStack(spacing: 24) {

                Spacer()

                Image("MascotFace")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)

                Text("Welcome!")
                    .font(
                        .system(
                            size: 42,
                            weight: .black,
                            design: .rounded
                        )
                    )
                    .foregroundColor(Color("OrangeBrand"))

                Text("""
This game helps you learn English while keeping your mind and body active.

Play simple language games that support memory, focus, and gentle movement.

Our app is designed to be easy, comfortable, and enjoyable for seniors.
""")
                .font(
                    .system(
                        size: 22,
                        weight: .medium,
                        design: .rounded
                    )
                )
                .foregroundColor(Color("BrownBrand"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 60)

                Spacer()

                RoleButton(
                    title: "Get Started",
                    size: .xl,
                    action: onContinue
                )
                .frame(width: 260)

                Spacer()
                    .frame(height: 30)
            }
            .padding()
        }
        .onAppear {
            OrientationManager.shared.lockLandscape()
        }
    }
}

#Preview(traits: .landscapeRight) {
    OnboardingScreen {}
}
