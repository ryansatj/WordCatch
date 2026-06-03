//
//  GameOverlays.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//

import SwiftUI

// MARK: - CameraLoadingOverlay

struct CameraLoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.9).ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color("OrangeBrand"))
                    .scaleEffect(1.5)

                Text("Preparing camera...")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text("Make sure you have good lighting")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - CategoryPromptOverlay

struct CategoryPromptOverlay: View {
    let category: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.58).ignoresSafeArea()

            VStack(spacing: 10) {
                Text("Find")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.78))

                Text(category)
                    .font(.system(size: 76, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)
                    .shadow(color: .black.opacity(0.55), radius: 8, y: 4)

                Text("Correct word +1  |  Wrong word -1")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color("OrangeBrand"))
            }
            .padding(.horizontal, 32)
        }
    }
}

// MARK: - CountdownOverlay

struct CountdownOverlay: View {
    let value: Int?

    var body: some View {
        ZStack {
            if let v = value {
                Color.black.opacity(0.4).ignoresSafeArea()

                Text(v == 0 ? "GO!" : "\(v)")
                    .font(.system(size: 160, weight: .black, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: v == 0 ? [.yellow, .orange] : [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.6), radius: 10, y: 6)
                    .id(v)
                    .transition(.scale(scale: 1.7).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.45, dampingFraction: 0.65), value: value)
    }
}

// MARK: - TimeUpOverlay

struct TimeUpOverlay: View {
    let onContinue: () -> Void

    var body: some View {
        Button(action: onContinue) {
            ZStack {
                Color.black.opacity(0.58).ignoresSafeArea()

                VStack(spacing: 4) {
                    Image("MascotFace")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 120)

                    OutlinedGameText(text: "TIME'S UP!", fontSize: 88)
                        .frame(height: 120)

                    Text("Tap to continue")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.85))
                }
            }
        }
        .buttonStyle(NoFadeButtonStyle())
    }
}

// MARK: - ScoreResultScreen

struct ScoreResultScreen: View {
    let mode: GameMode
    let winner: Int?
    let scoreP1: Int
    let scoreP2: Int
    let onContinue: () -> Void

    private var winnerTitle: String {
        if mode == .solo { return "YOUR SCORE" }
        if winner == 0 { return "PLAYER 1\nWINS!" }
        if winner == 1 { return "PLAYER 2\nWINS!" }
        return "DRAW!"
    }

    var body: some View {
        ZStack {
            CelebrationBackground()

            VStack(spacing: 18) {
                Image("MascotFace")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 122, height: 92)

                if mode == .solo {
                    soloScoreCard
                } else {
                    duoScoreContent
                }

                RoleButton(title: "Continue", size: .md, action: onContinue)
                    .frame(width: 165)
                    .padding(.top, 2)
            }
            .padding(.horizontal, 48)
        }
    }

    private var soloScoreCard: some View {
        VStack(spacing: 16) {
            Text("- \(winnerTitle) -")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundColor(Color("BrownBrand"))
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text("\(scoreP1)")
                .font(.system(size: 62, weight: .black, design: .rounded))
                .foregroundColor(Color("OrangeBrand"))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 44)
        .padding(.vertical, 28)
        .frame(maxWidth: 470)
        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
        .overlay(RoundedRectangle(cornerRadius: 8).strokeBorder(Color("OrangeBrand"), lineWidth: 4))
        .shadow(color: .black.opacity(0.18), radius: 4, y: 4)
    }

    private var duoScoreContent: some View {
        VStack(spacing: 14) {
            Text(winnerTitle)
                .font(.system(size: 48, weight: .black, design: .rounded))
                .foregroundColor(Color("BrownBrand"))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            HStack(spacing: 22) {
                scoreCard(title: "PLAYER 1 SCORED", score: scoreP1, highlighted: winner == 0)
                scoreCard(title: "PLAYER 2 SCORED", score: scoreP2, highlighted: winner == 1)
            }
        }
    }

    private func scoreCard(title: String, score: Int, highlighted: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundColor(Color("BrownBrand"))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("\(score)")
                .font(.system(size: 58, weight: .black, design: .rounded))
                .foregroundColor(Color("OrangeBrand"))
                .contentTransition(.numericText())
        }
        .padding(.horizontal, 12)
        .frame(width: 205, height: 122)
        .background(RoundedRectangle(cornerRadius: 8).fill(.white))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(highlighted ? Color("OrangeBrand") : .gray.opacity(0.7), lineWidth: highlighted ? 3 : 1.5)
        )
        .shadow(color: .black.opacity(0.18), radius: 3, y: 3)
    }
}

