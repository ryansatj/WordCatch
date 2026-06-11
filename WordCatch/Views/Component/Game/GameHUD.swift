//
//  GameHUD.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//

import SwiftUI

// MARK: - PlayerScorePill

struct PlayerScorePill: View {
    let label: String
    let score: Int
    let accent: Color

    var body: some View {
     
        RoleButton(size: .lg, variant: .secondary, width: 132, height: 64, action: {}) {
            HStack(spacing: 10) {
                Text(label)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 11)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(accent))

                Text("\(score)")
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundColor(accent)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: score)
            }
            .padding(.horizontal, 12)
        }
        .allowsHitTesting(false)
    }
}

// MARK: - PlayerDivider

struct PlayerDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color("BrownBrand"))
            .frame(width: 2)
            .frame(maxHeight: .infinity)
            .ignoresSafeArea()
    }
}

// MARK: - TimerPill

struct TimerPill: View {
    let seconds: Int

    // Chunky-pill styling (mirrors RoleButton .primary so the look matches).
    private let width: CGFloat = 150
    private let height: CGFloat = 54
    private let radius: CGFloat = 16
    private let shadowDepth: CGFloat = 4

    /// Final 5 seconds: turn the pill red to signal time's almost up.
    private var urgent: Bool { seconds <= 5 }
    private var color: Color { urgent ? .red : Color("OrangeBrand") }

    private var timeText: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        ZStack(alignment: .top) {
            ZStack {
                RoundedRectangle(cornerRadius: radius).fill(color)
                RoundedRectangle(cornerRadius: radius).fill(Color.black.opacity(0.3))
            }
            .frame(width: width, height: height)
            .offset(y: shadowDepth)

            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20, weight: .bold))
                Text(timeText)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .contentTransition(.numericText())
            }
            .foregroundColor(.white)
            .frame(width: width, height: height)
            .background(RoundedRectangle(cornerRadius: radius).fill(color))
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: radius).strokeBorder(color, lineWidth: 2)
                    RoundedRectangle(cornerRadius: radius).strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                }
            )
        }
        .frame(height: height + shadowDepth)
        .animation(.easeInOut(duration: 0.25), value: urgent)
        .allowsHitTesting(false)
    }
}

// MARK: - RoundHeader

struct RoundHeader: View {
    let seconds: Int
    let category: String
    let raised: Bool

    var body: some View {
        // Measures its own container so positioning is identical in the
        // preview and in gameplay (no externally-passed size to get out of sync).
        GeometryReader { geo in
            VStack(spacing: 10) {
                CatchWordOverlay(category: category, compact: true)
                    .zIndex(1)        //z index satu artinya depan
                    .offset()
                TimerPill(seconds: seconds)
                    .offset(y: -20)
                    .zIndex(-1)           // ini belakang
            }
            .scaleEffect(raised ? 1.0 : 1.6)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            .offset(y: raised ? -(geo.size.height / 2) + 80 : 0)
        }
    }
}

// MARK: - GameExitButton

struct GameExitButton: View {
    let action: () -> Void
    /// Live hand snapshots + the full-screen size used to map them, so the
    /// button can be triggered by hovering an open hand over it (no touch).
    var hands: () -> [HandSnapshot] = { [] }
    var screenSize: CGSize = .zero

    @State private var progress: CGFloat = 0
    @State private var pressing = false
    @State private var holdTask: Task<Void, Never>? = nil

    // Hand-hover state
    @State private var frame: CGRect = .zero        // button's frame in screen space
    @State private var hoverTimer: Timer? = nil
    @State private var exited = false

    private let holdSeconds: Double = 1.0
    private let hoverHoldSeconds: Double = 1.4      // hold a hand a touch longer to avoid accidental exits
    private let hoverPadding: CGFloat = 34          // generous hit area around the button
    private let tickRate: Double = 1.0 / 30.0
    private let height: CGFloat = 44
    private let width: CGFloat = 120

    var body: some View {
        ZStack {
            Capsule().fill(.white)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    Capsule().fill(Color("OrangeBrand").opacity(0.85))
                        .frame(width: geo.size.width * progress)
                    Spacer(minLength: 0)
                }
            }
            .clipShape(Capsule())

