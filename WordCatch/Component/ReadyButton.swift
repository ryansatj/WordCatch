//
//  ReadyButton.swift
//  WordCatch
//

import SwiftUI

struct ReadyButton: View {
    let title: String
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { pressed = true }
            Task {
                try? await Task.sleep(for: .milliseconds(130))
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) { pressed = false }
                action()
            }
        }) {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .fontDesign(.rounded)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(Capsule().fill(Color("OrangeBrand")))
                .shadow(color: .black.opacity(pressed ? 0.08 : 0.22),
                        radius: pressed ? 2 : 7, y: pressed ? 1 : 3)
                .scaleEffect(pressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ReadyButton(title: "I'm Ready!", action: {})
        .frame(maxWidth: 220)
}
