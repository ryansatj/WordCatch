//
//  IconButton.swift
//  WordCatch
//
//  Unified 44x44 circular icon button for top bars (back, close, etc).
//  Front circle slides down into the fixed shadow circle on press —
//  like a real key bottoming out.
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
        Button(action: action) {
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
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeOut(duration: 0.06)) { pressed = true }
                }
                .onEnded { _ in
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) { pressed = false }
                }
        )
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
