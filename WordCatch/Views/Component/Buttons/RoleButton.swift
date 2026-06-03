//
//  RoleButton.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//





//MARK: basically icon button cuma ada shadow samping

import SwiftUI

struct NoFadeButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}

struct RoleButton: View {
    enum Variant {
        case primary, secondary, ghost
    }

    enum Size {
        // Hero CTA, capsule shape
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
    var variant: Variant = .primary
    let action: () -> Void

    private let shadowDepth: CGFloat = 4
    @State private var pressed = false

    private var background: Color {
        switch variant {
        case .primary:   return Color("OrangeBrand")
        case .secondary: return .white
        case .ghost:     return .clear
        }
    }

    private var foreground: Color {
        switch variant {
        case .primary:           return .white
        case .secondary, .ghost: return Color("BrownBrand")
        }
    }

    private var borderColor: Color? {
        switch variant {
        case .primary:   return Color("OrangeBrand")
        case .secondary: return Color("BrownBrand")
        case .ghost:     return nil
        }
    }


    private var borderHasDarkOverlay: Bool {
        variant == .primary
    }


    private var shadowFill: Color? {
        switch variant {
        case .primary:   return nil
        case .secondary: return Color("BrownBrand")
        case .ghost:     return nil
        }
    }

    private var hasChunky: Bool { variant != .ghost }

    var body: some View {
        Button(action: handleTap) {
            ZStack(alignment: .top) {
                if hasChunky {
                    ZStack {
                        RoundedRectangle(cornerRadius: size.radius)
                            .fill(shadowFill ?? background)
                        if shadowFill == nil {
                            RoundedRectangle(cornerRadius: size.radius)
                                .fill(Color.black.opacity(0.3))
                        }
                    }
                    .frame(height: size.height)
                    .offset(y: shadowDepth)
                }

                Text(title)
                    .font(size.font)
                    .foregroundColor(foreground)
                    .frame(maxWidth: .infinity)
                    .frame(height: size.height)
                    .background(
                        RoundedRectangle(cornerRadius: size.radius)
                            .fill(background)
                    )
                    .overlay(
                        ZStack {
                            if let bc = borderColor {
                                RoundedRectangle(cornerRadius: size.radius)
                                    .strokeBorder(bc, lineWidth: 2)
                                if borderHasDarkOverlay {
                                    RoundedRectangle(cornerRadius: size.radius)
                                        .strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                                }
                            }
                        }
                    )
                    .offset(y: hasChunky && pressed ? shadowDepth : 0)
                    .scaleEffect(!hasChunky && pressed ? 0.95 : 1.0)
            }
            .frame(height: hasChunky ? size.height + shadowDepth : size.height)
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
        RoleButton(title: "I'm Ready!", size: .xl, action: {})

        RoleButton(title: "Primary Large", size: .lg, action: {})

        HStack(spacing: 12) {
            RoleButton(title: "Skip",     size: .md, variant: .secondary, action: {})
            RoleButton(title: "AirPlay",  size: .md, variant: .primary,   action: {})
        }

        RoleButton(title: "Back", size: .sm, variant: .ghost, action: {})
    }
    .padding(24)
}
