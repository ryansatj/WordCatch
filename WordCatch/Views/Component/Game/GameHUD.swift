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
        // Same reusable RoleButton chrome as RoundInfoPill; the accent colours
        // the label chip + score so it stays a non-interactive status display.
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

// MARK: - RoundInfoPill

struct RoundInfoPill: View {
    let category: String
    let remainingSeconds: Int

    private var timeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        // Reuses the resizable RoleButton for a consistent look; it's a status
        // display, not a control, so hit-testing is disabled.
        RoleButton(size: .lg, variant: .secondary, width: 240, height: 64, action: {}) {
            VStack(spacing: 2) {
                Text("Find \(category)")
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .foregroundColor(Color("BrownBrand"))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(timeText)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(Color("OrangeBrand"))
                    .contentTransition(.numericText())
                    .animation(.linear(duration: 0.2), value: remainingSeconds)
            }
            .padding(.horizontal, 12)
            
        }
        .allowsHitTesting(false)
        

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

// MARK: - GameTopBar

struct GameTopBar: View {
    let mode: GameMode
    let scoreP1: Int
    let scoreP2: Int
    let category: String
    let remainingSeconds: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            PlayerScorePill(label: mode == .solo ? "Score" : "P1", score: scoreP1, accent: Color("OrangeBrand"))

            Spacer(minLength: 8)

            RoundInfoPill(category: category, remainingSeconds: remainingSeconds)

            Spacer(minLength: 8)

            if mode == .duo {
                PlayerScorePill(label: "P2", score: scoreP2, accent: Color("BrownBrand"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

#Preview(traits: .landscapeLeft) {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            GameTopBar(mode: .duo, scoreP1: 8, scoreP2: -1, category: "Animals", remainingSeconds: 83)
            Spacer()
            GameExitButton(action: {})
                .padding(.bottom, 20)
        }
    }
}
