//
//  SoundManager.swift
//  WordCatch
//
//  Created by Gung on 05/06/26.
//
//  Plays short sound effects (and optional looping background music)
//  from audio files bundled in the app. Drop the audio files into the
//  project (e.g. "correct.mp3", "wrong.wav") and call:
//
//      SoundManager.shared.play("correct")
//
//  Sound effects can overlap; background music is a single looping track.
//

import AVFoundation

final class SoundManager {

    static let shared = SoundManager()

    private init() {
        configureSession()
    }

    /// Master switch — flip to false to mute everything.
    var isEnabled: Bool = true

    // Keep effect players alive until they finish, otherwise ARC
    // deallocates them mid-playback and the sound cuts off.
    private var effectPlayers: [AVAudioPlayer] = []
    private var musicPlayer: AVAudioPlayer?

    // Cache decoded data so repeated effects don't hit the disk each time.
    private var dataCache: [String: Data] = [:]

    // File extensions to look for, in priority order.
    private let supportedExtensions = ["mp3", "wav", "m4a", "caf", "aiff"]

    // MARK: - Public API

    /// Play a one-shot sound effect by file name (without extension).
    /// Multiple effects can play at the same time.
    func play(_ name: String, volume: Float = 1.0) {
        guard isEnabled else { return }
        guard let data = loadData(named: name) else {
            print("SoundManager: sound '\(name)' not found in bundle.")
            return
        }

        do {
            let player = try AVAudioPlayer(data: data)
            player.volume = volume
            player.delegate = cleanupDelegate
            player.prepareToPlay()
            player.play()
            effectPlayers.append(player)
        } catch {
            print("SoundManager: failed to play '\(name)': \(error)")
        }
    }

    /// Start looping background music. Pass `loops: 0` to play once.
    func playMusic(_ name: String, volume: Float = 0.5, loops: Int = -1) {
        guard isEnabled else { return }
        guard let data = loadData(named: name) else {
            print("SoundManager: music '\(name)' not found in bundle.")
            return
        }

        do {
            let player = try AVAudioPlayer(data: data)
            player.volume = volume
            player.numberOfLoops = loops
            player.prepareToPlay()
            player.play()
            musicPlayer = player
        } catch {
            print("SoundManager: failed to play music '\(name)': \(error)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    /// Stop everything immediately.
    func stopAll() {
        stopMusic()
        effectPlayers.forEach { $0.stop() }
        effectPlayers.removeAll()
    }

    // MARK: - Private

    private lazy var cleanupDelegate = EffectCleanupDelegate { [weak self] player in
        self?.effectPlayers.removeAll { $0 === player }
    }

    private func loadData(named name: String) -> Data? {
        if let cached = dataCache[name] { return cached }

        for ext in supportedExtensions {
            if let url = Bundle.main.url(forResource: name, withExtension: ext),
               let data = try? Data(contentsOf: url) {
                dataCache[name] = data
                return data
            }
        }
        return nil
    }

    private func configureSession() {
        #if os(iOS)
        do {
            // .ambient lets game audio mix with (and respect) the user's
            // music and the silent switch.
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundManager: audio session setup failed: \(error)")
        }
        #endif
    }
}

// Removes finished effect players so the array doesn't grow forever.
private final class EffectCleanupDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: (AVAudioPlayer) -> Void

    init(onFinish: @escaping (AVAudioPlayer) -> Void) {
        self.onFinish = onFinish
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish(player)
    }
}
