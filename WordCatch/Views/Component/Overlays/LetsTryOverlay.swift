//
//  LetsTryOverlay.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

import SwiftUI

struct LetsTryOverlay: View {
    var body: some View {
        ZStack{
            VStack(spacing: 12) {
                Text("Let's Try!")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.brownBrand)
                    .padding(.top, 20)
                    .padding(.horizontal)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 28)
            .background(Color(.creamBrand), in: RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color("OrangeBrand").opacity(1), lineWidth: 3)
            )
            Image(.splashMascot)
                .font(.system(size: 48))
                .foregroundStyle(Color("OrangeBrand"))
                .offset(x: 0, y: -60)
        }
    }
}

#Preview(traits: .landscapeRight) {
    LetsTryOverlay()
}
