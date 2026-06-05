//  LearningScreen.swift
//  WordCatch
//  Dipisahkan dari GameOverlays.swift agar lebih modular
import SwiftUI


struct LearningScreen: View {
    let category: WordCategory
    let onPlayAgain: () -> Void
    let onBackHome: () -> Void
    let learnedWords: [WordMeaning]
    
    init(category: WordCategory, learnedWords: [WordMeaning], onPlayAgain: @escaping () -> Void, onBackHome: @escaping () -> Void) {
        self.category = category
        self.onPlayAgain = onPlayAgain
        self.onBackHome = onBackHome
        self.learnedWords = learnedWords
    }
    
    public var body: some View {
        GeometryReader { geo in
            
            ZStack {
                CelebrationBackground()
                
                VStack(spacing: 16) {
                    
                    // MARK: Header
                    VStack(spacing: -10) {
                        
                        Image("MascotFace")
                            .resizable()
                            .scaledToFit()
                            .frame(width: min(120, geo.size.height * 0.22))
                        
                        Text(category.name.uppercased())
                            .font(
                                .system(
                                    size: min(28, geo.size.height * 0.055),
                                    weight: .black,
                                    design: .rounded
                                )
                            )
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color("OrangeBrand"))
                            )
                    }
                    
                    // MARK: Empty State
                    if learnedWords.isEmpty {
                        
                        Text("No vocabulary appeared this round")
                            .font(.title3.bold())
                            .foregroundColor(Color("BrownBrand"))
                    }
                    
                    // MARK: Vocabulary List
                    ScrollView {
                        
                        LazyVStack(spacing: 12) {
                            
                            ForEach(learnedWords) { item in
                                
                                HStack(spacing: 24) {

                                    Text(item.word.capitalized)
                                        .frame(
                                            width: geo.size.width * 0.25,
                                            alignment: .trailing
                                        )
                                        .foregroundColor(Color("BrownBrand"))
                                        .frame(
                                            width: geo.size.width * 0.22,
                                            alignment: .trailing
                                        )

                                    Text(item.meaning.capitalized)
                                        .frame(
                                            width: geo.size.width * 0.35,
                                            alignment: .leading
                                        )
                                        .foregroundColor(Color("OrangeBrand"))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.horizontal, 12)
                            }
                        }
                        .padding(.vertical, 20)
                        .padding(.horizontal, 32)
                    }
                    .frame(
                        width: min(geo.size.width * 0.85, 720),
                        height: min(geo.size.height * 0.35, 220)
                    )
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color("OrangeBrand"), lineWidth: 3)
                    )
                    .shadow(radius: 6)
                    
                    // MARK: Buttons
                    HStack(
                        spacing: min(40, geo.size.width * 0.05)
                    ) {
                        
                        RoleButton(
                            size: .md,
                            variant: .secondary,
                            action: onBackHome
                        ) {
                            HStack {
                                Image(systemName: "house.fill")
                                Text("Back Home")
                            }
                        }
                        .frame(
                            width: min(180, geo.size.width * 0.25)
                        )
                        
                        RoleButton(
                            size: .md,
                            variant: .primary,
                            action: onPlayAgain
                        ) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Play Again")
                            }
                        }
                        .frame(
                            width: min(180, geo.size.width * 0.25)
                        )
                    }
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.horizontal, geo.size.width * 0.04)
            }
        }
    }
    
    #Preview(traits: .landscapeRight) {
        LearningScreen(
            category: .animals,
            learnedWords: WordCategory.animals.learningWords,
            onPlayAgain: {},
            onBackHome: {}
        )
    }
}
