//
//  HandDetection.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//
//  Vision reports hand poses with NO identity across frames: every frame it
//  re-numbers the hands, so without help they swap, flicker, and ghost-catch.
//  HandDetectionModel adds the missing stability layer:
//    1. Persistent identity  — match each hand to the nearest hand from the
//       previous frame and carry its UUID forward.
//    2. Hard cap             — keep the highest-confidence detections (4 in
//       duo, 2 in solo). Hands are NOT bound to a side: a hand can roam the
//       whole screen and catch words on the other player's half (trolling).
//    3. isOpen buffer        — open/closed flips after a couple of agreeing
//       frames, low enough to feel responsive.
//

import AVFoundation
import Vision

@Observable //final itu gabisa di inherit ke class manapun
final class HandDetectionModel: NSObject {
    var tangan: [HandSnapshot] = []
    /// Set by Gameplay after start(). Drives zone locking and the hard cap.
    var gameMode: GameMode = .solo
    let session = AVCaptureSession()

    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "hand", qos: .userInteractive)
    private let vision = VisionActor()

    // MARK: - Cross-frame tracking state
    // Previous frame's hands are remembered here so the next frame can match
    // against them. Mutated only on the main actor, in frame order.
    private var tracked: [TrackedHand] = []
    private var lastFrameTime = CMTime.zero

    // MARK: - Tuning knobs
    /// Max euclidean distance (normalised 0–1) to treat a detection as the
    /// same hand as a previous-frame hand.
    private let matchThreshold: CGFloat = 0.08
    /// A hand kept this many frames after vanishing, then dropped.
    private let maxMissedFrames = 6
    /// Frames a new isOpen value must persist before it is accepted. Kept low
    /// so opening/closing the hand registers almost immediately.
    private let openFlipFrames = 2

    override init() {
        super.init()
        session.sessionPreset = .high
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        session.addInput(input)
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: queue)
        if session.canAddOutput(output) { session.addOutput(output) }
        output.connection(with: .video)?.isVideoMirrored = true
    }

    func start() {
        guard !session.isRunning else { return }
        let s = session; queue.async { s.startRunning() }
    }
    func stop() { session.stopRunning() }
}



extension HandDetectionModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput buffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        if connection.isVideoRotationAngleSupported(90) {
            connection.videoRotationAngle = 90
        }
        let timestamp = CMSampleBufferGetPresentationTimeStamp(buffer)
        Task {
            let raw = await vision.detect(buffer: buffer)
            await MainActor.run {
                // Detection Tasks can finish out of order; the tracker only
                // makes sense fed strictly forward in time, so drop stale ones.
                guard timestamp > self.lastFrameTime else { return }
                self.lastFrameTime = timestamp
                self.tangan = self.resolve(raw)
            }
        }
    }
}



// MARK: - Identity / zone / cap / buffer pipeline

private extension HandDetectionModel {
    func resolve(_ raw: [RawHand]) -> [HandSnapshot] {
        let capped = applyCap(raw)
        tracked = matchAndBuffer(capped)
        return tracked.map {
            HandSnapshot(id: $0.id, points: $0.points, isOpen: $0.isOpen, palmCenter: $0.palmCenter)
        }
    }

    
    func applyCap(_ raw: [RawHand]) -> [RawHand] {
        switch gameMode {
        case .solo:
            return Array(raw.sorted { $0.confidence > $1.confidence }.prefix(2))
        case .duo:
            // No sections: keep the 4 highest-confidence hands anywhere on screen.
            return Array(raw.sorted { $0.confidence > $1.confidence }.prefix(4))
        }
    }


    func matchAndBuffer(_ raw: [RawHand]) -> [TrackedHand] {
        // Identity matching is purely distance-based now; a hand can be tracked
        // anywhere on screen, including across the centre line.
        var pairs: [(r: Int, t: Int, dist: CGFloat)] = []
        for (ri, rh) in raw.enumerated() {
            for ti in tracked.indices {
                let dx = rh.palmCenter.x - tracked[ti].palmCenter.x
                let dy = rh.palmCenter.y - tracked[ti].palmCenter.y
                let dist = (dx * dx + dy * dy).squareRoot()
                if dist <= matchThreshold { pairs.append((ri, ti, dist)) }
            }
        }
        pairs.sort { $0.dist < $1.dist } // greedily claim the closest pairs first

        var trackForRaw = [Int?](repeating: nil, count: raw.count)
        var usedRaw = Set<Int>(), usedTrack = Set<Int>()
        for p in pairs where !usedRaw.contains(p.r) && !usedTrack.contains(p.t) {
            trackForRaw[p.r] = p.t
            usedRaw.insert(p.r); usedTrack.insert(p.t)
        }

        var next: [TrackedHand] = []
        for (ri, rh) in raw.enumerated() {
            if let ti = trackForRaw[ri] {
                var h = tracked[ti]            // same hand: keep its UUID + zone
                h.palmCenter = rh.palmCenter
                h.points = rh.points
                h.missedFrames = 0
                bufferOpen(&h, reading: rh.isOpen)
                next.append(h)
            } else {                            // genuinely new hand
                next.append(TrackedHand(
                    id: UUID(),
                    palmCenter: rh.palmCenter,
                    points: rh.points,
                    isOpen: rh.isOpen,
                    pendingOpen: rh.isOpen,
                    pendingCount: 0,
                    missedFrames: 0))
            }
        }

        // Unmatched previous hands survive briefly so a single dropped
        // detection doesn't blink them out; removed after > maxMissedFrames.
        for ti in tracked.indices where !usedTrack.contains(ti) {
            var h = tracked[ti]
            h.missedFrames += 1
            if h.missedFrames <= maxMissedFrames { next.append(h) }
        }

        return enforceCap(next)
    }

