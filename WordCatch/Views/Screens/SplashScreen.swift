//
//  SplashScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack{
            Image("bg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack{
                Image("SplashMascot")
                    .resizable()
                    .frame(width: 183, height: 136)
                Text("WordCatch")
                    .font(.system(size: 40, weight: .heavy))
                    .fontDesign(.rounded)
                    .foregroundStyle(Color(.orangeBrand))
                Text("Move, Smile, Repeat.")
                    .font(.system(size: 24, weight: .medium))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                    .opacity(0.7)
            }
        }
    }
}

#Preview {
    SplashScreen()
}
