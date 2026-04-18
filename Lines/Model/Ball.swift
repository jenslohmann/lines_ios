import Foundation

/// The possible colors for a ball on the game board.
enum BallColor: Int, CaseIterable, Sendable {
    case red = 0
    case green
    case blue
    case yellow
    case cyan
    case magenta
    case orange

    /// Returns a random ball color.
    static func random() -> BallColor {
        allCases.randomElement()!
    }
}

/// A ball on the game board, identified by a unique ID.
struct Ball: Identifiable, Equatable, Sendable {
    /// Unique identifier for this ball.
    let id: UUID
    /// The color of this ball.
    let color: BallColor
    /// Current position on the board.
    var position: Position

    /// Creates a new ball with a random UUID.
    init(color: BallColor, position: Position) {
        self.id = UUID()
        self.color = color
        self.position = position
    }

    /// Creates a ball with a specific ID (useful for testing).
    init(id: UUID, color: BallColor, position: Position) {
        self.id = id
        self.color = color
        self.position = position
    }
}

