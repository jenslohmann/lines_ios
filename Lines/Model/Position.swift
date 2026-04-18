/// A row/column coordinate on the game board.
struct Position: Hashable, Sendable {
    /// Row index (0-based, top to bottom).
    let row: Int
    /// Column index (0-based, left to right).
    let col: Int

    /// Returns the four orthogonal neighbors (up, down, left, right),
    /// filtered to positions within the grid bounds.
    var neighbors: [Position] {
        let offsets = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        return offsets.compactMap { dr, dc in
            let r = row + dr
            let c = col + dc
            guard r >= 0, r < Constants.gridSize,
                  c >= 0, c < Constants.gridSize else { return nil }
            return Position(row: r, col: c)
        }
    }

    /// Whether this position is within the grid bounds.
    var isValid: Bool {
        row >= 0 && row < Constants.gridSize &&
        col >= 0 && col < Constants.gridSize
    }
}

