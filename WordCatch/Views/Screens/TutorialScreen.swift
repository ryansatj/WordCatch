//
//  TutorialScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
//

//
//  TutorialScreen.swift
//  WordCatch
//

import SwiftUI
import QuartzCore

// MARK: - Model

private struct TutorialWord: Identifiable {
    let id = UUID()
    let text: String
    let isCorrect: Bool
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
    var caught = false
}

// MARK: - Main View

struct TutorialScreen: View {
    let mode: GameMode
    let category: WordCategory
    var hands: () -> [HandSnapshot]
    var size: CGSize
    var onFinished: () -> Void

    // Per-player catch state
    @State private var p1Done = false
    @State private var p2Done = false

    @State private var words: [TutorialWord] = []
    @State private var timer: Timer? = nil
    @State private var last = CACurrentMediaTime()
    @State private var spawnIn: CFTimeInterval = 0.5

    private let maxOnScreen = 5
    private let spawnInterval: ClosedRange<CFTimeInterval> = 1.8...3.0
    private let fallDuration: ClosedRange<Double> = 5.0...7.5
    private let catchRadiusFraction: CGFloat = 0.24

    var body: some View {
        ZStack {
            // Falling words
            ForEach(words) { w in
                FallingWordView(text: w.text, isLeftSide: mode == .duo && w.x < size.width / 2)
                    .position(x: w.x, y: w.y)
            }

            // Overlays per side
            if mode == .duo {
                HStack(spacing: 0) {
                    sideOverlay(done: p1Done, label: "P1")
                    sideOverlay(done: p2Done, label: "P2")
                }
            } else {
                sideOverlay(done: p1Done, label: nil)
            }

            // Instruction banner at top
            if !p1Done || (mode == .duo && !p2Done) {
                instructionBanner
            }
        }
        .onAppear(perform: startLoop)
        .onDisappear(perform: stopLoop)
    }

    // MARK: - Sub-views

    @ViewBuilder
    private func sideOverlay(done: Bool, label: String?) -> some View {
        ZStack {
            if done {
                // Dim + checkmark while waiting for partner
                if mode == .duo && !(p1Done && p2Done) {
                    Color.black.opacity(0.35)
                        .transition(.opacity)

                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(.green)
                        Text("Nice catch!")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white)
                        Text("Wait for partner...")
                            .font(.system(size: 14))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: done)
    }

    private var instructionBanner: some View {
        VStack {
            Text(bannerText)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(.black.opacity(0.55))
                .clipShape(Capsule())
                .padding(.top, 16)
            Spacer()
        }
        .transition(.opacity)
        .animation(.easeInOut, value: p1Done || p2Done)
    }

    private var bannerText: String {
        if mode == .solo {
            return "Catch a \(category.name.lowercased()) word to start!"
        }
        if p1Done && !p2Done { return "P2 — catch a \(category.name.lowercased()) word!" }
        if p2Done && !p1Done { return "P1 — catch a \(category.name.lowercased()) word!" }
        return "Each player: catch one \(category.name.lowercased()) word!"
    }

    // MARK: - Game loop

    private func startLoop() {
        last = CACurrentMediaTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { _ in
            tick()
        }
    }

    private func stopLoop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard size != .zero else { return }
        let now = CACurrentMediaTime()
        let dt = min(now - last, 0.05)
        last = now

        spawnIfNeeded(dt: dt)
        moveWords(dt: dt)
        checkCatches()
        words.removeAll { $0.caught || $0.y > size.height + 60 }
    }

    private func spawnIfNeeded(dt: CFTimeInterval) {
        spawnIn -= dt
        guard spawnIn <= 0, words.count < maxOnScreen else {
            if words.count >= maxOnScreen { spawnIn = 0.4 }
            return
        }

        let prompt = category.randomPrompt()
        let duration = Double.random(in: fallDuration)
        let speed = CGFloat(size.height) / CGFloat(duration)
        let x = randomX()

        words.append(TutorialWord(
            text: prompt.text,
            isCorrect: prompt.isCorrect,
            x: x,
            y: -30,
            speed: speed
        ))
        spawnIn = .random(in: spawnInterval)
    }

    private func randomX() -> CGFloat {
        let margin: CGFloat = 60
        let center = size.width / 2

        if mode == .solo {
            return .random(in: margin...(size.width - margin))
        }

        // Spawn on sides that aren't done yet
        let leftAvail  = !p1Done
        let rightAvail = !p2Done

        if leftAvail && rightAvail {
            return Bool.random()
                ? .random(in: margin...(center - margin))
                : .random(in: (center + margin)...(size.width - margin))
        } else if leftAvail {
            return .random(in: margin...(center - margin))
        } else {
            return .random(in: (center + margin)...(size.width - margin))
        }
    }

    private func moveWords(dt: CFTimeInterval) {
        for i in words.indices {
            words[i].y += words[i].speed * CGFloat(dt)
        }
    }

    private func checkCatches() {
        let radius = min(size.width, size.height) * catchRadiusFraction
        let center = size.width / 2

        let openPalms = hands()
            .filter { $0.isOpen }
            .map { CGPoint(
                x: $0.palmCenter.x * size.width,
                y: (1 - $0.palmCenter.y) * size.height
            )}

        for i in words.indices where !words[i].caught {
            guard words[i].isCorrect else { continue } // only correct words count for tutorial

            let wp = CGPoint(x: words[i].x, y: words[i].y)

            let relevantPalms: [CGPoint]
            if mode == .duo {
                // Left side = P1, right side = P2
                let isLeft = words[i].x < center
                if isLeft && p1Done { continue }   // P1 already done, skip left words
                if !isLeft && p2Done { continue }  // P2 already done, skip right words
                relevantPalms = openPalms.filter { isLeft ? $0.x < center : $0.x >= center }
            } else {
                relevantPalms = openPalms
            }

            let caught = relevantPalms.contains {
                hypot(wp.x - $0.x, wp.y - $0.y) < radius
            }

            if caught {
                words[i].caught = true
                handleCatch(isLeftWord: words[i].x < center)
            }
        }
    }

    private func handleCatch(isLeftWord: Bool) {
        if mode == .solo {
            withAnimation(.spring()) { p1Done = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onFinished()
            }
            return
        }

        // Duo
        withAnimation(.spring()) {
            if isLeftWord { p1Done = true } else { p2Done = true }
        }

        if p1Done && p2Done {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                onFinished()
            }
        }
    }
}

// MARK: - Preview

#Preview(traits: .landscapeRight) {
    GeometryReader { geo in
        ZStack {
            // Fake camera background
            Color(red: 0.15, green: 0.15, blue: 0.18)
                .ignoresSafeArea()

            TutorialScreen(
                mode: .duo,                          // change to .solo to preview solo
                category: .animals,                  // change to any WordCategory
                hands: { [] },                       // no real hands in preview
                size: geo.size,
                onFinished: { print("Tutorial done!") }
            )
        }
    }
}
