//
//  IconButton.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//

import SwiftUI
import Foundation

struct SetupPage: Identifiable {
    let id = UUID()
    let image: String
    let subtitle: String
}

struct IconButton: View {
    let systemName: String
    var background: Color = Color("OrangeBrand")
    var tint: Color = .white
    let action: () -> Void

    private let size: CGFloat = 44
    private let shadowDepth: CGFloat = 4
    @State private var pressed = false

    var body: some View {
        Button(action: handleTap) {
            ZStack(alignment: .top) {
                ZStack {
                    Circle().fill(background)
                    Circle().fill(Color.black.opacity(0.3))
                }
                .frame(width: size, height: size)
                .offset(y: shadowDepth)

                ZStack {
                    Circle()
                        .fill(background)
                    Image(systemName: systemName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(tint)
                }
                .frame(width: size, height: size)
                .offset(y: pressed ? shadowDepth : 0)
            }
            .frame(width: size, height: size + shadowDepth)
        }
        .buttonStyle(NoFadeButtonStyle())
    }

    private func handleTap() {
        withAnimation(.easeOut(duration: 0.08)) { pressed = true }
        Task {
            try? await Task.sleep(for: .milliseconds(110))
            withAnimation(.spring(response: 0.28, dampingFraction: 0.55)) { pressed = false }
            action()
        }
    }
}

#Preview {
    HStack(spacing: 16) {
        IconButton(systemName: "chevron.left", action: {})
        IconButton(systemName: "xmark", action: {})
        IconButton(systemName: "gearshape.fill",
                   background: .white,
                   tint: .black,
                   action: {})
    }
    .padding()
}
