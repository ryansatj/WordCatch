//
//  CatchWordOverlay.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

import SwiftUI

struct CatchWordOverlay: View {
    var body: some View {
        VStack(spacing: 8) {
            Text("Catch the word in")
                .font(.system(size: 44, weight: .semibold, design: .rounded))
                .foregroundStyle(.brownBrand)
            Text("Animal")
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .foregroundStyle(Color("OrangeBrand"))
                .padding(.horizontal, 100)
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 28)
        .background(Color(.creamBrand), in: RoundedRectangle(cornerRadius: 24))
        .shadow(radius: 1)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(.white.opacity(0.25), lineWidth: 1.5)
        )
    }
}

#Preview(traits: .landscapeRight) {
    CatchWordOverlay()
}
