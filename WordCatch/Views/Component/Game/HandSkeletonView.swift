//
//  HandSkeletonView.swift
//  WordCatch
//
//  Shows friendly hand assets over the detected palm position instead of
//  exposing the raw Vision hand skeleton to players.
//

import SwiftUI

struct HandSkeletonView: View {
    let hands: [HandSnapshot]

    private let handSize: CGFloat = 118

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(hands) { hand in
                    Image(hand.isOpen ? "PandaHand" : "Image")
                        .resizable()
                        .scaledToFit()
                        .frame(width: handSize, height: handSize)
                        .shadow(color: .black.opacity(0.28), radius: 7, y: 4)
                        .scaleEffect(hand.isOpen ? 1.08 : 0.96)
                        .opacity(hand.isOpen ? 1.0 : 0.78)
                        .position(handPosition(for: hand, in: geo.size))
                        .animation(.spring(response: 0.24, dampingFraction: 0.72), value: hand.isOpen)
                        .animation(.linear(duration: 0.06), value: hand.palmCenter)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    private func handPosition(for hand: HandSnapshot, in size: CGSize) -> CGPoint {
        CGPoint(
            x: hand.palmCenter.x * size.width,
            y: (1 - hand.palmCenter.y) * size.height
        )
    }
}
