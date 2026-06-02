//
//  GameHUD.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//
//  Contents:
//    - PlayerScorePill   → score badge, themed in OrangeBrand / BrownBrand
//    - PlayerDivider     → center vertical gradient (orange)
//    - GameExitButton    → 3-second hold-to-exit with progress ring
//    - GameTopBar        → composes the three above
//

import SwiftUI

// MARK: - PlayerScorePill

struct PlayerScorePill: View {
    let label: String
    let score: Int
    let accent: Color  

    var body: some View {
        HStack(spacing: 10) {
            Text(label)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .background(Capsule().fill(accent))

            Text("\(score)")
                .font(.system(size: 32, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: score)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 7)
        .background(Capsule().fill(.black.opacity(0.6)))
        .overlay(Capsule().strokeBorder(accent.opacity(0.85), lineWidth: 2))
    }
}

// MARK: - PlayerDivider

struct PlayerDivider: View {
    var body: some View {
        LinearGradient(
            colors: [
    
                Color("BrownBrand").opacity(1.0),
            
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 2)
        .frame(maxHeight: .infinity)
        .ignoresSafeArea()
    }
}

// MARK: - GameExitButton (hold 3s — "✕ Exit" pill with fill-from-left progress)

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
            // Base
            Capsule().fill(.white)

            GeometryReader { geo in
                HStack(spacing: 0) {
                    Capsule().fill(Color("OrangeBrand").opacity(0.85))
                        .frame(width: geo.size.width * progress)
                    Spacer(minLength: 0)
                }
            }
            .clipShape(Capsule())

            // Border
            Capsule().strokeBorder(Color("BrownBrand"), lineWidth: 2)

            // Label — flips to white once the fill covers most of it
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
    let scoreP1: Int
    let scoreP2: Int
    let winScore: Int

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            PlayerScorePill(label: "P1", score: scoreP1, accent: Color("OrangeBrand"))

            Spacer(minLength: 8)

            Text("First to \(winScore)")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(Capsule().fill(Color("BrownBrand").opacity(0.9)))
                .overlay(Capsule().strokeBorder(.white.opacity(0.35), lineWidth: 1.5))

            Spacer(minLength: 8)

            PlayerScorePill(label: "P2", score: scoreP2, accent: Color("BrownBrand"))
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        VStack {
            GameTopBar(scoreP1: 8, scoreP2: 13, winScore: 20)
            Spacer()
            GameExitButton(action: {})
                .padding(.bottom, 20)
        }
    }
}
