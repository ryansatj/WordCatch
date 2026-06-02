//
//  AppAnimations.swift
//  WordCatch
//
//vibee
import SwiftUI

// MARK: - Animations

extension Animation {
    // Entrances
    static let entrance: Animation = .spring(response: 0.55, dampingFraction: 0.6)
    // Staggered card appearance (Player Select).
    static let cardAppear: Animation = .spring(response: 0.5, dampingFraction: 0.75)

    // — Fades —
    static let fadeIn: Animation = .easeOut(duration: 0.45)
    static let fadeInQuick: Animation = .easeOut(duration: 0.4)

    // — Loops (use with .repeatForever(autoreverses: true))
    static let mascotFloat: Animation = .easeInOut(duration: 1.2)
    static let iconPulse: Animation = .easeInOut(duration: 1.4)

    //Screen state
    static let hudReveal: Animation = .easeOut(duration: 0.35)
    //Top-level screen switch in ContentView.
    static let screenSwitch: Animation = .easeInOut(duration: 0.45)
    // Tutorial page changes.
    static let pageSwitch: Animation = .easeInOut(duration: 0.35)
}

// MARK: - Transitions

extension AnyTransition {
    // Slide+fade for forward navigation (PlayerSelect → AirPlay → Tutorial → Game).
    static let slideForward: AnyTransition = .asymmetric(
        insertion: .move(edge: .trailing).combined(with: .opacity),
        removal:   .move(edge: .leading).combined(with: .opacity)
    )

    // Slide+fade for backward navigation.
    static let slideBackward: AnyTransition = .asymmetric(
        insertion: .move(edge: .leading).combined(with: .opacity),
        removal:   .move(edge: .trailing).combined(with: .opacity)
    )
}
