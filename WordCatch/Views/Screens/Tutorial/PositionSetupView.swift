






//MARK: Gung

import SwiftUI
import Vision

struct PositionSetupView: View {
    let mode: GameMode
    var hands: () -> [HandSnapshot]
    var onReady: () -> Void

    // MARK: Tuning

    private let requiredHands = 2
    private let holdToReady: TimeInterval = 1.5    // for ready
    private let tooCloseSpan: CGFloat = 0.5        // hand span that counts as too close

    // MARK: State

    @State private var leftState: SetupState = .raiseHands   // solo uses this one
    @State private var rightState: SetupState = .raiseHands
    @State private var readySince: Date?
    @State private var timer: Timer?
    @State private var done = false

    private var allReady: Bool {
        mode == .duo ? leftState == .ready && rightState == .ready : leftState == .ready
    }

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
        var image: String {
            switch self {
            case .raiseHands:  return "TwoHand"
            case .moveFarther: return "Image"        // TODO: dedicated "too close" art
            case .ready:       return "SplashMascot"
            }
        }
        var tint: Color { self == .ready ? .green : Color("OrangeBrand") }
    }

    // MARK: Body

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()

            if mode == .duo { PlayerDivider() }

            cards

            VStack {
                header
                Spacer()
                debugSkipButton
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
        .onAppear(perform: startPolling)
        .onDisappear { timer?.invalidate() }
    }

    // MARK: Sub-views

    private var header: some View {
        RoleButton(size: .lg, variant: .primary, width: 240, height: 54, action: {}) {
            Text("Position Setup")
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var cards: some View {
        if mode == .duo {
            HStack(spacing: 0) {
                card(leftState, label: "Player 1").frame(maxWidth: .infinity)
                card(rightState, label: "Player 2").frame(maxWidth: .infinity)
            }
            .offset(y: 15)
        } else {
            card(leftState, label: nil)
        }
    }

    private func card(_ state: SetupState, label: String?) -> some View {
        VStack(spacing: 10) {
            if let label {
                Text(label)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(Color("BrownBrand").opacity(0.7))
            }
            Image(state.image)
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 100)
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

    private var debugSkipButton: some View {
        HStack {
            Spacer()
            // debug  (delete later)
            RoleButton(title: "Next", size: .sm, variant: .secondary, width: 90, action: finish)
        }
    }

    // MARK:  Detection

    private func startPolling() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in evaluate() }
    }

    private func evaluate() {
        guard !done else { return }
        let snaps = hands()

        if mode == .duo {
            setLeft(state(for: snaps.filter { $0.palmCenter.x < 0.5 }))
            setRight(state(for: snaps.filter { $0.palmCenter.x >= 0.5 }))
        } else {
            setLeft(state(for: snaps))
        }

        updateReadyHold()
    }

    private func setLeft(_ s: SetupState) {
        if s != leftState { withAnimation { leftState = s } }
    }

    private func setRight(_ s: SetupState) {
        if s != rightState { withAnimation { rightState = s } }
    }

    // Continues once every zone has stayed `.ready` for `holdToReady`.
    private func updateReadyHold() {
        guard allReady else { readySince = nil; return }
        if readySince == nil {
            readySince = Date()
        } else if Date().timeIntervalSince(readySince!) >= holdToReady {
            finish()
        }
    }

    private func state(for snaps: [HandSnapshot]) -> SetupState {
        if snaps.contains(where: isTooClose) { return .moveFarther }
        return snaps.count >= requiredHands ? .ready : .raiseHands
    }

    private func isTooClose(_ hand: HandSnapshot) -> Bool {
        handSpan(hand) > tooCloseSpan
    }


    private func handSpan(_ hand: HandSnapshot) -> CGFloat {
        guard let wrist = hand.points[.wrist], let tip = hand.points[.middleTip] else { return 0 }
        return hypot(tip.x - wrist.x, tip.y - wrist.y)
    }

    private func finish() {
        guard !done else { return }
        done = true
        timer?.invalidate()
        onReady()
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
