import SwiftUI

/// SwiftUI wrapper hosting the game board and score.
/// Placeholder grid until SpriteKit scene is added in Phase 4.
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScoreView(score: viewModel.score, nextColors: viewModel.nextColors)
                .padding(.vertical, 8)

            GeometryReader { geometry in
                let size = min(geometry.size.width, geometry.size.height)
                let cellSize = size / CGFloat(Constants.gridSize)

                ZStack {
                    // Grid
                    gridView(cellSize: cellSize)

                    // Game over overlay
                    if viewModel.isGameOver {
                        GameOverView(score: viewModel.score) {
                            viewModel.newGame()
                        }
                    }
                }
                .frame(width: size, height: size)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func gridView(cellSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<Constants.gridSize, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<Constants.gridSize, id: \.self) { col in
                        let pos = Position(row: row, col: col)
                        cellView(at: pos, size: cellSize)
                    }
                }
            }
        }
    }

    private func cellView(at position: Position, size: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color(white: 0.9))
                .border(Color(white: 0.7), width: 0.5)

            if let ball = viewModel.board[position] {
                Circle()
                    .fill(ball.color.swiftUIColor)
                    .padding(size * 0.1)
                    .scaleEffect(viewModel.selectedBall == position ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3).repeatForever(autoreverses: true),
                               value: viewModel.selectedBall == position)
            }
        }
        .frame(width: size, height: size)
        .onTapGesture {
            viewModel.selectCell(position)
        }
    }
}

#Preview {
    let vm = GameViewModel()
    GameView(viewModel: vm)
        .onAppear { vm.newGame() }
}

