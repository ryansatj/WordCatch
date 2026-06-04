//
//  CatchWordOverlay.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

import SwiftUI

struct CatchWordOverlay: View {
    var category: String = "Animal"
    var compact: Bool = false

    var body: some View {
        RoleButton(size: .lg,
                   variant: .secondary,
                   width: compact ? 280 : 480,
                   height: compact ? 70 : 170,
                   action: {}) {
            VStack(spacing: compact ? 4 : 8) {
                Text("Catch the word in")
                    .font(.system(size: compact ? 20 : 44, weight: .semibold, design: .rounded))
                    .foregroundStyle(.brownBrand)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(category)
                    .font(.system(size: compact ? 24 : 56, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color("OrangeBrand"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.horizontal, compact ? 20 : 36)
        }
        .allowsHitTesting(false)
    }
}

#Preview("Full", traits: .landscapeRight) {
    CatchWordOverlay()
}

#Preview("Compact", traits: .landscapeRight) {
    CatchWordOverlay(compact: true)
}
