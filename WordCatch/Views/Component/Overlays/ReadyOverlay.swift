//
//  ReadyOverlay.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

import SwiftUI

struct ReadyOverlay: View {
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "hands.clap.fill")
                .font(.system(size: 48))
                .foregroundStyle(Color("OrangeBrand"))

            Text("You Are Ready!")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(.brownBrand)

            Text("Let's get to the game")
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundStyle(.brownBrand)
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 32)
        .background(Color(.creamBrand), in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color("OrangeBrand").opacity(0.7), lineWidth: 2.5)
        )
    }
}

#Preview(traits: .landscapeRight) {
    ReadyOverlay()
}

