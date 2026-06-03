//
//  FallingWordView.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//
//  Word capsule that falls from the top — color-coded per side so
//  players know whose word is whose. Uses brand colors:
//    left  side → OrangeBrand (Player 1)
//    right side → BrownBrand  (Player 2)
//

import SwiftUI

struct FallingWordView: View {
    let text: String
    let isLeftSide: Bool

    private var gradientColors: [Color] {
        if isLeftSide {
            return [Color("OrangeBrand"), Color("OrangeBrand").opacity(0.7)]
        } else {
            return [Color("BrownBrand"), Color("BrownBrand").opacity(0.7)]
        }
    }

    var body: some View {
        // 38pt heavy — large enough for 57+ to read while in motion.
        Text(text)
            .font(.system(size: 38, weight: .heavy, design: .rounded))
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.85), radius: 4, y: 2)
            .padding(.horizontal, 20)
            .padding(.vertical, 11)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            )
            // Thick white outline — high contrast against any camera background.
            .overlay(Capsule().strokeBorder(.white.opacity(0.7), lineWidth: 2.5))
    }
}

#Preview {
    HStack(spacing: 20) {
        FallingWordView(text: "tambah", isLeftSide: true)
        FallingWordView(text: "doggs",  isLeftSide: false)
    }
    .padding(40)
    .background(Color.black)
}
