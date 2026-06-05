//
//  AirplayInfoScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 05/06/26.
//

import SwiftUI

struct AirplayInfoScreen: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        ZStack{
            Image("LanscapePolos")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            HStack{
                VStack{
                    Text("Connect to a TV")
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(.brownBrand)
                    HStack{
                        ZStack{
                            Circle()
                                .frame(width: 46, height: 46)
                                .foregroundColor(.brownBrand)
                            Text("1")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Text("Make sure your device and TV are on the same Wi-Fi network.")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .frame(maxWidth: 335, alignment: .leading)
                            .padding(.leading)
                    }
                    HStack{
                        ZStack{
                            Circle()
                                .frame(width: 46, height: 46)
                                .foregroundColor(.brownBrand)
                            Text("2")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Text("Open Control Center.")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .frame(maxWidth: 335, alignment: .leading)
                            .padding(.leading)
                        
                    }
                    HStack{
                        ZStack{
                            Circle()
                                .frame(width: 46, height: 46)
                                .foregroundColor(.brownBrand)
                            Text("3")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        Text("Tap Screen Mirroring.")
                            .font(.system(size: 24, weight: .medium, design: .rounded))
                            .frame(maxWidth: 335, alignment: .leading)
                            .padding(.leading)
                    }
                    RoleButton(
                        title: "Got it",
                        size: .lg,
                        variant: .primary,
                        action: { dismiss() }
                    )
                    .frame(maxWidth: 250)
                    .offset(x : -10)
                }
                Image(.airplay)
                    .offset(y: 70)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview(traits: .landscapeRight) {
    AirplayInfoScreen()
}
