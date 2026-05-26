//
//  SelectPlayerCard.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//

import SwiftUI

struct SelectPlayerCard: View {
    let textDisplay : String
    let imageDisplay : String
    let description : String
    var body: some View {
            HStack{
                Image(imageDisplay)
                    .resizable()
                    .frame(width: 144, height: 144)
                    .padding(.top)
                    .padding(.trailing, -15)
                VStack(alignment:.leading){
                    Text(textDisplay)
                        .font(.system(size: 30, weight: .bold))
                        .fontDesign(.rounded)
                    Text(description)
                        .foregroundColor(.brownBrand)
                }
                .padding()
            }
            .frame(width: 318, height: 136)
            .background(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(Color.black, lineWidth: 2)
            )
        }
}

#Preview {
    SelectPlayerCard(textDisplay: "Solo", imageDisplay: "MascotFace", description: "Play by yourself")
}
