//
//  Tutor.swift
//  WordCatch
//
//  Auto-advances through setup pages so older users don't have to
//  hunt for a "Next" button. Once it reaches the last page the
//  "I'm Ready!" CTA appears. Swiping is still supported so they
//  can swipe back to re-read a previous page at their own pace —
//  any manual swipe cancels auto-advance.
//

import SwiftUI

struct TutorialCarouselScreen: View {
    var onBack: () -> Void = {}
    var onStart: () -> Void = {}

    @State private var index = 0
    @State private var autoAdvanceTask: Task<Void, Never>? = nil

    private let pages: [SetupPage] = [
        SetupPage(image: "Position1", subtitle: "Place the device and step back now"),
        SetupPage(image: "Position2", subtitle: "Stand far enough so your upper body is visible"),
        SetupPage(image: "Position2", subtitle: "Open your hand wide to catch a falling word")
    ]

    private let perPageSeconds: Double = 2.0

    private var isLastPage: Bool { index == pages.count - 1 }

    var body: some View {
        ZStack {
            Image("LanscapePolos")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            Image(pages[index].image)
                .resizable()
                .offset(y: 40)
                .scaledToFit()
                .frame(maxHeight: 260)
                .padding(.horizontal, 60)
                .id("img-\(index)")
                .transition(.opacity)

            VStack(spacing: 8) {
                HStack {
                    IconButton2(systemName: "chevron.left", action: backTapped)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)

                Text("Let's Get Setup")
                    .font(.system(size: 32, weight: .heavy))
                    .fontDesign(.rounded)
                    .foregroundColor(Color("BrownBrand"))
                    .padding(.top, 4)
                    .offset(y: -54)

                Text(pages[index].subtitle)
                    .font(.system(size: 18, weight: .medium))
                    .fontDesign(.rounded)
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .offset(y: -56)
                    .id("subtitle-\(index)")
                    .transition(.opacity)

                Spacer()
                Spacer()



                ZStack {
                    if isLastPage {
                        RoleButton(
                            title: "I'm Ready!",
                            action: onStart
                        )
                        .frame(maxWidth: 220)
                        .transition(.scale(scale: 0.85).combined(with: .opacity))
                    }
                }
                .frame(height: 70)
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            OrientationManager.shared.lockLandscape()
            startAutoAdvance()
        }
        .onDisappear {
            autoAdvanceTask?.cancel()
        }
        .animation(.pageSwitch, value: index)
        .gesture(
            DragGesture(minimumDistance: 30)
                .onEnded { value in
                    if value.translation.width < -50 {
                        goNext()
                    } else if value.translation.width > 50 {
                        goPrev()
                    }
                }
        )
    }

    // MARK: - Auto-advance

    private func startAutoAdvance() {
        autoAdvanceTask?.cancel()
        autoAdvanceTask = Task {
            for step in 0..<(pages.count - 1) {
                try? await Task.sleep(for: .seconds(perPageSeconds))
                if Task.isCancelled { return }
                await MainActor.run {
                    // Only advance if user hasn't already moved past this step.
                    if index == step {
                        withAnimation(.pageSwitch) { index = step + 1 }
                    }
                }
            }
        }
    }

    // MARK: - Manual navigation (any manual move cancels auto-advance)

    private func backTapped() {
        if index > 0 { goPrev() } else { onBack() }
    }

    private func goNext() {
        guard index < pages.count - 1 else { return }
        autoAdvanceTask?.cancel()
        withAnimation(.pageSwitch) { index += 1 }
    }

    private func goPrev() {
        guard index > 0 else { return }
        autoAdvanceTask?.cancel()
        withAnimation(.pageSwitch) { index -= 1 }
    }
}

#Preview(traits: .landscapeRight) {
    TutorialCarouselScreen()
}
