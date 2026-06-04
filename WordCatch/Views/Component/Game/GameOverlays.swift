//
//  GameOverlays.swift
//  WordCatch
//
//  Created by Gung  on 29/05/26.
//

import SwiftUI

// NOTE: ScoreResultScreen and LearningScreen have been moved to separate files.

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

// MARK: - Shared Background

struct CelebrationBackground: View {
    @State private var spin = false

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
                .rotationEffect(.degrees(spin ? 360 : 0))
                .animation(.linear(duration: 85).repeatForever(autoreverses: false), value: spin)
                .ignoresSafeArea()
        }
        .onAppear { spin = true }
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

// MARK: - Previews

#Preview("CameraLoading", traits: .landscapeRight) {
    CameraLoadingOverlay()
}

#Preview("CategoryPrompt", traits: .landscapeRight) {
    CategoryPromptOverlay(category: "Animals")
}

#Preview("Countdown – 3", traits: .landscapeRight) {
    CountdownOverlay(value: 3)
}

#Preview("Countdown – GO", traits: .landscapeRight) {
    CountdownOverlay(value: 0)
}

#Preview("TimeUp", traits: .landscapeRight) {
    TimeUpOverlay(onContinue: {})
}

#Preview("CelebrationBackground", traits: .landscapeRight) {
    CelebrationBackground()
}

