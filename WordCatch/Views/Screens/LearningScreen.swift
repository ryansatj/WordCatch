//  LearningScreen.swift
//  WordCatch
//  Dipisahkan dari GameOverlays.swift agar lebih modular
import SwiftUI

 struct LearningScreen: View {
    let category: WordCategory
    let onPlayAgain: () -> Void
    let onBackHome: () -> Void

    init(category: WordCategory, onPlayAgain: @escaping () -> Void, onBackHome: @escaping () -> Void) {
        self.category = category
        self.onPlayAgain = onPlayAgain
        self.onBackHome = onBackHome
    }

    public var body: some View {
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
