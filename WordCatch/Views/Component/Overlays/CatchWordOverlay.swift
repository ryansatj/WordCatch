//
//  CatchWordOverlay.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

import SwiftUI

struct CatchWordOverlay: View {
    var category: String = "Animal"
    /// Compact sizing for use as a persistent in-game banner; the default
    /// large sizing is the full-screen intro card.
    var compact: Bool = false

    var body: some View {
        VStack(spacing: compact ? 4 : 8) {
            Text("Catch the word in")
                .font(.system(size: compact ? 20 : 44, weight: .semibold, design: .rounded))
                .foregroundStyle(.brownBrand)
            Text(category)
                .font(.system(size: compact ? 24 : 56, weight: .heavy, design: .rounded))
                .foregroundStyle(Color("OrangeBrand"))
                .padding(.horizontal, compact ? 24 : 100)
        }
        .padding(.horizontal, compact ? 24 : 44)
        .padding(.vertical, compact ? 12 : 28)
        .background(Color(.creamBrand), in: RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
        )
    }
}

#Preview("Full", traits: .landscapeRight) {
    CatchWordOverlay()
}

#Preview("Compact", traits: .landscapeRight) {
    CatchWordOverlay(compact: true)
}
