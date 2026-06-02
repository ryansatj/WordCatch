//
//  GameOverlays.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//
//  Contents:
//    - CameraLoadingOverlay → spinner while AVCaptureSession warms up
//    - CountdownOverlay     → 3-2-1-GO pre-game countdown
//    - WinnerOverlay        → end-of-game reveal with Play Again / Exit
//

import SwiftUI

// MARK: - CameraLoadingOverlay

struct CameraLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color("OrangeBrand"))
                    .scaleEffect(1.5)

                Text("Preparing camera…")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text("Make sure you have good lighting")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - CountdownOverlay

struct CountdownOverlay: View {
    let value: Int?

    var body: some View {
        ZStack {
            if let v = value {
                Color.black.opacity(0.4).ignoresSafeArea()

                Text(v == 0 ? "GO!" : "\(v)")
                    .font(.system(size: 160, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: v == 0 ? [.yellow, .orange] : [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 10, y: 6)
                    .id(v)
                    .transition(.scale(scale: 1.7).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: value)
    }
}

// MARK: - WinnerOverlay

struct WinnerOverlay: View {
    /// 0 = Player 1, 1 = Player 2
    let winner: Int
    let onPlayAgain: () -> Void
    let onExit: () -> Void

    @State private var revealScale: CGFloat = 0.6
    @State private var revealOpacity: Double = 0
    @State private var emojiSpin: Double = 0

    private var winnerColor: Color { winner == 0 ? Color("OrangeBrand") : Color("BrownBrand") }
    private var winnerLabel: String { winner == 0 ? "Player 1 Wins!" : "Player 2 Wins!" }
    private var sideLabel: String { winner == 0 ? "orange" : "brown" }

    var body: some View {
        ZStack {
            Color.black.opacity(0.75).ignoresSafeArea()

            VStack(spacing: 18) {
                Text("🏆")
                    .font(.system(size: 72))
                    .rotationEffect(.degrees(emojiSpin))

                Text(winnerLabel)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text("\(sideLabel) side wins")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(winnerColor)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(winnerColor.opacity(0.18)))
                    .overlay(Capsule().strokeBorder(winnerColor.opacity(0.6), lineWidth: 1))
                    .padding(.bottom, 10)

                HStack(spacing: 14) {
                    RoleButton(title: "Exit",       size: .md, variant: .secondary, action: onExit)
                    RoleButton(title: "Play Again", size: .md, variant: .primary,   action: onPlayAgain)
                }
                .frame(maxWidth: 360)
            }
            .padding(.horizontal, 32)
            .scaleEffect(revealScale)
            .opacity(revealOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.6)) {
                revealScale = 1.0
                revealOpacity = 1.0
            }
            withAnimation(.spring(response: 1.0, dampingFraction: 0.5).delay(0.1)) {
                emojiSpin = 360
            }
        }
    }
}
