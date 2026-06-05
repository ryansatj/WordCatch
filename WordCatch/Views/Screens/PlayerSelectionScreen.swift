//
//  PlayerSelectionScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//


import SwiftUI

struct PlayerSelectionScreen: View {
    var onBack: () -> Void = {}
    var onSelect: (GameMode) -> Void = { _ in }

    var body: some View {
        ZStack {
            Image(.lanscapePolos)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Who's playing today?")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(Color("BrownBrand"))
                    Text("Tap a mode below, then Continue")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

                HStack(spacing: 14) {
                    RoleButton(variant: .playerSelect,
                               width: 300,
                               height: 250,
                               action: { onSelect(.solo) }) {
                        modeButtonContent(title: "Single Player",
                                          description: "Play by yourself",
                                          image: "MascotFace")
                    }

                    
                    
                    RoleButton(variant: .primary,
                               width: 400,
                               height: 250,
                               action: { onSelect(.duo) }) {
                        modeButtonContent(title: "Duo",
                                          description: "Invite a partner",
                                          image: "TwoFaceMascot")
                    }
                }

                Spacer()
            }
        }
        .onAppear { OrientationManager.shared.lockLandscape() }
    }

    // MARK: - Mode button content

    private func modeButtonContent(title: String,
                                   description: String,
                                   image: String) -> some View {
        VStack(spacing: 8) {
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(description)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .opacity(0.7)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 10)
    }
}

#Preview(traits: .landscapeRight) {
    PlayerSelectionScreen()
}
