//
//  PagingDots.swift
//  WordCatch
//

import SwiftUI

struct PagingDots: View {
    let count: Int
    let index: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<count, id: \.self) { i in
                Capsule()
                    .fill(i == index ? Color("OrangeBrand") : Color.black.opacity(0.18))
                    .frame(width: i == index ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: index)
            }
        }
    }
}

#Preview {
    PagingDots(count: 3, index: 1)
}
