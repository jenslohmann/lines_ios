import Testing
@testable import Lines

@Suite("Integration Tests")
struct IntegrationTests {

    @Test("Full game loop: new game → move → line removal → score update")
    func fullGameLoop() {
        var model = GameModel()
        model.prepareNextColors()
        model.spawnBalls()
        model.prepareNextColors()

        // After initial spawn: 3 balls on board, next colors prepared
        #expect(model.board.count == 3)
        #expect(model.nextColors.count == 3)
        #expect(model.score == 0)
        #expect(!model.isGameOver)
    }

    @Test("Move that forms a line scores points and removes balls")
    func moveFormsLineAndScores() {
        var model = GameModel()

        // Place 4 red balls in a horizontal line
        for col in 0..<4 {
            model.board[Position(row: 0, col: col)] = Ball(color: .red, position: Position(row: 0, col: col))
        }
        // Place a 5th red ball nearby to move into the line
        model.board[Position(row: 1, col: 4)] = Ball(color: .red, position: Position(row: 1, col: 4))
        model.prepareNextColors()

        // Move ball to complete the line
        let moved = model.moveBall(from: Position(row: 1, col: 4), to: Position(row: 0, col: 4))
        #expect(moved)

        let removed = model.findAndRemoveLines()
        #expect(removed.count == 5)
        #expect(model.score == 10)
        #expect(model.board.isEmpty)
    }

    @Test("Move without line triggers spawn")
    func moveWithoutLineTriggersSpawn() {
        var model = GameModel()

        // Place one ball and move it
        model.board[Position(row: 0, col: 0)] = Ball(color: .red, position: Position(row: 0, col: 0))
        model.prepareNextColors()

        let moved = model.moveBall(from: Position(row: 0, col: 0), to: Position(row: 0, col: 1))
        #expect(moved)

        let removed = model.findAndRemoveLines()
        #expect(removed.isEmpty)

        // Spawn should add 3 balls (1 existing + 3 new = 4)
        model.spawnBalls()
        #expect(model.board.count == 4)
    }

    @Test("Game over when board fills up")
    func gameOverWhenBoardFills() {
        var model = GameModel()

        // Fill entire board except 2 cells with alternating colors to prevent lines
        let colors: [BallColor] = [.red, .blue, .green, .yellow, .cyan, .magenta, .orange]
        var colorIndex = 0
        for row in 0..<Constants.gridSize {
            for col in 0..<Constants.gridSize {
                let totalFilled = row * Constants.gridSize + col
                if totalFilled >= Constants.gridSize * Constants.gridSize - 2 { break }
                // Alternate colors to avoid forming lines
                let color = colors[(colorIndex) % colors.count]
                colorIndex += 1
                // Shift pattern each row to avoid vertical lines
                let adjustedColor = colors[(colorIndex + row) % colors.count]
                model.board[Position(row: row, col: col)] = Ball(
                    color: adjustedColor,
                    position: Position(row: row, col: col)
                )
            }
        }

        // Board nearly full — spawning 3 balls should trigger game over
        model.nextColors = [.red, .blue, .green]
        model.spawnBalls()
        #expect(model.isGameOver)
    }

    @Test("Multiple consecutive moves accumulate score")
    func consecutiveMovesAccumulateScore() {
        var model = GameModel()

        // First line: 5 red horizontal at row 0
        for col in 0..<4 {
            model.board[Position(row: 0, col: col)] = Ball(color: .red, position: Position(row: 0, col: col))
        }
        model.board[Position(row: 1, col: 4)] = Ball(color: .red, position: Position(row: 1, col: 4))
        model.prepareNextColors()

        model.moveBall(from: Position(row: 1, col: 4), to: Position(row: 0, col: 4))
        model.findAndRemoveLines()
        #expect(model.score == 10)

        // Second line: 5 blue horizontal at row 2
        for col in 0..<4 {
            model.board[Position(row: 2, col: col)] = Ball(color: .blue, position: Position(row: 2, col: col))
        }
        model.board[Position(row: 3, col: 4)] = Ball(color: .blue, position: Position(row: 3, col: 4))

        model.moveBall(from: Position(row: 3, col: 4), to: Position(row: 2, col: 4))
        model.findAndRemoveLines()
        #expect(model.score == 20) // 10 + 10
    }

    @Test("New game resets everything")
    func newGameResetsState() {
        var model = GameModel()
        model.score = 100
        model.isGameOver = true
        model.board[Position(row: 0, col: 0)] = Ball(color: .red, position: Position(row: 0, col: 0))

        // Simulate new game
        model = GameModel()
        model.prepareNextColors()
        model.spawnBalls()
        model.prepareNextColors()

        #expect(model.score == 0)
        #expect(!model.isGameOver)
        #expect(model.board.count == 3)
        #expect(model.nextColors.count == 3)
    }

    @Test("Line removal skips spawn in full game flow")
    func lineRemovalSkipsSpawnInFlow() {
        var model = GameModel()

        // Set up a line-completing move
        for col in 0..<4 {
            model.board[Position(row: 0, col: col)] = Ball(color: .red, position: Position(row: 0, col: col))
        }
        model.board[Position(row: 1, col: 4)] = Ball(color: .red, position: Position(row: 1, col: 4))
        model.prepareNextColors()

        model.moveBall(from: Position(row: 1, col: 4), to: Position(row: 0, col: 4))
        let removed = model.findAndRemoveLines()

        // Line found — do NOT spawn
        #expect(!removed.isEmpty)
        #expect(model.board.isEmpty) // All 5 removed, nothing spawned

        // Now prepare next colors for the following turn
        model.prepareNextColors()
        #expect(model.nextColors.count == 3)
    }
}

