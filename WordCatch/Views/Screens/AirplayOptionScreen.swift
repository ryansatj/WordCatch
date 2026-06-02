import SwiftUI

struct AirplayOptionScreen: View {
    var onBack: () -> Void = {}
    var onContinue: () -> Void = {}

    @State private var iconVisible = false
    @State private var titleVisible = false
    @State private var buttonsVisible = false
    @State private var iconPulse = false

    var body: some View {
        ZStack {
            Image("LandscapeBg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack {
                HStack {
//                    IconButton(systemName: "chevron.left",action: onBack)
                    
                    IconButton2(systemName: "chevron.left",action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                Spacer()
            }

            VStack(spacing: 32) {
    
               
                Text("WordCatch is Best\non Larger Screen!")
                    .padding(12)
                    .font(.system(size: 52, weight: .heavy))
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color(red: 0.35, green: 0.13, blue: 0.0))
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 12)

                HStack(spacing: 16) {
                    RoleButton(
                        title: "Learn More",
                        size: .md,
                        variant: .secondary,
                        action: { /* belum ada isi */ }
                    )
                    .frame(maxWidth: 160)

                    RoleButton(
                        title: "continue",
                        size: .md,
                        variant: .primary,
                        action: onContinue
                    )
                    .frame(maxWidth: 220)
                }
                .opacity(buttonsVisible ? 1 : 0)
                .offset(y: buttonsVisible ? 0 : 16)
            }
            .padding(.horizontal, 80)
        }
        .onAppear {
            OrientationManager.shared.lockLandscape()
            runEntryAnimation()
        }
    }

    private func runEntryAnimation() {
        Task {
            withAnimation(.entrance) { iconVisible = true }
            try? await Task.sleep(for: .milliseconds(160))
            withAnimation(.fadeIn) { titleVisible = true }
            try? await Task.sleep(for: .milliseconds(150))
            withAnimation(.fadeInQuick) { buttonsVisible = true }

            withAnimation(.iconPulse.repeatForever(autoreverses: true)) {
                iconPulse = true
            }
        }
    }
}


#Preview(traits: .landscapeRight) {
    AirplayOptionScreen()
}
 
