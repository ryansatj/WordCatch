import SwiftUI

struct AirplayOptionScreen: View {

    var body: some View {

        ZStack {

            Image("LandscapeBg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 32) {

                Spacer()

                Text("WordCatch is Best\non Larger Screen!")
                    .font(.system(size: 40, weight: .heavy))
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundColor(
                        Color(red: 0.35, green: 0.13, blue: 0.0)
                    )

                HStack(spacing: 24) {

                    Button {
                        // Placeholder
                    } label: {
                        Text("Learn More")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 180, height: 58)
                            .background(Color.orange)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }

                    Button {
                        // Placeholder
                    } label: {
                        Text("Continue")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 180, height: 58)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 80)
        }
        .onAppear {
            OrientationManager.shared.lockLandscape()
        }
        .onDisappear {
            OrientationManager.shared.lockPortrait()
        }
    }
}

#Preview {
    AirplayOptionScreen()
}
