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

    /// The BFS path to display on the board and animate along.
    @Published var movePath: [Position]?

    /// Whether a move animation is currently playing (blocks input).
    @Published private(set) var isAnimating: Bool = false

    /// Callback invoked by the scene when move animation finishes.
    /// The ViewModel then finalizes the turn (line check, spawn, etc.).
    var onMoveAnimationComplete: (() -> Void)?

    // MARK: - Actions

    /// Starts a new game.
    func newGame() {
        model = GameModel()
        selectedBall = nil
        lastRemovedPositions = []
        movePath = nil
        isAnimating = false
        onMoveAnimationComplete = nil
        model.prepareNextColors()
        model.spawnBalls()
        model.prepareNextColors()
    }

    /// Handles a tap on a grid cell.
    func selectCell(_ position: Position) {
        guard !model.isGameOver, !isAnimating else { return }

        if let selected = selectedBall {
            if position == selected {
                selectedBall = nil
            } else if model.board[position] != nil {
                selectedBall = position
            } else {
                tryMove(from: selected, to: position)
            }
        } else {
            if model.board[position] != nil {
                selectedBall = position
            }
        }
    }

    /// Called by the scene after it finishes animating the move.
    func finalizeTurn() {
        let removed = model.findAndRemoveLines()
        lastRemovedPositions = removed

        if removed.isEmpty {
            model.spawnBalls()
            let spawnRemoved = model.findAndRemoveLines()
            if !spawnRemoved.isEmpty {
                lastRemovedPositions = spawnRemoved
            }
            model.prepareNextColors()

            if model.board.count == Constants.gridSize * Constants.gridSize {
                model.isGameOver = true
            }
        } else {
            model.prepareNextColors()
        }

        movePath = nil
        isAnimating = false
    }

    // MARK: - Private

    private func tryMove(from: Position, to: Position) {
        let occupied = Set(model.board.keys).subtracting([from])
        guard let path = findPath(from: from, to: to, occupied: occupied) else { return }

        // Publish path for the scene to display and animate
        selectedBall = nil
        isAnimating = true
        movePath = path

        // Move the ball in the model immediately (so board state is correct)
        model.moveBall(from: from, to: to)

        // The scene will observe `movePath`, animate, then call `finalizeTurn()`
    }
}
