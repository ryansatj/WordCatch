//
//  PositionSetupView.swift
//  WordCatch
//
//  Pre-game calibration shown before the tutorial: it watches the live hand
//  detection and coaches the player(s) into frame ("Raise Your Hands" /
//  "Move Farther") before letting the round begin, plus an open-vs-closed
//  hand legend. Solo shows one card; duo checks each side independently.
//

// MARK: fituururewiufhuewfweb

import SwiftUI
import Vision
import QuartzCore

struct PositionSetupView: View {
    let mode: GameMode
    var hands: () -> [HandSnapshot]
    var onReady: () -> Void

    private enum SetupState: Equatable {
        case raiseHands     // not enough hands visible
        case moveFarther    // a hand is too close to the camera
        case ready          // framed correctly

        var title: String {
            switch self {
            case .raiseHands:  return "Raise Your Hands"
            case .moveFarther: return "Move Farther"
            case .ready:       return "Perfect!"
            }
        }
        var icon: String {
            switch self {
            case .raiseHands:  return "PandaHand"
            case .moveFarther: return "Xmark"
            case .ready:       return "SplashMascot"
            }
        }
        
        var tint: Color { self == .ready ? .green : Color("OrangeBrand") }
    }

    @State private var leftState: SetupState = .raiseHands   // also the solo state
    @State private var rightState: SetupState = .raiseHands
    @State private var readySince: Date? = nil
    @State private var timer: Timer? = nil
    @State private var done = false

    private let holdToReady: TimeInterval = 1.5
    private let tooCloseSpan: CGFloat = 0.5

    private var allReady: Bool {
        mode == .duo ? (leftState == .ready && rightState == .ready) : leftState == .ready
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            if mode == .duo {
                PlayerDivider()
            }

            cardsLayer

            VStack {
                header
                Spacer()
                //MARK: FOR DEBUGGING Debug: skip calibration (hand detection doesn't run in previews/sim).
                
                HStack {
                    Spacer()
                    RoleButton(title: "Next", size: .sm, variant: .secondary, width: 90) {
                        advance() //THISS
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
        .onAppear(perform: startPolling)
        .onDisappear { timer?.invalidate() }
    }
    
    private func advance() {
        guard !done else { return }
        done = true
        timer?.invalidate()
        onReady() //MARK: FOR DEBUGGING
    }

    // MARK: - Sub-views

    private var header: some View {
        RoleButton(size: .lg, variant: .primary, width: 240, height: 54, action: {}) {
            Text("Position Setup")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var cardsLayer: some View {
        if mode == .duo {
            HStack(spacing: 0) {
                instructionCard(leftState, label: "Player 1")
                    .frame(maxWidth: .infinity)
                instructionCard(rightState, label: "Player 2")
                    .frame(maxWidth: .infinity)
            }
            .offset(y: 15)
        } else {
            instructionCard(leftState, label: nil)
        }
    }

    private func instructionCard(_ state: SetupState, label: String?) -> some View {
        VStack(spacing: 10) {
            if let label {
                Text(label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("BrownBrand").opacity(0.7))
            }
            Image(state.icon)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .font(.system(size: 46))
                .foregroundStyle(state.tint)
            Text(state.title)
                .font(.system(size: 24, weight: .black, design: .rounded))
                .foregroundStyle(.brownBrand)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 22)
        .background(Color(.creamBrand), in: RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(state.tint.opacity(0.8), lineWidth: 2.5)
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: state)
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

        if mode == .duo {
            let l = state(for: snaps.filter { $0.palmCenter.x < 0.5 })
            let r = state(for: snaps.filter { $0.palmCenter.x >= 0.5 })
            if l != leftState { withAnimation { leftState = l } }
            if r != rightState { withAnimation { rightState = r } }
        } else {
            let s = state(for: snaps)
            if s != leftState { withAnimation { leftState = s } }
        }

        if allReady {
            if readySince == nil {
                readySince = Date()
            } else if Date().timeIntervalSince(readySince!) >= holdToReady {
                done = true
                timer?.invalidate()
                onReady()
            }
        } else {
            readySince = nil
        }
    }

    /// State for one zone's hands (all hands in solo, one side in duo).
    /// Both hands must be up — 2 per side in duo, 2 total in solo.
    private func state(for snaps: [HandSnapshot]) -> SetupState {
        if snaps.contains(where: { handSpan($0) > tooCloseSpan }) { return .moveFarther }
        return snaps.count >= 2 ? .ready : .raiseHands
    }

    /// Normalised wrist→middle-fingertip distance — a proxy for camera distance.
    private func handSpan(_ hand: HandSnapshot) -> CGFloat {
        guard let wrist = hand.points[.wrist],
              let tip = hand.points[.middleTip] else { return 0 }
        return hypot(tip.x - wrist.x, tip.y - wrist.y)
    }
}

#Preview("Duo", traits: .landscapeRight) {
    ZStack {
        Color(red: 0.15, green: 0.15, blue: 0.18).ignoresSafeArea()
        PositionSetupView(mode: .duo, hands: { [] }, onReady: {})
    }
}

#Preview("Solo", traits: .landscapeRight) {
    ZStack {
        Color(red: 0.15, green: 0.15, blue: 0.18).ignoresSafeArea()
        PositionSetupView(mode: .solo, hands: { [] }, onReady: {})
    }
}
