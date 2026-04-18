/// Grid size, colors, counts, animation durations, and scoring constants.
/// Use `Constants.` to access values — this enum has no cases to prevent instantiation.
enum Constants {
    /// Number of rows and columns on the game board.
    static let gridSize = 9

    /// Number of distinct ball colors.
    static let colorCount = 7

    /// Number of balls spawned each turn.
    static let ballsPerTurn = 3

    /// Minimum number of same-colored balls in a line to score.
    static let minLineLength = 5

    /// Base score awarded for a line of exactly `minLineLength` balls.
    static let baseScore = 10

    /// Additional points per ball beyond `minLineLength`.
    static let extraBallScore = 10

    /// Duration (seconds) for a ball to slide one cell.
    static let moveStepDuration: Double = 0.08

    /// Duration (seconds) for a ball appear animation.
    static let appearDuration: Double = 0.2

    /// Duration (seconds) for a ball removal animation.
    static let removeDuration: Double = 0.3

    /// Duration (seconds) path markers stay visible before move starts.
    static let pathHighlightDuration: Double = 0.15
}

