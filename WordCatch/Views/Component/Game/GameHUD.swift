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

    private var timeText: String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    var body: some View {
        RoleButton(size: .lg, variant: .primary, width: 150, height: 54, action: {}) {
            HStack(spacing: 8) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 20, weight: .bold))
                Text(timeText)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .contentTransition(.numericText())
            }
            .foregroundColor(.white)
        }
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

    @State private var progress: CGFloat = 0
    @State private var pressing = false
    @State private var holdTask: Task<Void, Never>? = nil

    private let holdSeconds: Double = 1.0
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
        .scaleEffect(pressing ? 0.97 : 1.0)
        .animation(.easeOut(duration: 0.1), value: pressing)
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
    }

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
            GameExitButton(action: onExit)
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
