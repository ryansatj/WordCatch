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
//  Volume is layered: every sound's final loudness is
//      masterVolume * (sfxVolume or musicVolume) * per-call volume
//  so you can tune one channel without touching the call sites.
//
//  Sound effects can overlap; background music is a single looping track.
//

import AVFoundation

//  Sound file names used around the app (drop a matching file in the project):
//    "ButtonClick" button press
//    "correct"    caught a correct word / tutorial success
//    "wrong"      caught a distractor word (-1)
//    "countdown"  3-2-1 tick
//    "go"         round starts ("GO!")
//    "timeUp"     round over
//    "win"        score / victory screen
//    "bgm"        looping background music

final class SoundManager {

    static let shared = SoundManager()

    private init() {
        configureSession()
    }

    // MARK: - Volume controls

    /// Master switch — flip to false to mute everything.
    var isEnabled: Bool = true {
        didSet { applyMusicVolume() }
    }

    /// Overall loudness for the whole app (0...1). Scales both SFX and music.
    var masterVolume: Float = 1.0 {
        didSet { masterVolume = masterVolume.clampedVolume; applyMusicVolume() }
    }

    /// Loudness for one-shot sound effects only (0...1).
    var sfxVolume: Float = 1.0 {
        didSet { sfxVolume = sfxVolume.clampedVolume }
    }

    /// Loudness for the background music only (0...1). Applies live.
    var musicVolume: Float = 1.0 {
        didSet { musicVolume = musicVolume.clampedVolume; applyMusicVolume() }
    }

    // Keep effect players alive until they finish, otherwise ARC
    // deallocates them mid-playback and the sound cuts off.
    private var effectPlayers: [AVAudioPlayer] = []
    private var musicPlayer: AVAudioPlayer?
    // The per-call volume the current music was started with, so live
    // master/music changes can be re-applied on top of it.
    private var musicBaseVolume: Float = 1.0
    /// Name of the track currently playing, so we can avoid restarting it
    /// when the same track is requested again (e.g. menu screen changes).
    private(set) var currentMusic: String?

    // Cache decoded data so repeated effects don't hit the disk each time.
    private var dataCache: [String: Data] = [:]

    // File extensions to look for, in priority order.
    private let supportedExtensions = ["mp3", "wav", "m4a", "caf", "aiff"]

    // MARK: - Public API

    func play(_ name: String, volume: Float = 1.0) {
        guard isEnabled else { return }
        guard let data = loadData(named: name) else {
            print("SoundManager: sound '\(name)' not found in bundle.")
            return
        }

        do {
            let player = try AVAudioPlayer(data: data)
            player.volume = (masterVolume * sfxVolume * volume).clampedVolume
            player.delegate = cleanupDelegate
            player.prepareToPlay()
            player.play()
            effectPlayers.append(player)
        } catch {
            print("SoundManager: failed to play '\(name)': \(error)")
        }
    }

    /// Start looping background music. Pass `loops: 0` to play once.
    /// If `name` is already the current track, this is a no-op (the track
    /// keeps playing) unless `restart` is true. Switching to a different
    /// track replaces the old one.
    func playMusic(_ name: String, volume: Float = 0.5, loops: Int = -1, restart: Bool = false) {
        guard isEnabled else { return }

        if name == currentMusic, musicPlayer?.isPlaying == true, !restart {
            return
        }

        guard let data = loadData(named: name) else {
            print("SoundManager: music '\(name)' not found in bundle.")
            return
        }

        musicPlayer?.stop()

        do {
            let player = try AVAudioPlayer(data: data)
            musicBaseVolume = volume
            player.volume = (masterVolume * musicVolume * volume).clampedVolume
            player.numberOfLoops = loops
            player.prepareToPlay()
            player.play()
            musicPlayer = player
            currentMusic = name
        } catch {
            print("SoundManager: failed to play music '\(name)': \(error)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
        currentMusic = nil
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

    /// Re-applies the current volume settings to the live music track.
    private func applyMusicVolume() {
        let level = isEnabled ? (masterVolume * musicVolume * musicBaseVolume).clampedVolume : 0
        musicPlayer?.volume = level
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

private extension Float {
    /// Keeps a volume in AVAudioPlayer's valid 0...1 range.
    var clampedVolume: Float { min(max(self, 0), 1) }
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
