//  ScoreResultScreen.swift
//  WordCatch
//




import SwiftUI

public struct ScoreResultScreen: View {
    let mode: GameMode
    let winner: Int?
    let scoreP1: Int
    let scoreP2: Int
    let onContinue: () -> Void

    private var winnerTitle: String {
        if mode == .solo { return "YOUR SCORE" }
        if winner == 0 { return "PLAYER 1 WINS!" }
        if winner == 1 { return "PLAYER 2 WINS!" }
        return "DRAW!"
    }

    private var winnerLines: [String] {
        if mode == .solo { return ["YOUR SCORE"] }
        if winner == 0 { return ["PLAYER 1", "WINS!"] }
        if winner == 1 { return ["PLAYER 2", "WINS!"] }
        return ["DRAW!"]
    }
    
    

    public var body: some View {
        ZStack {
            CelebrationBackground()

            VStack(spacing: 16) {
                Group {
                    if mode == .solo {
                        soloScoreCard
                    } else {
                        duoScoreContent
                    }
                }
                .overlay(alignment: .top) {
                    Image("SplashMascot")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 96, height: 96)
                        .offset(y: -72)
                }
                .padding(.top, 38)

                RoleButton(title: "Continue", size: .md, action: onContinue)
                    .frame(width: 165)
                    .offset(y: 18)
            }
            .padding(.horizontal, 48)
            .padding(.vertical, 12)
        }
    }

    private var soloScoreCard: some View {
        VStack(spacing: 16) {
            Text("- \(winnerTitle) -")
                .font(.system(size: 38, weight: .black, design: .rounded))
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
        .offset(y: 8)
    }
    

    private var duoScoreContent: some View {
        VStack(spacing: 14) {
            VStack(spacing: 0) {
                ForEach(winnerLines, id: \.self) { line in
                    Text(line)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .foregroundColor(line == "WINS!" ? Color("OrangeBrand") : Color("BrownBrand"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .offset(y: 10)
            }
            .multilineTextAlignment(.center)

            HStack(spacing: 22) {
                scoreCard(title: "PLAYER 1 SCORED", score: scoreP1, highlighted: winner == 0)
                scoreCard(title: "PLAYER 2 SCORED", score: scoreP2, highlighted: winner == 1)
                  
            }
            .offset(y: 8)
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

#Preview("Duo", traits: .landscapeRight) {
    ScoreResultScreen(mode: .duo, winner: 0, scoreP1: 12, scoreP2: 0, onContinue: {})
}

#Preview("Solo", traits: .landscapeRight) {
    ScoreResultScreen(mode: .solo, winner: 0, scoreP1: 12, scoreP2: 0, onContinue: {})
}
