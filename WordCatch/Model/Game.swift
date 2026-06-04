//
//  Game.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//
//  Runs a two-minute category round. Players get +1 for catching words
//  that match the target category and -1 for catching distractor words.
//

import QuartzCore
import SwiftUI

struct WordMeaning: Identifiable {
    let word: String
    let meaning: String

    var id: String { word }
}

struct WordCategory {
    let name: String
    let correctWords: [WordMeaning]
    let incorrectWords: [String]

    var learningWords: [WordMeaning] {
        correctWords
    }

    func randomPrompt() -> WordPrompt {
        let shouldUseCorrectWord = Bool.random()
        if shouldUseCorrectWord, let word = correctWords.randomElement() {
            return WordPrompt(text: word.word, isCorrect: true)
        }
        if let word = incorrectWords.randomElement() {
            return WordPrompt(text: word, isCorrect: false)
        }
        return WordPrompt(text: correctWords.randomElement()?.word ?? "word", isCorrect: true)
    }
}

struct WordPrompt {
    let text: String
    let isCorrect: Bool
}

@Observable
final class Game {
    private(set) var words: [FallingWord] = []
    private(set) var ScoreP1 = 0
    private(set) var ScoreP2 = 0
    private(set) var winner: Int?
    private(set) var isFinished = false
    private(set) var mode: GameMode = .solo
    private(set) var currentCategory = WordCategory.animals
    private(set) var remainingSeconds = 10

    let roundDuration: CFTimeInterval = 10

    // MARK: - Tuning knobs

    private let maxOnScreen = 4
    private let spawnInterval: ClosedRange<CFTimeInterval> = 2.2...3.4
    private let fallDuration: ClosedRange<Double> = 5.0...7.0
    private let catchRadiusFraction: CGFloat = 0.24
    private let backoffWhenFull: CFTimeInterval = 0.4

    // MARK: - State

    @ObservationIgnored var hands: () -> [HandSnapshot] = { [] }
    @ObservationIgnored var size: CGSize = .zero
    @ObservationIgnored private var timer: Timer?
    @ObservationIgnored private var last = CACurrentMediaTime()
    @ObservationIgnored private var startedAt = CACurrentMediaTime()
    @ObservationIgnored private var spawnIn: CFTimeInterval = 0
    @ObservationIgnored private var spawnLeft = true

    private static let categories: [WordCategory] = [
        .animals,
        WordCategory(
            name: "Plants",
            correctWords: [
                WordMeaning(word: "rose", meaning: "bunga mawar"),
                WordMeaning(word: "tree", meaning: "pohon"),
                WordMeaning(word: "leaf", meaning: "daun"),
                WordMeaning(word: "grass", meaning: "rumput"),
                WordMeaning(word: "flower", meaning: "bunga"),
                WordMeaning(word: "bamboo", meaning: "bambu"),
                WordMeaning(word: "fern", meaning: "pakis"),
                WordMeaning(word: "moss", meaning: "lumut"),
                WordMeaning(word: "cactus", meaning: "kaktus"),
                WordMeaning(word: "orchid", meaning: "anggrek")
            ],
            incorrectWords: ["nose", "three", "loaf", "glass", "flour", "bottle", "fan", "mouse", "campus", "orbit"]
        ),
        WordCategory(
            name: "Stationery",
            correctWords: [
                WordMeaning(word: "pen", meaning: "pulpen"),
                WordMeaning(word: "pencil", meaning: "pensil"),
                WordMeaning(word: "paper", meaning: "kertas"),
                WordMeaning(word: "eraser", meaning: "penghapus"),
                WordMeaning(word: "ruler", meaning: "penggaris"),
                WordMeaning(word: "marker", meaning: "spidol"),
                WordMeaning(word: "book", meaning: "buku"),
                WordMeaning(word: "crayon", meaning: "krayon"),
                WordMeaning(word: "stapler", meaning: "stapler"),
                WordMeaning(word: "clip", meaning: "klip kertas")
            ],
            incorrectWords: ["pan", "parcel", "pepper", "eagle", "runner", "market", "cook", "crown", "speaker", "clap"]
        ),
        WordCategory(
            name: "House Things",
            correctWords: [
                WordMeaning(word: "chair", meaning: "kursi"),
                WordMeaning(word: "table", meaning: "meja"),
                WordMeaning(word: "lamp", meaning: "lampu"),
                WordMeaning(word: "door", meaning: "pintu"),
                WordMeaning(word: "sofa", meaning: "sofa"),
                WordMeaning(word: "clock", meaning: "jam dinding"),
                WordMeaning(word: "bed", meaning: "tempat tidur"),
                WordMeaning(word: "mirror", meaning: "cermin"),
                WordMeaning(word: "pillow", meaning: "bantal"),
                WordMeaning(word: "blanket", meaning: "selimut")
            ],
            incorrectWords: ["cheer", "tablet", "lamb", "floor", "soda", "cloud", "bread", "river", "yellow", "basket"]
        ),
        WordCategory(
            name: "Food",
            correctWords: [
                WordMeaning(word: "rice", meaning: "nasi"),
                WordMeaning(word: "bread", meaning: "roti"),
                WordMeaning(word: "apple", meaning: "apel"),
                WordMeaning(word: "banana", meaning: "pisang"),
                WordMeaning(word: "egg", meaning: "telur"),
                WordMeaning(word: "soup", meaning: "sup"),
                WordMeaning(word: "cake", meaning: "kue"),
                WordMeaning(word: "noodle", meaning: "mi"),
                WordMeaning(word: "milk", meaning: "susu"),
                WordMeaning(word: "cheese", meaning: "keju")
            ],
            incorrectWords: ["race", "beard", "apply", "bandana", "edge", "soap", "lake", "needle", "silk", "chase"]
        ),
        WordCategory(
            name: "Vehicles",
            correctWords: [
                WordMeaning(word: "car", meaning: "mobil"),
                WordMeaning(word: "bus", meaning: "bus"),
                WordMeaning(word: "train", meaning: "kereta"),
                WordMeaning(word: "bike", meaning: "sepeda"),
                WordMeaning(word: "truck", meaning: "truk"),
                WordMeaning(word: "plane", meaning: "pesawat"),
                WordMeaning(word: "boat", meaning: "perahu"),
                WordMeaning(word: "taxi", meaning: "taksi"),
                WordMeaning(word: "ship", meaning: "kapal"),
                WordMeaning(word: "scooter", meaning: "skuter")
            ],
            incorrectWords: ["cat", "bush", "rain", "bake", "track", "plant", "coat", "text", "shop", "school"]
        )
    ]

