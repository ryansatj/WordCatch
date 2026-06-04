//
//  ReadyOverlay.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

import SwiftUI

struct ReadyOverlay: View {
    var body: some View {
        // Reuses RoleButton (.secondary) as the card chrome; non-interactive.
        RoleButton(size: .lg, variant: .secondary, width: 420, height: 200, action: {}) {
            VStack(spacing: 10) {
              

                Text("You Are Ready!")
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(.brownBrand)

                Text("Let's get to the game")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(.brownBrand)
            }
            .padding(.horizontal, 24)
        }
        .allowsHitTesting(false)
    }
}

#Preview(traits: .landscapeRight) {
    ReadyOverlay()
}

