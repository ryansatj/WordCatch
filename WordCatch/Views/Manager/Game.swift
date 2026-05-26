//
//  Game.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//

import QuartzCore
import SwiftUI

@Observable
final class Game { //set di class game aja
    private(set) var words:[FallingWord] = []
    private(set) var ScroleP1 = 0
    private(set) var ScroleP2 = 0
    private(set) var winner: int?
    
    
    @ObservationIgnored var hands: () -> [HandSnapshot] = { [] }
        @ObservationIgnored var size: CGSize = .zero
        @ObservationIgnored private var timer: Timer?
        @ObservationIgnored private var last = CACurrentMediaTime()
        @ObservationIgnored private var spawnIn: CFTimeInterval = 0
        @ObservationIgnored private var spawnLeft = true
        private static let pool = ["tambah", "guguk", "doggs", "tes1", "tes2"]
    
    func start() {
        words = []; scoreP1 = 0; scoreP2 = 0; winner = nil
        spawnIn = 0; spawnLeft = true; last : = CACurrentMediaTime()
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1/60, repeats: true) { [weak self] _ in self?.tick() }
    }
    
    
    
    
    func stop() { timer?.invalidate(); timer = nil }

    private func tick() {
        guard winner == nil, size != .zero else { return }
        let now = CACurrentMediaTime(); let dt = min(now - last, 0.05); last = now
        let center = size.width / 2

        // Spawn alternately on each side so both players get words.
        spawnIn -= dt
        if spawnIn <= 0 {
            let m: CGFloat = 50
            let x: CGFloat = spawnLeft
                ? .random(in: m...max(m, center - m))
                : .random(in: (center + m)...max(center + m, size.width - m))
            words.append(FallingWord(text: Self.pool.randomElement()!,
                                     x: x, y: -30, speed: .random(in: 90...170)))
            spawnLeft.toggle()
            spawnIn = .random(in: 0.8...1.5)
        }
        for i in words.indices { words[i].y += words[i].speed * CGFloat(dt) }


        let r = min(size.width, size.height) * 0.18
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
                if left { scoreL += 1 } else { scoreR += 1 }
            }
        }
        words.removeAll { $0.caught || $0.y > size.height + 60 }

        if scoreL >= winScore { winner = 0; words = []; stop() }
        else if scoreR >= winScore { winner = 1; words = []; stop() }
    }
}


}