    func prepareRound(mode: GameMode) {
        self.mode = mode
        words = []
        ScoreP1 = 0
        ScoreP2 = 0
        winner = nil
        isFinished = false
        currentCategory = Self.categories.randomElement() ?? .animals
        remainingSeconds = Int(roundDuration)
        spawnIn = 0
        spawnLeft = true
        stop()
    }

    func start() {
        words = []
        ScoreP1 = 0
        ScoreP2 = 0
        winner = nil
        isFinished = false
        remainingSeconds = Int(roundDuration)
        spawnIn = 0
        spawnLeft = true
        last = CACurrentMediaTime()
        startedAt = last
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1 / 60, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard !isFinished, size != .zero else { return }

        let now = CACurrentMediaTime()
        let dt = min(now - last, 0.05)
        last = now
        updateRemainingTime(now: now)

        guard !isFinished else { return }

        spawnWordsIfNeeded(deltaTime: dt)
        moveWords(deltaTime: dt)
        catchWords()
        words.removeAll { $0.caught || $0.y > size.height + 60 }
    }

    private func updateRemainingTime(now: CFTimeInterval) {
        let elapsed = now - startedAt
        remainingSeconds = max(0, Int(ceil(roundDuration - elapsed)))

        if elapsed >= roundDuration {
            finishRound()
        }
    }

    private func spawnWordsIfNeeded(deltaTime: CFTimeInterval) {
        spawnIn -= deltaTime
        guard spawnIn <= 0 else { return }

        if words.count >= maxOnScreen {
            spawnIn = backoffWhenFull
            return
        }

        let x = spawnXPosition()
        let duration = Double.random(in: fallDuration)
        let speed = CGFloat(Double(size.height) / duration)
        let prompt = currentCategory.randomPrompt()

        words.append(FallingWord(
            text: prompt.text,
            isCorrect: prompt.isCorrect,
            x: x,
            y: -30,
            speed: speed
        ))
        spawnLeft.toggle()
        spawnIn = .random(in: spawnInterval)
    }

    private func spawnXPosition() -> CGFloat {
        let center = size.width / 2
        let margin: CGFloat = 50

        if mode == .solo {
            return .random(in: margin...max(margin, size.width - margin))
        }

        return spawnLeft
            ? .random(in: margin...max(margin, center - margin))
            : .random(in: (center + margin)...max(center + margin, size.width - margin))
    }

    private func moveWords(deltaTime: CFTimeInterval) {
        for i in words.indices {
            words[i].y += words[i].speed * CGFloat(deltaTime)
        }
    }

    private func catchWords() {
        let radius = min(size.width, size.height) * catchRadiusFraction
        // No zone restriction: any open hand can catch any word, even across
        // the centre line, so players can reach into the other side to troll.
        // Scoring still follows the word's side (see addScore), so a steal on
        // the opponent's half lands on the opponent's score.
        let palms = hands().filter { $0.isOpen }
            .map { CGPoint(x: $0.palmCenter.x * size.width, y: (1 - $0.palmCenter.y) * size.height) }

        for i in words.indices where !words[i].caught {
            let wordPoint = CGPoint(x: words[i].x, y: words[i].y)
            if palms.contains(where: { hypot(wordPoint.x - $0.x, wordPoint.y - $0.y) < radius }) {
                words[i].caught = true
                addScore(forWordX: words[i].x, isCorrect: words[i].isCorrect)
            }
        }
    }

    private func addScore(forWordX wordX: CGFloat, isCorrect: Bool) {
        let point = isCorrect ? 1 : -1

        if mode == .solo {
            ScoreP1 += point
            return
        }

        if wordX < size.width / 2 {
            ScoreP1 += point
        } else {
            ScoreP2 += point
        }
    }

    private func finishRound() {
        words = []
        isFinished = true

        if mode == .solo {
            winner = nil
        } else if ScoreP1 > ScoreP2 {
            winner = 0
        } else if ScoreP2 > ScoreP1 {
            winner = 1
        } else {
            winner = 2
        }

        stop()
    }
}

extension WordCategory {
    static let animals = WordCategory(
        name: "Animals",
        correctWords: [
            WordMeaning(word: "ant", meaning: "semut"),
            WordMeaning(word: "snake", meaning: "ular"),
            WordMeaning(word: "tiger", meaning: "harimau"),
            WordMeaning(word: "cat", meaning: "kucing"),
            WordMeaning(word: "dog", meaning: "anjing"),
            WordMeaning(word: "bird", meaning: "burung"),
            WordMeaning(word: "fish", meaning: "ikan"),
            WordMeaning(word: "lion", meaning: "singa"),
            WordMeaning(word: "horse", meaning: "kuda"),
            WordMeaning(word: "rabbit", meaning: "kelinci")
        ],
        incorrectWords: ["and", "snack", "tired", "cart", "dock", "board", "dish", "line", "house", "rapid"]
    )
}