            Capsule().strokeBorder(Color("BrownBrand"), lineWidth: 2)

            HStack(spacing: 8) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                Text("Hold To Exit")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(progress > 0.55 ? .white : Color("BrownBrand"))
            .animation(.easeInOut(duration: 0.2), value: progress)
        }
        .frame(width: width, height: height)
        .scaleEffect(pressing || progress > 0 ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.1), value: pressing)
        // Track the button's position on screen so we can test palms against it.
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { frame = geo.frame(in: .global) }
                    .onChange(of: geo.frame(in: .global)) { _, f in frame = f }
            }
        )
        .contentShape(Capsule())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard !pressing else { return }
                    startHold()
                }
                .onEnded { _ in
                    cancelHold()
                }
        )
        .onAppear { startHoverLoop() }
        .onDisappear { hoverTimer?.invalidate(); hoverTimer = nil }
    }

    // MARK: - Hand hover

    private func startHoverLoop() {
        hoverTimer?.invalidate()
        hoverTimer = Timer.scheduledTimer(withTimeInterval: tickRate, repeats: true) { _ in
            hoverTick()
        }
    }

    private func hoverTick() {
        guard !exited, !pressing else { return }        // touch hold takes priority
        guard screenSize != .zero, frame != .zero else { return }

        let hitArea = frame.insetBy(dx: -hoverPadding, dy: -hoverPadding)
        let hovering = hands().contains { h in
            let p = CGPoint(x: h.palmCenter.x * screenSize.width,
                            y: (1 - h.palmCenter.y) * screenSize.height)
            return hitArea.contains(p)
        }

        if hovering {
            progress = min(1, progress + CGFloat(tickRate / hoverHoldSeconds))
            if progress >= 1 { triggerExit() }
        } else if progress > 0 {
            // Decay back down when the hand leaves before the hold completes.
            progress = max(0, progress - CGFloat(tickRate / 0.4))
        }
    }

    private func triggerExit() {
        exited = true
        hoverTimer?.invalidate()
        action()
    }

    // MARK: - Touch hold (fallback)

    private func startHold() {
        pressing = true
        withAnimation(.linear(duration: holdSeconds)) { progress = 1.0 }
        holdTask?.cancel()
        holdTask = Task {
            try? await Task.sleep(for: .seconds(holdSeconds))
            if !Task.isCancelled {
                await MainActor.run {
                    action()
                    pressing = false
                    progress = 0
                }
            }
        }
    }

    private func cancelHold() {
        holdTask?.cancel()
        pressing = false
        withAnimation(.easeOut(duration: 0.2)) { progress = 0 }
    }
}



// MARK: - PlayingHUD

/// In-game side HUD: score pills along the top, hold-to-exit at the bottom.
struct PlayingHUD: View {
    let mode: GameMode
    let scoreP1: Int
    let scoreP2: Int
    let onExit: () -> Void
    var hands: () -> [HandSnapshot] = { [] }
    var screenSize: CGSize = .zero

    var body: some View {
        VStack {
            HStack(spacing: 12) {
                PlayerScorePill(label: mode == .solo ? "Score" : "P1",
                                score: scoreP1, accent: Color("OrangeBrand"))
                Spacer()
                if mode == .duo {
                    PlayerScorePill(label: "P2", score: scoreP2, accent: Color("BrownBrand"))
                }
            }
            Spacer()
            GameExitButton(action: onExit, hands: hands, screenSize: screenSize)
                .padding(.bottom, 20)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

// MARK: - SkipButton

struct SkipButton: View {
    let action: () -> Void

    var body: some View {
        VStack {
            HStack {
                Spacer()
                RoleButton(title: "Skip", size: .md, variant: .primary, width: 96, height: 40, action: action)
            }
            .offset(x: 20, y: -160)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

#Preview(traits: .landscapeLeft) {
    ZStack {
        Color.black.ignoresSafeArea()
        RoundHeader(seconds: 100, category: "Animals", raised: true)
        PlayingHUD(mode: .duo, scoreP1: 8, scoreP2: -1, onExit: {})
    }
}
