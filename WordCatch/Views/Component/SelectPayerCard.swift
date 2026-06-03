//
//  SelectPayerCard.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//


import SwiftUI

struct SelectPlayerCard: View {
    let textDisplay: String
    let imageDisplay: String
    let description: String
    var isPressed: Bool = false

    var body: some View {
        HStack(spacing: 4) {
            Image(imageDisplay)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130, height: 130)
                .padding(.leading, 8)

            VStack(alignment: .leading, spacing: 6) {
                Text(textDisplay)
                    .font(.system(size: 28, weight: .bold))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                Text(description)
                    .font(.system(size: 15, weight: .medium))
                    .fontDesign(.rounded)
                    .foregroundColor(Color("BrownBrand").opacity(0.85))
            }
            .padding(.trailing, 18)

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color("BrownBrand").opacity(0.6))
                .padding(.trailing, 20)
        }
        .frame(width: 320, height: 136)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.black, lineWidth: 2)
        )
        .shadow(color: .black.opacity(isPressed ? 0.05 : 0.15),
                radius: isPressed ? 2 : 8, x: 0, y: isPressed ? 1 : 4)
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
}

#Preview {
    SelectPlayerCard(textDisplay: "Solo", imageDisplay: "MascotFace", description: "Play by yourself")
}
