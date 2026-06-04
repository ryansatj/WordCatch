//
//  SplashScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//


// MARK: Animated gung 


import SwiftUI

struct SplashScreen: View {
    var onContinue: () -> Void = {}

    @State private var mascotVisible = false
    @State private var titleVisible = false
    @State private var subtitleVisible = false
    @State private var mascotFloat = false
    @State private var dotPhase = 0
    @State private var loadingDone = false

    var body: some View {
        ZStack {
            CelebrationBackground()

            VStack(spacing: 12) {
                Image("SplashMascot")
                    .resizable()
                    .frame(width: 183, height: 136)
                    .offset(y: mascotFloat ? -8 : 0)
                    .scaleEffect(mascotVisible ? 1.0 : 0.6)
                    .opacity(mascotVisible ? 1 : 0)

                Text("WordCatch")
                    .font(.system(size: 44, weight: .heavy))
                    .fontDesign(.rounded)
                    .foregroundStyle(Color("OrangeBrand"))
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 12)

                Text("Move, Smile, Repeat.")
                    .font(.system(size: 22, weight: .medium))
                    .fontDesign(.rounded)
                    .foregroundColor(.black)
                    .opacity(subtitleVisible ? 0.7 : 0)
                    .offset(y: subtitleVisible ? 0 : 8)

                ZStack {
                    LoadingDots(phase: dotPhase)
                        .opacity(loadingDone ? 0 : (subtitleVisible ? 1 : 0))

                    RoleButton(title: "Play", action: onContinue)
                        .frame(maxWidth: 220)
                        .opacity(loadingDone ? 1 : 0)
                        .offset(y: loadingDone ? 0 : 8)
                        .allowsHitTesting(loadingDone)
                }
                .padding(.top, 28)
            }
        }
        .task {
            withAnimation(.entrance) { mascotVisible = true }
            try? await Task.sleep(for: .milliseconds(220))
            withAnimation(.fadeIn) { titleVisible = true }
            try? await Task.sleep(for: .milliseconds(180))
            withAnimation(.fadeInQuick) { subtitleVisible = true }

            withAnimation(.mascotFloat.repeatForever(autoreverses: true)) {
                mascotFloat = true
            }

            startDotAnimation()

            try? await Task.sleep(for: .milliseconds(3500))
            withAnimation(.entrance) {
                loadingDone = true //hardcoded loadiing
            }
        }
        .onAppear { OrientationManager.shared.lockLandscape() }
    }

    private func startDotAnimation() {
        Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(280))
                withAnimation(.easeInOut(duration: 0.2)) {
                    dotPhase = (dotPhase + 1) % 3
                }
            }
        }
    }
}

private struct LoadingDots: View {
    let phase: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(Color("OrangeBrand"))
                    .frame(width: 10, height: 10)
                    .scaleEffect(i == phase ? 1.3 : 0.8)
                    .opacity(i == phase ? 1.0 : 0.5)
            }
        }
    }
}

#Preview(traits: .landscapeRight) {
    SplashScreen()
}
