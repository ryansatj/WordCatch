//
//  Game.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//
//  Tuned for older players (57+) per the design spec:
//   - Round ~60–90 s with 8–12 words total
//   - Max 2–3 words visible at the same time
//   - Each word falls in ~5–7 seconds
//   - Forgiving catch radius
//   - Real, uplifting words instead of placeholder strings
//
//  Adaptive difficulty (speed scaling by accuracy) is intentionally
//  left out for now — keep the baseline calm and predictable first.
//

import QuartzCore
import SwiftUI

@Observable
final class Game {
    private(set) var words: [FallingWord] = []
    private(set) var ScoreP1 = 0
    private(set) var ScoreP2 = 0
    private(set) var winner: Int?

    /// First-to-N. Aimed at a ~60–90 s round with 8–12 words spawned.
    let winScore = 7

    // MARK: - Tuning knobs (one place to tweak the elder-friendly feel)

    /// Most words allowed on screen at any moment.
    private let maxOnScreen = 3
    /// Seconds between spawns when we're allowed to spawn.
    private let spawnInterval: ClosedRange<CFTimeInterval> = 5.0...7.0
    /// Seconds it takes a word to travel top → bottom.
    private let fallDuration: ClosedRange<Double> = 5.0...7.0
    /// Catch radius as a fraction of the smaller screen dimension.
    private let catchRadiusFraction: CGFloat = 0.24
    private let backoffWhenFull: CFTimeInterval = 0.5

    // MARK: - State

    @ObservationIgnored var hands: () -> [HandSnapshot] = { [] }
    @ObservationIgnored var size: CGSize = .zero
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var last = CACurrentMediaTime()
    @ObservationIgnored private var spawnIn: CFTimeInterval = 0
    @ObservationIgnored private var spawnLeft = true

    private static let pool = [
        "happy", "smile", "kind", "calm", "warm",
        "shine", "hope", "music", "garden", "family",
        "morning", "coffee", "story", "home", "love",
        "sunny", "peace", "friend", "thanks", "tea"
    ]

    func start() {
        words = []; ScoreP1 = 0; ScoreP2 = 0; winner = nil
        spawnIn = 0; spawnLeft = true; last = CACurrentMediaTime()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in self?.tick() }
    }

    func stop() { timer?.invalidate(); timer = nil }

    private func tick() {
        guard winner == nil, size != .zero else { return }
        let now = CACurrentMediaTime(); let dt = min(now - last, 0.05); last = now
        let center = size.width / 2

        // Spawning — respect the on-screen cap so the screen never feels busy.
        spawnIn -= dt
        if spawnIn <= 0 {
            if words.count >= maxOnScreen {
                spawnIn = backoffWhenFull
            } else {
                let m: CGFloat = 50
                let x: CGFloat = spawnLeft
                    ? .random(in: m...max(m, center - m))
                    : .random(in: (center + m)...max(center + m, size.width - m))

                // Speed is derived so the word actually takes `fallDuration` seconds
                // to cross the screen, regardless of device size.
                let duration = Double.random(in: fallDuration)
                let speed = CGFloat(Double(size.height) / duration)

                words.append(FallingWord(
                    text: Self.pool.randomElement()!,
                    x: x, y: -30, speed: speed
                ))
                spawnLeft.toggle()
                spawnIn = .random(in: spawnInterval)
            }
        }

        for i in words.indices { words[i].y += words[i].speed * CGFloat(dt) }

        let r = min(size.width, size.height) * catchRadiusFraction
        let palms = hands().filter { $0.isOpen }
            .map { CGPoint(x: $0.palmCenter.x * size.width, y: (1 - $0.palmCenter.y) * size.height) }
        let palmsL = palms.filter { $0.x < center }
        let palmsR = palms.filter { $0.x >= center }

        for i in words.indices where !words[i].caught {
            let w = CGPoint(x: words[i].x, y: words[i].y)
            let left = words[i].x < center
            let pool = left ? palmsL : palmsR
            if pool.contains(where: { hypot(w.x - $0.x, w.y - $0.y) < r }) {
                words[i].caught = true
                if left { ScoreP1 += 1 } else { ScoreP2 += 1 }
            }
        }
        words.removeAll { $0.caught || $0.y > size.height + 60 }

        if ScoreP1 >= winScore { winner = 0; words = []; stop() }
        else if ScoreP2 >= winScore { winner = 1; words = []; stop() }
    }
}
