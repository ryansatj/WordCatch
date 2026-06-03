//
//  HandSkeletonView.swift
//  WordCatch
//
//  Canvas-based hand skeleton overlay. Renders Vision joint points
//  and finger chains. The skeleton lights up in OrangeBrand when the
//  palm is open (= ready to catch), white otherwise.
//

import SwiftUI
import Vision

struct HandSkeletonView: View {
    let hands: [HandSnapshot]

    private static let chains: [[VNHumanHandPoseObservation.JointName]] = [
        [.wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip],
        [.wrist, .indexMCP, .indexPIP, .indexDIP, .indexTip],
        [.wrist, .middleMCP, .middlePIP, .middleDIP, .middleTip],
        [.wrist, .ringMCP, .ringPIP, .ringDIP, .ringTip],
        [.wrist, .littleMCP, .littlePIP, .littleDIP, .littleTip],
        [.indexMCP, .middleMCP, .ringMCP, .littleMCP]
    ]

    var body: some View {
        Canvas { ctx, size in
            for hand in hands {
                let color: Color = hand.isOpen
                    ? Color("OrangeBrand")
                    : .white.opacity(0.7)

                func toScreen(_ j: VNHumanHandPoseObservation.JointName) -> CGPoint? {
                    hand.points[j].map {
                        CGPoint(x: $0.x * size.width, y: (1 - $0.y) * size.height)
                    }
                }

                for chain in Self.chains {
                    var path = Path()
                    var started = false
                    for joint in chain {
                        guard let p = toScreen(joint) else { started = false; continue }
                        if started { path.addLine(to: p) } else { path.move(to: p) }
                        started = true
                    }
                    ctx.stroke(path, with: .color(color.opacity(0.85)), lineWidth: 2.5)
                }

                for (_, raw) in hand.points {
                    let p = CGPoint(x: raw.x * size.width, y: (1 - raw.y) * size.height)
                    ctx.fill(
                        Path(ellipseIn: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)),
                        with: .color(color)
                    )
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}
