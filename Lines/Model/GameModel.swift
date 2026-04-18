import Foundation

/// Core game logic for Lines. Pure value type — no UI imports.
struct GameModel: Sendable {
    /// The balls currently on the board, keyed by position.
    var board: [Position: Ball] = [:]

    /// The colors of the next 3 balls to be spawned.
    var nextColors: [BallColor] = []

    /// Current score.
    var score: Int = 0

    /// Whether the game is over (board full, can't spawn).
    var isGameOver: Bool = false

    // MARK: - Scoring

    /// Calculates the score for removing a given number of balls.
    /// 10 points for 5, +10 for each additional ball.
    static func score(forRemovedCount count: Int) -> Int {
        guard count >= Constants.minLineLength else { return 0 }
        let extra = count - Constants.minLineLength
        return Constants.baseScore + extra * Constants.extraBallScore
    }

    // MARK: - Next Colors

    /// Prepares the next set of random colors to be spawned.
    mutating func prepareNextColors() {
        nextColors = (0..<Constants.ballsPerTurn).map { _ in BallColor.random() }
    }

    // MARK: - Spawning

    /// Spawns balls using `nextColors` on random empty cells.
    /// Sets `isGameOver` if there aren't enough empty cells.
    mutating func spawnBalls() {
        let emptyPositions = allPositions.filter { board[$0] == nil }

        if emptyPositions.count < nextColors.count {
            // Place as many as we can, then game over
            for (i, pos) in emptyPositions.enumerated() where i < nextColors.count {
                board[pos] = Ball(color: nextColors[i], position: pos)
            }
            isGameOver = true
            return
        }

        var available = emptyPositions
        for color in nextColors {
            let index = Int.random(in: 0..<available.count)
            let pos = available.remove(at: index)
            board[pos] = Ball(color: color, position: pos)
        }
    }

    // MARK: - Movement

    /// Attempts to move a ball from one position to another.
    /// - Returns: `true` if the move succeeded, `false` if no ball at source or no path.
    @discardableResult
    mutating func moveBall(from: Position, to: Position) -> Bool {
        guard var ball = board[from] else { return false }

        let occupied = Set(board.keys).subtracting([from])
        guard findPath(from: from, to: to, occupied: occupied) != nil else { return false }

        board.removeValue(forKey: from)
        ball.position = to
        board[to] = ball
        return true
    }

    // MARK: - Line Detection & Removal

    /// The eight directions to scan for lines: horizontal, vertical, and both diagonals.
    private static let lineDirections: [(dr: Int, dc: Int)] = [
        (0, 1),   // horizontal
        (1, 0),   // vertical
        (1, 1),   // diagonal down-right
        (1, -1)   // diagonal down-left
    ]

    /// Finds and removes all lines of 5+ same-colored balls.
    /// Updates the score accordingly.
    /// - Returns: The positions that were removed.
    @discardableResult
    mutating func findAndRemoveLines() -> [Position] {
        var toRemove: Set<Position> = []

        for direction in Self.lineDirections {
            let positions = scanForLines(dr: direction.dr, dc: direction.dc)
            toRemove.formUnion(positions)
        }

        if !toRemove.isEmpty {
            score += Self.score(forRemovedCount: toRemove.count)
            for pos in toRemove {
                board.removeValue(forKey: pos)
            }
        }

        return Array(toRemove)
    }

    /// Scans in one direction pair for lines of 5+.
    private func scanForLines(dr: Int, dc: Int) -> Set<Position> {
        var result: Set<Position> = []
        var visited: Set<Position> = []

        for row in 0..<Constants.gridSize {
            for col in 0..<Constants.gridSize {
                let start = Position(row: row, col: col)
                guard !visited.contains(start),
                      let ball = board[start] else { continue }

                // Walk forward in this direction
                var line: [Position] = [start]
                var r = row + dr
                var c = col + dc
                while r >= 0, r < Constants.gridSize,
                      c >= 0, c < Constants.gridSize {
                    let pos = Position(row: r, col: c)
                    guard let other = board[pos], other.color == ball.color else { break }
                    line.append(pos)
                    r += dr
                    c += dc
                }

                for pos in line { visited.insert(pos) }

                if line.count >= Constants.minLineLength {
                    for pos in line { result.insert(pos) }
                }
            }
        }

        return result
    }

    // MARK: - Helpers

    /// All positions on the board.
    private var allPositions: [Position] {
        (0..<Constants.gridSize).flatMap { row in
            (0..<Constants.gridSize).map { col in Position(row: row, col: col) }
        }
    }
}

