//
//  PlayerSelectionScreen.swift
//  WordCatch
//
//  Created by Ryan Tjendana on 26/05/26.
//


import SwiftUI

struct PlayerSelectionScreen: View {
    var onBack: () -> Void = {}
    var onSelect: () -> Void = {}

    enum Mode { case solo, duo }
    @State private var selected: Mode? = .solo

    @State private var headerVisible = false
    @State private var card1Visible = false
    @State private var card2Visible = false
    @State private var ctaVisible = false

    var body: some View {
        ZStack {
            Image("bg2")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 40)

                VStack(spacing: 10) {
                    Text("Who's playing today?")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundColor(Color("BrownBrand"))
                    Text("Tap a mode below, then Continue")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.black.opacity(0.6))
                }
                .multilineTextAlignment(.center)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : -12)
                .padding(.bottom, 36)
                .padding(.horizontal, 20)

                VStack(spacing: 18,) {
                    modeCard(.solo,
                             
                             title: "Solo",
                             description: "Play by yourself",
                             image: "MascotFace")
                    .opacity(card1Visible ? 1 : 0)
                    .offset(y: card1Visible ? 0 : 20)

                    modeCard(.duo,
                             title: "Duo",
                             description: "Invite a partner",
                             image: "TwoFaceMascot")
                    .opacity(card2Visible ? 1 : 0)
                    .offset(y: card2Visible ? 0 : 20)
                    .frame(maxHeight: 160)
                }
                .padding(.horizontal, 80)

                Spacer()

                RoleButton(
                    title: "Continue",
                    size: .lg,
                    action: { if selected != nil { onSelect() } }
                )
                .frame(maxWidth: 280)
                .padding(.bottom, 40)
                .opacity(selected == nil ? 0.4 : 1.0)
                .opacity(ctaVisible ? 1 : 0)
                .allowsHitTesting(selected != nil)
                .animation(.easeInOut(duration: 0.2), value: selected)
            }
        }
        .task {
            withAnimation(.fadeInQuick) { headerVisible = true }
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.cardAppear) { card1Visible = true }
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.cardAppear) { card2Visible = true }
            try? await Task.sleep(for: .milliseconds(120))
            withAnimation(.fadeInQuick) { ctaVisible = true }
        }
        .onAppear { OrientationManager.shared.lockPortrait() }
    }

    // MARK: - Mode card

    private func modeCard(_ mode: Mode,
                          title: String,
                          description: String,
                          image: String) -> some View {
        let isSelected = selected == mode
        return Button {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
                selected = mode
            }
        } label: {
            HStack(spacing: 10) {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 110)
                    .padding(.leading, 4)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white : Color("BrownBrand"))
                    Text(description)
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(isSelected
                                         ? .white.opacity(0.95)
                                         : Color("BrownBrand").opacity(0.7))
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                radioIndicator(isSelected: isSelected)
                    .padding(.trailing, 18)
            }
            .padding(.vertical, 18)
            .padding(.leading, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isSelected ? Color("OrangeBrand") : Color.white)
            )
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(isSelected
                                      ? Color("OrangeBrand")
                                      : Color("BrownBrand"),
                                      lineWidth: 2)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.black.opacity(0.3), lineWidth: 2)
                    }
                }
            )
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color("OrangeBrand") : Color("BrownBrand"))
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.3))
                }
                .offset(y: 5)
            )
        }
        .buttonStyle(NoFadeButtonStyle())
    }

    private func radioIndicator(isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .strokeBorder(
                    isSelected ? Color.white : Color("BrownBrand").opacity(0.4),
                    lineWidth: 3
                )
                .frame(width: 38, height: 38)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    PlayerSelectionScreen()
}
