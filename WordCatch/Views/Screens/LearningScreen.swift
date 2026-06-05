



//MARK: still neeed stuff masih vibeee



import SwiftUI

struct LearningScreen: View {
    let category: WordCategory
    let onPlayAgain: () -> Void
    let onBackHome: () -> Void


    @State private var contentHeight: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0

    private var maxScroll: CGFloat { max(contentHeight - viewportHeight, 0) }
    private var isScrollable: Bool { maxScroll > 1 }

    var body: some View {
        ZStack {
            CelebrationBackground()

            card
                .frame(maxWidth: 560, maxHeight: 320)
                .padding(.horizontal, 40)
                .overlay(alignment: .top) { categoryBadge.offset(y: -20) }
                .overlay(alignment: .top) { mascot.offset(y: -74) }
                .padding(.top, 60)
        }
    }

    // MARK: - Card

    private var card: some View {
        VStack(spacing: 0) {
            wordList
            buttonsRow
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
        }
        .background(RoundedRectangle(cornerRadius: 26).fill(.white))
        .overlay(
            RoundedRectangle(cornerRadius: 26)
                .strokeBorder(Color("OrangeBrand"), lineWidth: 4)
        )
        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
    }

    private var wordList: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 14) {
                ForEach(category.learningWords) { item in
                    wordRow(item)
                }
            }
            .padding(.leading, 44)
            .padding(.trailing, 30)   // room for the scroll bar
            .padding(.top, 30)        // clears the title pill
            .padding(.bottom, 12)
            // Track content height + live scroll offset.
            .background(
                GeometryReader { geo in
                    Color.clear
                        .preference(key: ContentHeightKey.self, value: geo.size.height)
                        .preference(key: ScrollOffsetKey.self,
                                    value: -geo.frame(in: .named("wordScroll")).minY)
                }
            )
        }
        .coordinateSpace(name: "wordScroll")
        .onPreferenceChange(ContentHeightKey.self) { contentHeight = $0 }
        .onPreferenceChange(ScrollOffsetKey.self) { scrollOffset = $0 }
        // Measure the visible scroll area.
        .background(
            GeometryReader { geo in
                Color.clear
                    .onAppear { viewportHeight = geo.size.height }
                    .onChange(of: geo.size) { _, s in viewportHeight = s.height }
            }
        )
        .overlay(alignment: .trailing) { scrollIndicator }
    }

    private func wordRow(_ item: WordMeaning) -> some View {
        HStack(spacing: 16) {
            Text(item.word.capitalized)
                .font(.system(size: 19, weight: .black, design: .rounded))
                .foregroundColor(Color("BrownBrand"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(item.meaning.capitalized)
                .font(.system(size: 19, weight: .black, design: .rounded))
                .foregroundColor(Color("OrangeBrand"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }

    // MARK: - Custom scroll indicator

    @ViewBuilder
    private var scrollIndicator: some View {
        if isScrollable {
            GeometryReader { geo in
                let trackHeight = geo.size.height
                let ratio = min(viewportHeight / max(contentHeight, 1), 1)
                let thumbHeight = max(trackHeight * ratio, 30)
                let progress = min(max(scrollOffset, 0), maxScroll) / maxScroll
                let thumbOffset = (trackHeight - thumbHeight) * progress

                ZStack(alignment: .top) {
                    // Faint groove so it reads as a scroll track even at the top.
                    Capsule()
                        .fill(Color("OrangeBrand").opacity(0.18))
                        .frame(width: 6)

                    Capsule()
                        .fill(Color("OrangeBrand"))
                        .frame(width: 6, height: thumbHeight)
                        .offset(y: thumbOffset)
                }
            }
            .frame(width: 6)
            .padding(.vertical, 12)
            .padding(.trailing, 10)
        }
    }

    // MARK: - Top decorations

    private var categoryBadge: some View {
        Text(category.name.uppercased())
            .font(.system(size: 18, weight: .black, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 26)
            .padding(.vertical, 9)
            .background(Capsule().fill(Color("OrangeBrand")))
            .overlay(Capsule().strokeBorder(.white.opacity(0.85), lineWidth: 2))
            .shadow(color: .black.opacity(0.18), radius: 3, y: 2)
    }

    private var mascot: some View {
        Image("SplashMascot")
            .resizable()
            .scaledToFit()
            .frame(width: 68, height: 68)
    }

    // MARK: - Buttons

    private var buttonsRow: some View {
        HStack(spacing: 16) {
            RoleButton(size: .md, variant: .secondary, action: onBackHome) {
                HStack(spacing: 8) {
                    Image(systemName: "house.fill")
                    Text("Back to Home")
                }
            }
            .frame(maxWidth: .infinity)

            RoleButton(size: .md, variant: .primary, action: onPlayAgain) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Scroll measurement keys

private struct ContentHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview(traits: .landscapeRight) {
    LearningScreen(category: .animals, onPlayAgain: {}, onBackHome: {})
}
