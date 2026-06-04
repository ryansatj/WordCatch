//
//  TryHandsView.swift
//  WordCatch
//
//  Second pre-game step (after Position Setup): players practise the two
//  gestures — open hand to catch, closed hand to skip — before the round.
//  Kept in its own file so the tutorial flow stays clean.
//

import SwiftUI

struct TryHandsView: View {
    let mode: GameMode
    var hands: () -> [HandSnapshot]
    var onReady: () -> Void

    private enum Step: Equatable {
        case close, open, done

        var title: String {
            switch self {
            case .close: return "Close Your Hand"
            case .open:  return "Now Open It"
            case .done:  return "Great!"
            }
        }
        var hint: String {
            switch self {
            case .close: return "to skip words"
            case .open:  return "to catch words"
            case .done:  return "you've got it"
            }
        }
        var image: String {
            switch self {
            case .close: return "Image"        // closed-hand asset
            case .open:  return "PandaHand"     // open-hand asset
            case .done:  return "SplashMascot"
            }
        }
        var tint: Color { self == .done ? .green : Color("OrangeBrand") }
    }

    @State private var step: Step = .close
    @State private var heldSince: Date? = nil
    @State private var timer: Timer? = nil
    @State private var done = false

    /// How long a gesture must hold before it counts.
    private let holdToPass: TimeInterval = 0.6

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 20) {
                header
                promptCard
                debugNext
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
        .onAppear(perform: startPolling)
        .onDisappear { timer?.invalidate() }
    }

    // MARK: - Sub-views

    private var header: some View {
        RoleButton(size: .lg, variant: .primary, width: 240, height: 54, action: {}) {
            Text("Try Your Hands")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .allowsHitTesting(false)
    }

    private var promptCard: some View {
        VStack(spacing: 8) {
            
            
            Image(step.image)
                .resizable()
                .scaledToFit()
                .frame(width: 90, height: 90)
            Text(step.title)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(.brownBrand)
            Text(step.hint)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(Color("BrownBrand").opacity(0.7))
        }
        .padding(.horizontal, 40)
        .padding(.vertical, 22)
        .background(Color(.creamBrand), in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(step.tint.opacity(0.8), lineWidth: 2.5)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: step)
    }

    private var debugNext: some View {
        HStack {
            Spacer()
            //MARK: Debug: skip the practice (hand detection doesn't run in previews/sim).
            RoleButton(title: "Next", size: .sm, variant: .secondary, width: 90) { finish() }
        }
    }

    // MARK: - Detection

    private func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            evaluate()
        }
    }

    private func evaluate() {
        guard !done else { return }
        let snaps = hands()

        switch step {
        case .close:
            // A closed hand — per side in duo, anywhere in solo.
            if satisfied(snaps, { !$0.isOpen }) {
                pass { withAnimation { step = .open } }
            } else { heldSince = nil }

        case .open:
            // An open hand — per side in duo, anywhere in solo.
            if satisfied(snaps, { $0.isOpen }) {
                pass { finish() }
            } else { heldSince = nil }

        case .done:
            break
        }
    }

    /// In duo each side must contain a matching hand; in solo the whole frame.
    private func satisfied(_ snaps: [HandSnapshot], _ check: (HandSnapshot) -> Bool) -> Bool {
        guard mode == .duo else { return snaps.contains(where: check) }
        let left = snaps.filter { $0.palmCenter.x < 0.5 }
        let right = snaps.filter { $0.palmCenter.x >= 0.5 }
        return left.contains(where: check) && right.contains(where: check)
    }

    // Calls `action` once the current gesture has been held long enough.
    private func pass(_ action: () -> Void) {
        if heldSince == nil {
            heldSince = Date()
        } else if Date().timeIntervalSince(heldSince!) >= holdToPass {
            heldSince = nil
            action()
        }
    }

    private func finish() {
        guard !done else { return }
        done = true
        timer?.invalidate()
        withAnimation { step = .done }
        onReady()
    }
}

#Preview(traits: .landscapeRight) {
    ZStack {
        Color(red: 0.15, green: 0.15, blue: 0.18).ignoresSafeArea()
        TryHandsView(mode: .duo, hands: { [] }, onReady: {})
    }
}