    /// Guarantees the hard cap holds on the final list even after grace hands
    /// are carried over, preferring currently-visible hands. 4 hands in duo
    /// (two players), 2 in solo.
    func enforceCap(_ hands: [TrackedHand]) -> [TrackedHand] {
        let limit = gameMode == .duo ? 4 : 2
        guard hands.count > limit else { return hands }
        return Array(hands.sorted { $0.missedFrames < $1.missedFrames }.prefix(limit))
    }

    /// isOpen only flips after `openFlipFrames` consecutive frames agree on the
    /// new state (requirement 4); a single frame never changes it.
    func bufferOpen(_ h: inout TrackedHand, reading: Bool) {
        if reading == h.isOpen {
            h.pendingOpen = h.isOpen
            h.pendingCount = 0
        } else if reading == h.pendingOpen {
            h.pendingCount += 1
            if h.pendingCount >= openFlipFrames {
                h.isOpen = reading
                h.pendingCount = 0
            }
        } else {
            h.pendingOpen = reading
            h.pendingCount = 1
        }
    }
}



/// A single Vision detection for one frame, before identity is assigned.
private struct RawHand {
    var palmCenter: CGPoint
    var points: [VNHumanHandPoseObservation.JointName: CGPoint]
    var isOpen: Bool
    var confidence: Float
}

/// A hand remembered across frames. `id` is stable for the hand's lifetime;
/// everything else updates each frame.
private struct TrackedHand {
    let id: UUID
    var palmCenter: CGPoint
    var points: [VNHumanHandPoseObservation.JointName: CGPoint]
    var isOpen: Bool
    var pendingOpen: Bool   // isOpen value awaiting confirmation
    var pendingCount: Int   // frames it has held
    var missedFrames: Int
}



actor VisionActor { //refactor 1
    private let request: VNDetectHumanHandPoseRequest = {
        let r = VNDetectHumanHandPoseRequest()
        r.maximumHandCount = 4
        return r
    }()

    fileprivate func detect(buffer: CMSampleBuffer) -> [RawHand] {
        guard let pixels = CMSampleBufferGetImageBuffer(buffer) else { return [] }
        try? VNImageRequestHandler(cvPixelBuffer: pixels, orientation: .up).perform([request])

        return (request.results ?? []).compactMap { obs -> RawHand? in
            guard let all = try? obs.recognizedPoints(.all) else { return nil }
            let pts = all.filter { $0.value.confidence > 0.3 }
                .reduce(into: [VNHumanHandPoseObservation.JointName: CGPoint]()) {
                    $0[$1.key] = CGPoint(x: $1.value.x, y: $1.value.y)
                }
            guard !pts.isEmpty, let center = palm(all) else { return nil }
            return RawHand(palmCenter: center, points: pts, isOpen: isOpen(all), confidence: obs.confidence)
        }
    }

    // helper functions pindah ke sini
    private func d(_ a: VNRecognizedPoint, _ b: VNRecognizedPoint) -> CGFloat {
        hypot(a.x - b.x, a.y - b.y)
    }
    private func isOpen(_ p: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> Bool {
        guard let w = p[.wrist] else { return false }
        let fingers: [(VNHumanHandPoseObservation.JointName, VNHumanHandPoseObservation.JointName)] =
            [(.indexTip, .indexPIP), (.middleTip, .middlePIP), (.ringTip, .ringPIP),
             (.littleTip, .littlePIP), (.thumbTip, .thumbIP)]
        let ext = fingers.filter { f in
            guard let t = p[f.0], let m = p[f.1], t.confidence > 0.3, m.confidence > 0.3 else { return false }
            return d(t, w) > d(m, w) * 1.05
        }.count
        return ext >= 4
    }
    private func palm(_ p: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> CGPoint? {
        let v = [.wrist, .indexMCP, .middleMCP, .ringMCP, .littleMCP]
            .compactMap { p[$0] }.filter { $0.confidence > 0.3 }
        guard !v.isEmpty else { return nil }
        return CGPoint(x: v.reduce(0) { $0 + $1.x } / CGFloat(v.count),
                       y: v.reduce(0) { $0 + $1.y } / CGFloat(v.count))
    }
}
