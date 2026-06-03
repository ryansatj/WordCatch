//
//  ChunkyButton.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//


import SwiftUI

struct ChunkyButton: View {
    enum Size {
        // Hero CTA, capsule shape (matches ReadyButton style)
        case xl
        case lg, md, sm

        var height: CGFloat {
            switch self {
            case .xl: return 60
            case .lg: return 58
            case .md: return 48
            case .sm: return 38
            }
        }

        var font: Font {
            switch self {
            case .xl: return .system(size: 18, weight: .bold, design: .rounded)
            case .lg: return .h2
            case .md: return .bodyText
            case .sm: return .caption
            }
        }

        var radius: CGFloat {
            switch self {
            case .xl: return 30
            case .lg: return 16
            case .md: return 14
            case .sm: return 12
            }
        }
    }

    let title: String
    var size: Size = .lg
    var backgroundColor: Color = Color("OrangeBrand")
    var foregroundColor: Color = .white
    var shadowColor: Color? = nil
    let action: () -> Void

    private let shadowDepth: CGFloat = 4
    @State private var pressed = false

    var body: some View {
        Button(action: handleTap) {
            ZStack(alignment: .top) {
                ZStack {
                    RoundedRectangle(cornerRadius: size.radius)
                        .fill(shadowColor ?? backgroundColor)
                    if shadowColor == nil {
                        RoundedRectangle(cornerRadius: size.radius)
                            .fill(Color.black.opacity(0.3))
                    }
                }
                .frame(height: size.height)
                .offset(y: shadowDepth)

                Text(title)
                    .font(size.font)
                    .foregroundColor(foregroundColor)
                    .frame(maxWidth: .infinity)
                    .frame(height: size.height)
                    .background(
                        RoundedRectangle(cornerRadius: size.radius)
                            .fill(backgroundColor)
                    )
                    .offset(y: pressed ? shadowDepth : 0)
            }
            .frame(height: size.height + shadowDepth)
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
    VStack(spacing: 18) {
        ChunkyButton(title: "I'm Ready!", size: .xl, action: {})

        ChunkyButton(title: "Primary Large", size: .lg, action: {})

        HStack(spacing: 12) {
            ChunkyButton(title: "Cancel",
                         size: .md,
                         backgroundColor: .white,
                         foregroundColor: .black,
                         shadowColor: .black.opacity(0.35),
                         action: {})
            ChunkyButton(title: "Confirm", size: .md, action: {})
        }

        ChunkyButton(title: "Small", size: .sm, action: {})
    }
    .padding(24)
}
