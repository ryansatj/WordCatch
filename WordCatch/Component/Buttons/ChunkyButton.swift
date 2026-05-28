//
//  ChunkyButton.swift
//  WordCatch
//
//  Chunky pressable button. The shadow layer is fixed in place
//  underneath; on press the front slides down to meet it — like
//  a key bottoming out. No "back circle hanging" artifact.
//
//  Sizes (heights): .lg = 58 / .md = 48 / .sm = 38
//  In a row, the button stretches to fill via maxWidth: .infinity,
//  so use HStack(spacing:) and let them share width naturally.
//

import SwiftUI

struct ChunkyButton: View {
    enum Size {
        case lg, md, sm

        var height: CGFloat {
            switch self {
            case .lg: return 58
            case .md: return 48
            case .sm: return 38
            }
        }

        var font: Font {
            switch self {
            case .lg: return .h2
            case .md: return .bodyText
            case .sm: return .caption
            }
        }

        var radius: CGFloat {
            switch self {
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
        Button(action: action) {
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
    VStack(spacing: 18) {
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
