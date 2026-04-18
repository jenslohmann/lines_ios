import SwiftUI

/// How-to-play instructions for new players.
struct HowToPlayView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                section(
                    icon: "🎯",
                    title: "Goal",
                    text: "Score as many points as possible by forming lines of 5 or more same-colored balls."
                )

                section(
                    icon: "🟢",
                    title: "Board",
                    text: "The game is played on a 9×9 grid. Each turn, 3 new balls of random colors appear."
                )

                section(
                    icon: "👆",
                    title: "Moving",
                    text: "Tap a ball to select it, then tap an empty cell to move it there. The ball can only move if a clear path exists (no jumping over other balls)."
                )

                section(
                    icon: "✨",
                    title: "Scoring",
                    text: "When 5 or more balls of the same color form a horizontal, vertical, or diagonal line, they are removed and you earn points: 10 for 5 balls, plus 10 for each additional ball."
                )

                section(
                    icon: "🔮",
                    title: "Next Balls",
                    text: "The 3 colors shown at the top tell you what colors will appear next. Plan your moves accordingly!"
                )

                section(
                    icon: "⛔",
                    title: "Game Over",
                    text: "The game ends when the board is completely full and no more balls can be placed."
                )

                section(
                    icon: "💡",
                    title: "Tip",
                    text: "When you clear a line, the 3 new balls don't appear that turn — use this to chain moves strategically!"
                )
            }
            .padding()
        }
        .navigationTitle("How to Play")
    }

    private func section(icon: String, title: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(icon)
                .font(.title)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(text)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        HowToPlayView()
    }
}

