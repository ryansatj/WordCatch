//
//  Gameplay.swift
//  WordCatch
//
//  Created by Gung  on 26/05/26.
//

import SwiftUI
import Vision



struct Gameplay: View {
    @State private var manager = HandDetectionModel()
    @State private var game = Game()

    private static let chains: [[VNHumanHandPoseObservation.JointName]] = [
        [.wrist, .thumbCMC, .thumbMP, .thumbIP, .thumbTip],
        [.wrist, .indexMCP, .indexPIP, .indexDIP, .indexTip],
        [.wrist, .middleMCP, .middlePIP, .middleDIP, .middleTip],
        [.wrist, .ringMCP, .ringPIP, .ringDIP, .ringTip],
        [.wrist, .littleMCP, .littlePIP, .littleDIP, .littleTip],
        [.indexMCP, .middleMCP, .ringMCP, .littleMCP],
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                CameraPreviewView(session: manager.session).ignoresSafeArea()

                Canvas { ctx, size in
                    for hand in $manager.hands {
                        let c: Color = hand.isOpen ? .green : .white.opacity(0.7)
                        func pt(_ j: VNHumanHandPoseObservation.JointName) -> CGPoint? {
                            hand.points[j].map { CGPoint(x: $0.x * size.width, y: (1 - $0.y) * size.height) }
                        }
                        for chain in Self.chains {
                            var path = Path(); var on = false
                            for j in chain {
                                guard let p = pt(j) else { on = false; continue }
                                on ? path.addLine(to: p) : path.move(to: p); on = true
                            }
                            ctx.stroke(path, with: .color(c.opacity(0.85)), lineWidth: 2.5)
                        }
                        for (_, raw) in hand.points {
                            let p = CGPoint(x: raw.x * size.width, y: (1 - raw.y) * size.height)
                            ctx.fill(Path(ellipseIn: CGRect(x: p.x - 4, y: p.y - 4, width: 8, height: 8)), with: .color(c))
                        }
                    }
                }
                .ignoresSafeArea().allowsHitTesting(false)

                // Divider between the two players
                Rectangle()
                    .fill(.white.opacity(0.5))
                    .frame(width: 3)
                    .frame(maxHeight: .infinity)
                    .ignoresSafeArea()

                ForEach(game.words) { w in
                    let left = w.x < geo.size.width / 2
                    Text(w.text)
                        .font(.system(size: 30, weight: .heavy, design: .rounded))
                        .foregroundColor(.white).shadow(color: .black.opacity(0.7), radius: 3, y: 2)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Capsule().fill(LinearGradient(
                            colors: left ? [.blue, .cyan] : [.red, .orange],
                            startPoint: .top, endPoint: .bottom)))
                        .position(x: w.x, y: w.y)
                }

                VStack {
                    HStack(alignment: .top) {
                        pill("P1   \(game.scoreL)")
                        Spacer()
                        Text("First to \(game.winScore)")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12).padding(.vertical, 6)
                            .background(Capsule().fill(.black.opacity(0.4)))
                        Spacer()
                        pill("P2   \(game.scoreR)")
                    }.padding(24)
                    Spacer()
                }

                if let winner = game.winner {
                    ZStack {
                        Color.black.opacity(0.6).ignoresSafeArea()
                        VStack(spacing: 20) {
                            Text(winner == 0 ? "Player 1 Wins! 🎉" : "Player 2 Wins! 🎉")
                                .font(.system(size: 48, weight: .black, design: .rounded)).foregroundColor(.white)
                            Button("Play Again") { game.size = geo.size; game.start() }
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.black).padding(.horizontal, 32).padding(.vertical, 14)
                                .background(Capsule().fill(.white))
                        }
                    }
                }
            }
            .onAppear {
                manager.start(); game.hands = { manager.hands }; game.size = geo.size; game.start()
            }
            .onChange(of: geo.size) { _, s in game.size = s }
            .onDisappear { manager.stop(); game.stop() }
        }
    }

    private func pill(_ t: String) -> some View {
        Text(t).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.white)
            .padding(.horizontal, 16).padding(.vertical, 8)
            .background(Capsule().fill(.black.opacity(0.5)))
    }
}

#Preview { ContentView() }
