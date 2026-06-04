//
//  TutorialScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 04/06/26.
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

private enum TutorialPhase: Equatable {
    case letsTry
    case catchWord
    case countdown(Int)
    case playing
    case finished
}

// MARK: - Main View

struct TutorialScreen: View {
    let mode: GameMode
    let category: WordCategory
    var hands: () -> [HandSnapshot]
    var size: CGSize
    var onFinished: () -> Void
    
    @State private var phase: TutorialPhase = .letsTry
    @State private var p1Done = false
    @State private var p2Done = false
    @State private var words: [TutorialWord] = []
    @State private var timer: Timer? = nil
    @State private var last = CACurrentMediaTime()
    @State private var spawnIn: CFTimeInterval = 0.5
    
    private let maxOnScreen = 4
    private let fallDuration: ClosedRange<Double> = 4.0...5.5
    private let catchRadiusFraction: CGFloat = 0.24
    private let spawnInterval: ClosedRange<CFTimeInterval> = 1.8...3.0
    
    
    var body: some View {
        ZStack {
            // Words + game UI — only during playing phase
            if case .playing = phase {
                ForEach(words) { w in
                    FallingWordView(text: w.text, isLeftSide: mode == .duo && w.x < size.width / 2)
                        .position(x: w.x, y: w.y)
                }
                
                if mode == .duo {
                    PlayerDivider()

                    HStack(spacing: 0) {
                        sideOverlay(done: p1Done)
                        sideOverlay(done: p2Done)
                    }
                } else {
                    sideOverlay(done: p1Done)
                }
                
                if !p1Done || (mode == .duo && !p2Done) {
                    instructionBanner
                }
            }
            
            // Phase overlays
            switch phase {
            case .letsTry:
                LetsTryOverlay()
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            case .catchWord:
                CatchWordOverlay()
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            case .countdown(let n):
                CountdownOverlay(value: n)
                    .transition(.opacity)
            case .playing:
                EmptyView()
                
            case .finished:
                ReadyOverlay()
                    .transition(.scale(scale: 0.85).combined(with: .opacity))
            }
        }
        .onAppear(perform: runIntroThenStart)
        .onDisappear(perform: stopLoop)
    }
    
    // MARK: - Intro sequence
    
    private func runIntroThenStart() {
        Task {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { phase = .letsTry }
            try? await Task.sleep(for: .milliseconds(2000))
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { phase = .catchWord }
            try? await Task.sleep(for: .milliseconds(1800))
            
            for n in [3, 2, 1] {
                withAnimation(.easeInOut(duration: 0.25)) { phase = .countdown(n) }
                try? await Task.sleep(for: .milliseconds(900))
            }
            
            withAnimation(.easeOut(duration: 0.3)) { phase = .playing }
            startLoop()
        }
    }
    
    // MARK: - Sub-views
    
    @ViewBuilder
    private func sideOverlay(done: Bool) -> some View {
        ZStack {
            if done && mode == .duo && !(p1Done && p2Done) {
                Color.black.opacity(0.35)
                    .transition(.opacity)
                
                VStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color("OrangeBrand"))
                    Text("Nice catch!")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundStyle(.brownBrand)
                    Text("Ready — waiting for partner…")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color("BrownBrand").opacity(0.7))
                }
                .padding(.horizontal, 36)
                .padding(.vertical, 24)
                .background(Color(.creamBrand), in: RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color("OrangeBrand").opacity(0.7), lineWidth: 2.5)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: done)
    }
    
    private var instructionBanner: some View {
        VStack {
            CatchWordOverlay(compact: true)
            Spacer()
        }
        .padding(.top)
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
    
    private func randomX() -> CGFloat {
        let margin: CGFloat = 60
        let center = size.width / 2
        
        if mode == .solo {
            return .random(in: margin...(size.width - margin))
        }
        
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
    
    private func spawnIfNeeded(dt: CFTimeInterval) {
        spawnIn -= dt
        guard spawnIn <= 0, words.count < maxOnScreen else {
            if words.count >= maxOnScreen { spawnIn = 0.4 }
            return
        }
        
        let animals = WordCategory.animals
        let prompt = animals.randomPrompt()
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
            guard words[i].isCorrect else { continue }
            
            let wp = CGPoint(x: words[i].x, y: words[i].y)
            let isLeft = words[i].x < center
            
            let relevantPalms: [CGPoint]
            if mode == .duo {
                if isLeft && p1Done { continue }
                if !isLeft && p2Done { continue }
                relevantPalms = openPalms.filter { isLeft ? $0.x < center : $0.x >= center }
            } else {
                relevantPalms = openPalms
            }
            
            if relevantPalms.contains(where: { hypot(wp.x - $0.x, wp.y - $0.y) < radius }) {
                words[i].caught = true
                handleCatch(isLeftWord: isLeft)
            }
        }
    }
    
    private func handleCatch(isLeftWord: Bool) {
        if mode == .solo {
            withAnimation(.spring()) { p1Done = true }
            showFinished()
            return
        }
        
        withAnimation(.spring()) {
            if isLeftWord { p1Done = true } else { p2Done = true }
        }
        
        if p1Done && p2Done {
            showFinished()
        }
    }
    
    private func showFinished() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            stopLoop()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { phase = .finished }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinished()
            }
        }
    }
}


// MARK: - Preview

#Preview(traits: .landscapeRight) {
    GeometryReader { geo in
        ZStack {
            Color(red: 0.15, green: 0.15, blue: 0.18).ignoresSafeArea()

            TutorialScreen(
                mode: .duo,
                category: .animals,
                hands: { [] },
                size: geo.size,
                onFinished: { print("Tutorial done!") }
            )
        }
    }
}