// MARK: - LearningScreen

struct LearningScreen: View {
    let category: WordCategory
    let onPlayAgain: () -> Void
    let onBackHome: () -> Void

    var body: some View {
        ZStack {
            CelebrationBackground()

            VStack(spacing: 18) {
                Text("Learn: \(category.name)")
                    .font(.system(size: 34, weight: .black, design: .rounded))
                    .foregroundColor(Color("BrownBrand"))
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    ForEach(category.learningWords.prefix(6)) { item in
                        HStack(spacing: 28) {
                            Text(item.word.uppercased())
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(Color("BrownBrand"))
                                .frame(width: 150, alignment: .trailing)

                            Text(item.meaning.uppercased())
                                .font(.system(size: 20, weight: .black, design: .rounded))
                                .foregroundColor(Color("OrangeBrand"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineLimit(1)
                                .minimumScaleFactor(0.65)
                        }
                    }
                }
                .frame(maxWidth: 620)

                HStack(spacing: 96) {
                    RoleButton(title: "Play Again", size: .md, action: onPlayAgain)
                        .frame(width: 195)
                    RoleButton(title: "Back to Home", size: .md, action: onBackHome)
                        .frame(width: 195)
                }
                .padding(.top, 6)
            }
            .padding(.horizontal, 56)
        }
    }
}

// MARK: - Shared Background

struct CelebrationBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 1.0, green: 0.94, blue: 0.86), .white, Color(red: 1.0, green: 0.88, blue: 0.76)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            SunburstShape()
                .fill(Color("OrangeBrand").opacity(0.08))
                .ignoresSafeArea()

            VStack {
                HStack {
                    HalftoneDots()
                        .fill(Color("OrangeBrand").opacity(0.42))
                        .frame(width: 160, height: 120)
                    Spacer()
                }
                Spacer()
                HStack {
                    Spacer()
                    HalftoneDots()
                        .fill(Color("OrangeBrand").opacity(0.34))
                        .frame(width: 170, height: 120)
                }
            }
            .ignoresSafeArea()
        }
    }
}

struct SunburstShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = max(rect.width, rect.height)
        let rayCount = 18

        for index in 0..<rayCount where index.isMultiple(of: 2) {
            let startAngle = Angle.degrees(Double(index) * 360 / Double(rayCount) - 90)
            let endAngle = Angle.degrees(Double(index + 1) * 360 / Double(rayCount) - 90)
            path.move(to: center)
            path.addLine(to: CGPoint(
                x: center.x + cos(startAngle.radians) * radius,
                y: center.y + sin(startAngle.radians) * radius
            ))
            path.addLine(to: CGPoint(
                x: center.x + cos(endAngle.radians) * radius,
                y: center.y + sin(endAngle.radians) * radius
            ))
            path.closeSubpath()
        }

        return path
    }
}

struct HalftoneDots: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let spacing: CGFloat = 12
        let dotSize: CGFloat = 4
        var y = rect.minY

        while y <= rect.maxY {
            var x = rect.minX
            while x <= rect.maxX {
                path.addEllipse(in: CGRect(x: x, y: y, width: dotSize, height: dotSize))
                x += spacing
            }
            y += spacing
        }

        return path
    }
}
