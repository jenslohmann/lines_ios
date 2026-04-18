import SwiftUI

/// Game-over overlay showing the final score and a restart button.
struct GameOverView: View {
    let score: Int
    let onNewGame: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Final Score: \(score)")
                .font(.title2)

            Button(action: onNewGame) {
                Text("New Game")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(40)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    GameOverView(score: 150) { }
}

