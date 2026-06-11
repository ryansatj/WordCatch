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
    enum EndFlowStep {
        case timeUp
        case score
        case learning
    }

    let mode: GameMode
    var onExit: () -> Void = {}

    @State private var manager = HandDetectionModel()
    @State private var game = Game()
    @State private var cameraReady = false
    @State private var countdownValue: Int? = nil
    @State private var showRoundHeader = false
    @State private var pregameRaised = false
    @State private var showHUD = false
    @State private var endFlowStep: EndFlowStep? = nil
    @State private var showTutorial = true
    @State private var tutorialCategory: WordCategory = .animals


    var body: some View {
        GeometryReader { geo in
            ZStack {
                CameraPreviewView(session: manager.session).ignoresSafeArea()
                HandSkeletonView(hands: manager.tangan)

                if mode == .duo {
                    PlayerDivider()
                }
                

                wordsLayer(in: geo.size)

                if showRoundHeader {
                    RoundHeader(seconds: game.remainingSeconds,
                                category: game.currentCategory.name,
                                raised: pregameRaised)
                        .transition(.opacity)
                }

                if showHUD {
                    PlayingHUD(mode: mode,
                               scoreP1: game.ScoreP1,
                               scoreP2: game.ScoreP2,
                               onExit: exit)
                        .transition(.opacity)
                }

                if !cameraReady {
                    CameraLoadingOverlay()
                        .transition(.opacity)
                }

                CountdownOverlay(value: countdownValue)

                if let endFlowStep {
                    endOverlay(for: endFlowStep, size: geo.size)
                        .transition(.opacity)
                }
                if showTutorial {
                    TutorialScreen(
                        mode: mode,
                        category: tutorialCategory,
                        hands: { manager.tangan },
                        size: geo.size,
                        onFinished: finishTutorial
                    )
                    .ignoresSafeArea()
                    .zIndex(5)
                    .transition(.opacity)

                    SkipButton(action: finishTutorial)
                        .zIndex(6)
                        .transition(.opacity)
                }
            }
            .onAppear {
                OrientationManager.shared.lockLandscape()
                manager.start()
                game.hands = { manager.tangan }
                game.size = geo.size
                manager.gameMode = mode
                prepareRound()
                tutorialCategory = game.currentCategory
                cameraReady = true
                UIApplication.shared.isIdleTimerDisabled = true
                if !showTutorial { startSequence() }
            }
            .onChange(of: geo.size) { _, s in game.size = s }
            .onChange(of: game.remainingSeconds) { _, seconds in
                if seconds == 5 { SoundManager.shared.play("5second") }
            }
            .onChange(of: game.isFinished) { _, isFinished in
                guard isFinished else { return }
                SoundManager.shared.play("Timesup")
                withAnimation(.hudReveal) {
                    showHUD = false
                    endFlowStep = .timeUp
                }
            }
            .onDisappear {
                manager.stop()
                game.stop()
                UIApplication.shared.isIdleTimerDisabled = false
            }
        }
    }

    private func wordsLayer(in size: CGSize) -> some View {
        ForEach(game.words) { w in
            FallingWordView(text: w.text, isLeftSide: mode == .duo && w.x < size.width / 2)
                .position(x: w.x, y: w.y)
        }
    }

    @ViewBuilder
    private func endOverlay(for step: EndFlowStep, size: CGSize) -> some View {
        switch step {
        case .timeUp:
            TimeUpOverlay {
                withAnimation(.screenSwitch) { endFlowStep = .score }
            }
        case .score:
            ScoreResultScreen(
                mode: mode,
                winner: game.winner,
                scoreP1: game.ScoreP1,
                scoreP2: game.ScoreP2,
                onContinue: {
                    withAnimation(.screenSwitch) { endFlowStep = .learning }
                }
            )
        case .learning:
            LearningScreen(
                category: game.currentCategory,
                onPlayAgain: { restart(in: size) },
                onBackHome: exit
            )
        }
    }

    private func finishTutorial() {
        guard showTutorial else { return }
        withAnimation(.easeOut(duration: 0.4)) { showTutorial = false }
        startSequence()
    }

    private func prepareRound() {
        game.prepareRound(mode: mode)
        showHUD = false
        showRoundHeader = false
        pregameRaised = false
        endFlowStep = nil
        countdownValue = nil
    }

    private func startSequence() {
        Task {
            try? await Task.sleep(for: .milliseconds(500))
            withAnimation(.bannerReveal) { showRoundHeader = true }
            try? await Task.sleep(for: .milliseconds(1200))
            withAnimation(.bannerShrink) { pregameRaised = true }
            try? await Task.sleep(for: .milliseconds(700))

            runCountdown()
        }
    }

    private func runCountdown() {
        Task {
            SoundManager.shared.play("ready321")
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
        prepareRound()
        startSequence()
    }

    private func exit() {
        manager.stop()
        game.stop()
        onExit()
    }
}

#Preview(traits: .landscapeRight) { Gameplay(mode: .duo,) }


