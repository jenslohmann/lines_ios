import Testing
@testable import Lines

@Suite("GameModel Tests")
struct GameModelTests {

    // MARK: - Scoring

    @Test("Score for exactly 5 balls is 10")
    func scoreForFive() {
        #expect(GameModel.score(forRemovedCount: 5) == 10)
    }

    @Test("Score for 6 balls is 20")
    func scoreForSix() {
        #expect(GameModel.score(forRemovedCount: 6) == 20)
    }

    @Test("Score for 7 balls is 30")
    func scoreForSeven() {
        #expect(GameModel.score(forRemovedCount: 7) == 30)
    }

    @Test("Score for 9 balls is 50")
    func scoreForNine() {
        #expect(GameModel.score(forRemovedCount: 9) == 50)
    }

    // MARK: - Line Detection

    @Test("Detects horizontal line of 5")
    func horizontalLineOfFive() {
        var model = GameModel()
        for col in 0..<5 {
            let ball = Ball(color: .red, position: Position(row: 0, col: col))
            model.board[ball.position] = ball
        }
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 5)
    }

    @Test("Detects vertical line of 5")
    func verticalLineOfFive() {
        var model = GameModel()
        for row in 0..<5 {
            let ball = Ball(color: .blue, position: Position(row: row, col: 0))
            model.board[ball.position] = ball
        }
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 5)
    }

    @Test("Detects diagonal line of 5 (top-left to bottom-right)")
    func diagonalLineDown() {
        var model = GameModel()
        for i in 0..<5 {
            let ball = Ball(color: .green, position: Position(row: i, col: i))
            model.board[ball.position] = ball
        }
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 5)
    }

    @Test("Detects diagonal line of 5 (bottom-left to top-right)")
    func diagonalLineUp() {
        var model = GameModel()
        for i in 0..<5 {
            let ball = Ball(color: .yellow, position: Position(row: 4 - i, col: i))
            model.board[ball.position] = ball
        }
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 5)
    }

    @Test("4 in a row does NOT count")
    func fourInARow() {
        var model = GameModel()
        for col in 0..<4 {
            let ball = Ball(color: .red, position: Position(row: 0, col: col))
            model.board[ball.position] = ball
        }
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 0)
    }

    @Test("Line of 7 removes all 7")
    func lineOfSeven() {
        var model = GameModel()
        for col in 0..<7 {
            let ball = Ball(color: .cyan, position: Position(row: 3, col: col))
            model.board[ball.position] = ball
        }
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 7)
    }

    @Test("Mixed colors do not form a line")
    func mixedColors() {
        var model = GameModel()
        let colors: [BallColor] = [.red, .red, .red, .blue, .red]
        for (col, color) in colors.enumerated() {
            let ball = Ball(color: color, position: Position(row: 0, col: col))
            model.board[ball.position] = ball
        }
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 0)
    }

    @Test("Removed balls are cleared from the board")
    func removedBallsClearedFromBoard() {
        var model = GameModel()
        for col in 0..<5 {
            let ball = Ball(color: .red, position: Position(row: 0, col: col))
            model.board[ball.position] = ball
        }
        _ = model.findAndRemoveLines()
        for col in 0..<5 {
            #expect(model.board[Position(row: 0, col: col)] == nil)
        }
    }

    // MARK: - Spawning

    @Test("spawnBalls places 3 balls on empty board")
    func spawnThreeBalls() {
        var model = GameModel()
        model.prepareNextColors()
        model.spawnBalls()
        #expect(model.board.count == 3)
    }

    @Test("spawnBalls uses nextColors")
    func spawnUsesNextColors() {
        var model = GameModel()
        model.prepareNextColors()
        let expectedColors = model.nextColors
        model.spawnBalls()
        let placedColors = model.board.values.map(\.color)
        for color in expectedColors {
            #expect(placedColors.contains(color))
        }
    }

    @Test("Game over when board is full and spawn fails")
    func gameOverWhenFull() {
        var model = GameModel()
        // Fill all cells
        for row in 0..<Constants.gridSize {
            for col in 0..<Constants.gridSize {
                let ball = Ball(color: .red, position: Position(row: row, col: col))
                model.board[ball.position] = ball
            }
        }
        model.prepareNextColors()
        model.spawnBalls()
        #expect(model.isGameOver)
    }

    // MARK: - Move

    @Test("moveBall moves ball to new position")
    func moveBallBasic() {
        var model = GameModel()
        let from = Position(row: 0, col: 0)
        let to = Position(row: 0, col: 3)
        let ball = Ball(color: .red, position: from)
        model.board[from] = ball
        let success = model.moveBall(from: from, to: to)
        #expect(success)
        #expect(model.board[from] == nil)
        #expect(model.board[to] != nil)
        #expect(model.board[to]?.color == .red)
    }

    @Test("moveBall fails if no path exists")
    func moveBallNoPath() {
        var model = GameModel()
        let from = Position(row: 0, col: 0)
        let to = Position(row: 2, col: 2)
        let ball = Ball(color: .red, position: from)
        model.board[from] = ball
        // Block all exits
        model.board[Position(row: 0, col: 1)] = Ball(color: .blue, position: Position(row: 0, col: 1))
        model.board[Position(row: 1, col: 0)] = Ball(color: .blue, position: Position(row: 1, col: 0))
        let success = model.moveBall(from: from, to: to)
        #expect(!success)
        #expect(model.board[from] != nil)
    }

    @Test("moveBall fails if source is empty")
    func moveBallEmptySource() {
        var model = GameModel()
        let success = model.moveBall(from: Position(row: 0, col: 0), to: Position(row: 0, col: 1))
        #expect(!success)
    }

    // MARK: - Line removal skips spawn

    @Test("After a move that forms a line, no new balls spawn")
    func lineRemovalSkipsSpawn() {
        var model = GameModel()
        // Place 4 red balls in a row, move a 5th to complete the line
        for col in 0..<4 {
            model.board[Position(row: 0, col: col)] = Ball(color: .red, position: Position(row: 0, col: col))
        }
        let movingBall = Ball(color: .red, position: Position(row: 1, col: 4))
        model.board[movingBall.position] = movingBall
        model.prepareNextColors()

        let boardCountBefore = model.board.count // 5

        // Move ball to complete the line
        _ = model.moveBall(from: Position(row: 1, col: 4), to: Position(row: 0, col: 4))
        let removed = model.findAndRemoveLines()

        #expect(removed.count == 5)
        // Board should be empty (5 placed - 5 removed = 0), no spawn happened
        #expect(model.board.count == 0)
    }

    // MARK: - Two intersecting lines

    @Test("Intersecting lines remove all unique balls")
    func intersectingLines() {
        var model = GameModel()
        // Horizontal line at row 4
        for col in 0..<5 {
            model.board[Position(row: 4, col: col)] = Ball(color: .red, position: Position(row: 4, col: col))
        }
        // Vertical line at col 2 (overlaps at (4,2))
        for row in 0..<5 {
            if row != 4 { // skip overlap
                model.board[Position(row: row, col: 2)] = Ball(color: .red, position: Position(row: row, col: 2))
            }
        }
        // Total: 5 + 4 = 9 balls, but (4,2) shared → 9 unique positions
        let removed = model.findAndRemoveLines()
        #expect(removed.count == 9)
    }
}

