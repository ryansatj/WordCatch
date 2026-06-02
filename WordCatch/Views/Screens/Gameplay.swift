//
//  Gameplay.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//
//  Composes pieces from Component/Game/. Edit the visuals there;
//  this file only wires up the camera + game state + animations.
//

import SwiftUI

struct Gameplay: View {
    var onExit: () -> Void = {}

    @State private var manager = HandDetectionModel()
    @State private var game = Game()

    @State private var cameraReady = false
    @State private var countdownValue: Int? = nil
    @State private var showHUD = false

    var body: some View {
        GeometryReader { geo in
            ZStack {
                CameraPreviewView(session: manager.session).ignoresSafeArea()

                HandSkeletonView(hands: manager.tangan)

                PlayerDivider()

                wordsLayer(in: geo.size)

                if showHUD {
                    VStack {
                        GameTopBar(
                            scoreP1: game.ScoreP1,
                            scoreP2: game.ScoreP2,
                            winScore: game.winScore
                        )
                        Spacer()
                        GameExitButton(action: exit)
                            .padding(.bottom, 20)
                    }
                    .transition(.opacity)
                }

                if !cameraReady {
                    CameraLoadingOverlay()
                        .transition(.opacity)
                }

                CountdownOverlay(value: countdownValue)

                if let winner = game.winner {
                    WinnerOverlay(
                        winner: winner,
                        onPlayAgain: { restart(in: geo.size) },
                        onExit: exit
                    )
                    .transition(.opacity)
                }
            }
            .onAppear {
                OrientationManager.shared.lockLandscape()
                manager.start()
                game.hands = { manager.tangan }
                game.size = geo.size
                startSequence()
            }
            .onChange(of: geo.size) { _, s in game.size = s }
            .onDisappear {
                manager.stop()
                game.stop()
                OrientationManager.shared.lockPortrait()
            }
        }
    }

    private func wordsLayer(in size: CGSize) -> some View {
        ForEach(game.words) { w in
            FallingWordView(text: w.text, isLeftSide: w.x < size.width / 2)
                .position(x: w.x, y: w.y)
        }
    }

    private func startSequence() {
        Task {
            try? await Task.sleep(for: .milliseconds(900))
            withAnimation(.hudReveal) { cameraReady = true }
            try? await Task.sleep(for: .milliseconds(150))
            runCountdown()
        }
    }

    private func runCountdown() {
        Task {
            for n in [3, 2, 1, 0] {
                countdownValue = n
                try? await Task.sleep(for: .milliseconds(950))
            }
            countdownValue = nil
            withAnimation(.hudReveal) { showHUD = true }
            game.start()
        }
    }

    private func restart(in size: CGSize) {
        game.size = size
        game.start()
        runCountdown()
    }

    private func exit() {
        manager.stop()
        game.stop()
        onExit()
    }
}

#Preview(traits: .landscapeRight) { Gameplay()}
