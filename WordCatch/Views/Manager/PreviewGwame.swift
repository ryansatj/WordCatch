//
//  PreviewGwame.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//

import SwiftUI
import AVFoundation

let kCameraAngle: CGFloat = 90

// MARK: - View kamera

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.previewLayer.session = session
        v.previewLayer.videoGravity = .resizeAspectFill
        return v
    }
    func updateUIView(_ v: PreviewView, context: Context) {}

    final class PreviewView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

        override func layoutSubviews() {
            super.layoutSubviews()
            guard let c = previewLayer.connection else { return }
            if c.isVideoRotationAngleSupported(kCameraAngle) { c.videoRotationAngle = kCameraAngle }
        }
    }
}
