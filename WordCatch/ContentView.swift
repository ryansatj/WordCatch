//
//  ContentView.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//

import SwiftUI

struct ContentView: View {
    enum Screen: Hashable {
        case splash, playerSelection, airplay, tutorial, game
    }

    @State private var screen: Screen = .splash
    @State private var selectedMode: GameMode = .solo
    @Environment(\.accessibilityReduceMotion) private var reduceMotion 

    private var screenTransition: AnyTransition { .opacity }
    private var screenAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.2) : .screenSwitch
    }

    var body: some View {
        ZStack {
            switch screen {
            case .splash:
                SplashScreen { advance(to: .playerSelection) }
                    .transition(screenTransition)
            case .playerSelection:
                PlayerSelectionScreen(
                    onBack: { advance(to: .splash) },
                    onSelect: { mode in
                        selectedMode = mode
                        advance(to: .airplay)
                    }
                )
                .transition(screenTransition)
            case .airplay:
                AirplayOptionScreen(
                    onBack: { advance(to: .playerSelection) },
                    onContinue: { advance(to: .tutorial) }
                )
                .transition(screenTransition)
            case .tutorial:
                TutorialCarouselScreen(
                    onBack: { advance(to: .airplay) },
                    onStart: { advance(to: .game) }
                )
                .transition(screenTransition)
            case .game:
                Gameplay(mode: selectedMode, onExit: { advance(to: .playerSelection) })
                    .transition(screenTransition)
            }
        }
        .animation(screenAnimation, value: screen)
        .onAppear(perform: updateMusic)
        .onChange(of: screen) { _, _ in updateMusic() }
    }

    private func advance(to next: Screen) {
        screen = next
    }

   
    private func updateMusic() {
        let track = screen == .game ? "inGame" : "outGame"
        SoundManager.shared.playMusic(track, volume: 0.35)
    }
}

#Preview(traits: .landscapeRight) {
    ContentView()
}
