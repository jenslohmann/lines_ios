import SwiftUI

/// ObservableObject bridging GameModel ↔ SwiftUI views.
@MainActor
final class GameViewModel: ObservableObject {
    /// The underlying game model.
    @Published private(set) var model = GameModel()

    /// The position of the currently selected ball, if any.
    @Published var selectedBall: Position?

    /// Current score.
    var score: Int { model.score }

    /// Whether the game is over.
    var isGameOver: Bool { model.isGameOver }

    /// The balls on the board.
    var board: [Position: Ball] { model.board }

    /// The colors of the next balls to appear.
    var nextColors: [BallColor] { model.nextColors }

    /// Positions that were removed in the last move (for animation).
    @Published var lastRemovedPositions: [Position] = []

    /// Path of the last move (for animation).
    @Published var lastMovePath: [Position]?

    // MARK: - Actions

    /// Starts a new game.
    func newGame() {
        model = GameModel()
        selectedBall = nil
        lastRemovedPositions = []
        lastMovePath = nil
        model.prepareNextColors()
        model.spawnBalls()
        model.prepareNextColors()
    }

    /// Handles a tap on a grid cell.
    /// - If no ball is selected and the cell has a ball, select it.
    /// - If a ball is selected and the cell is empty, try to move.
    /// - If a ball is selected and another ball is tapped, switch selection.
    func selectCell(_ position: Position) {
        guard !model.isGameOver else { return }

        if let selected = selectedBall {
            if position == selected {
                // Deselect
                selectedBall = nil
            } else if model.board[position] != nil {
                // Switch selection to another ball
                selectedBall = position
            } else {
                // Try to move
                tryMove(from: selected, to: position)
            }
        } else {
            // Select a ball
            if model.board[position] != nil {
                selectedBall = position
            }
        }
    }

    // MARK: - Private

    private func tryMove(from: Position, to: Position) {
        let occupied = Set(model.board.keys).subtracting([from])
        let path = findPath(from: from, to: to, occupied: occupied)

        guard model.moveBall(from: from, to: to) else { return }

        selectedBall = nil
        lastMovePath = path

        let removed = model.findAndRemoveLines()
        lastRemovedPositions = removed

        if removed.isEmpty {
            // No line formed — spawn new balls
            model.spawnBalls()
            // Check if spawned balls form lines
            let spawnRemoved = model.findAndRemoveLines()
            if !spawnRemoved.isEmpty {
                lastRemovedPositions = spawnRemoved
            }
            // Prepare next colors for the following turn
            model.prepareNextColors()

            // Check game over after spawn
            if model.board.count == Constants.gridSize * Constants.gridSize {
                model.isGameOver = true
            }
        } else {
            // Line was formed — prepare next colors but don't spawn
            model.prepareNextColors()
        }
    }
}

