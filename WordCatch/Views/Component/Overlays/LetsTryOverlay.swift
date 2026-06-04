//
//  LetsTryOverlay.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

import SwiftUI

struct LetsTryOverlay: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(.splashMascot)
                .font(.system(size: 48))
                .foregroundStyle(Color("OrangeBrand"))

            Text("Let's Try!")
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundStyle(.brownBrand)
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 28)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color("OrangeBrand").opacity(0.7), lineWidth: 2.5)
        )
    }
}

#Preview {
    LetsTryOverlay()
}
