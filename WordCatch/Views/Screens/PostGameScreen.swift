//
//  Gameplay.swift
//  WordCatch
//
//  Created by Gung  on 3/06/26.
//
// MARK: Screen 6

import SwiftUI

struct PostGameScreen: View {
    var onHome: () -> Void = {}

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack {
                HStack {
                    IconButton2(systemName: "house.fill", variant: .primary, action: onHome)
                        .padding(24)
                    Spacer()
                }
                Spacer()
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    PostGameScreen()
}
