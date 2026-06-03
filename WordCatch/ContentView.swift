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

    var body: some View {
        ZStack {
            switch screen {
            case .splash:
                SplashScreen { advance(to: .playerSelection) }
                    .transition(.opacity)
            case .playerSelection:
                PlayerSelectionScreen(
                    onBack: { advance(to: .splash) },
                    onSelect: { mode in
                        selectedMode = mode
                        advance(to: .airplay)
                    }
                )
                .transition(.slideForward)
            case .airplay:
                AirplayOptionScreen(
                    onBack: { advance(to: .playerSelection) },
                    onContinue: { advance(to: .tutorial) }
                )
                .transition(.slideForward)
            case .tutorial:
                TutorialCarouselScreen(
                    onBack: { advance(to: .airplay) },
                    onStart: { advance(to: .game) }
                )
                .transition(.slideForward)
            case .game:
                Gameplay(mode: selectedMode, onExit: { advance(to: .playerSelection) })
                    .transition(.opacity)
            }
        }
        .animation(.screenSwitch, value: screen)
    }

    private func advance(to next: Screen) {
        screen = next
    }
}

#Preview {
    ContentView()
}
