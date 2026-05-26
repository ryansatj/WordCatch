//
//  PlayerSelectionScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//

import SwiftUI

struct PlayerSelectionScreen: View {
    var body: some View {
        ZStack{
            Image("bg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            VStack{
                Text("Who's playing today?")
                    .font(.system(size: 32, weight: .heavy))
                    .foregroundColor(.brownBrand)
                    .fontDesign(.rounded)
                    .padding(.bottom, 10)
                Text("Choose your playing mode")
                    .font(.system(size: 24, weight: .medium))
                    .opacity(0.6)
                    .fontDesign(.rounded)
                    .padding(.bottom, 30)
                
                SelectPlayerCard(textDisplay: "Solo", imageDisplay: "MascotFace", description: "Play by yourself")
                    .padding()
                
                SelectPlayerCard(textDisplay: "Duo", imageDisplay: "TwoFaceMascot", description: "Invite a partner")
            }
        }
    }
}

#Preview {
    PlayerSelectionScreen()
}
