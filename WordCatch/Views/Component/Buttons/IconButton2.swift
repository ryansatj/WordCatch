//
//  IconButton2.swift
//  WordCatch
//
//

import SwiftUI

struct IconButton2: View {
    enum Variant {
        case primary, secondary, ghost
    }

    let systemName: String
    var variant: Variant = .primary
    let action: () -> Void

    private let size: CGFloat = 44
    private let shadowDepth: CGFloat = 4
    @State private var pressed = false

    private var background: Color {
        switch variant {
        case .primary:   return Color("OrangeBrand")
        case .secondary: return .white
        case .ghost:     return .clear
        }
    }

    private var tint: Color {
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
                        Circle().fill(shadowFill ?? background)
                        if shadowFill == nil {
                            Circle().fill(Color.black.opacity(0.3))
                        }
                    }
                    .frame(width: size, height: size)
                    .offset(y: shadowDepth)
                }

                ZStack {
                    Circle().fill(background)
                    if let bc = borderColor {
                        Circle().strokeBorder(bc, lineWidth: 2)
                        if borderHasDarkOverlay {
                            Circle().strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                        }
                    }
                    Image(systemName: systemName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(tint)
                }
                .frame(width: size, height: size)
                .offset(y: hasChunky && pressed ? shadowDepth : 0)
                .scaleEffect(!hasChunky && pressed ? 0.9 : 1.0)
            }
            .frame(width: size, height: hasChunky ? size + shadowDepth : size)
        }
        .buttonStyle(NoFadeButtonStyle())
    }

    private func handleTap() {
        SoundManager.shared.play("BackButton")
        
        
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
        IconButton2(systemName: "chevron.left", variant: .primary,   action: {})
        IconButton2(systemName: "xmark",        variant: .secondary, action: {})
        IconButton2(systemName: "gearshape.fill", variant: .ghost,   action: {})
    }
    .padding(32)
    .background(Color(white: 0.95))
}
