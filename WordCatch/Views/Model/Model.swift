//
//  Model.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//


import CoreGraphics
import Foundation
import Vision

struct FallingWord: Identifiable {
    let id = UUID()
    var text: String
    var x: CGFloat
    var y: CGFloat
    var speed: CGFloat
    var caught = false
}

struct HandSnapshot: Identifiable {
    let id: Int
    var points: [VNHumanHandPoseObservation.JointName: CGPoint]
    var isOpen: Bool
    var palmCenter: CGPoint
}
