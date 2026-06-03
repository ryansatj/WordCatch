//
//  HandDetection.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//

import AVFoundation
import Vision

@Observable //final itu gabisa di inherit ke class manapun
final class HandDetectionModel: NSObject {
    var tangan: [HandSnapshot] = []
    let session = AVCaptureSession()
    
    private let output = AVCaptureVideoDataOutput()
    private let queue = DispatchQueue(label: "hand", qos: .userInteractive)
    private let vision = VisionActor()
    
    
    
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
        Task {
            let snaps = await vision.detect(buffer: buffer)
            await MainActor.run { self.tangan = snaps }
        }
    }
}




actor VisionActor { //refactor 1
    private let request: VNDetectHumanHandPoseRequest = {
        let r = VNDetectHumanHandPoseRequest()
        r.maximumHandCount = 4
        return r
    }()

    func detect(buffer: CMSampleBuffer) async -> [HandSnapshot] {
        guard let pixels = CMSampleBufferGetImageBuffer(buffer) else { return [] }
        try? VNImageRequestHandler(cvPixelBuffer: pixels, orientation: .up).perform([request])

        return (request.results ?? []).enumerated().compactMap { i, obs -> HandSnapshot? in
            guard let all = try? obs.recognizedPoints(.all) else { return nil }
            let pts = all.filter { $0.value.confidence > 0.3 }
                .reduce(into: [VNHumanHandPoseObservation.JointName: CGPoint]()) {
                    $0[$1.key] = CGPoint(x: $1.value.x, y: $1.value.y)
                }
            guard !pts.isEmpty else { return nil }
            return HandSnapshot(id: i, points: pts, isOpen: isOpen(all), palmCenter: palm(all))
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
    private func palm(_ p: [VNHumanHandPoseObservation.JointName: VNRecognizedPoint]) -> CGPoint {
        let v = [.wrist, .indexMCP, .middleMCP, .ringMCP, .littleMCP]
            .compactMap { p[$0] }.filter { $0.confidence > 0.3 }
        guard !v.isEmpty else { return CGPoint(x: 0.5, y: 0.5) }
        return CGPoint(x: v.reduce(0) { $0 + $1.x } / CGFloat(v.count),
                       y: v.reduce(0) { $0 + $1.y } / CGFloat(v.count))
    }
}
