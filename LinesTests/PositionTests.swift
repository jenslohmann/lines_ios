import Testing
@testable import Lines

@Suite("Position Tests")
struct PositionTests {

    @Test("Position equality")
    func positionEquality() {
        let a = Position(row: 3, col: 4)
        let b = Position(row: 3, col: 4)
        #expect(a == b)
    }

    @Test("Position inequality")
    func positionInequality() {
        let a = Position(row: 0, col: 0)
        let b = Position(row: 0, col: 1)
        #expect(a != b)
    }

    @Test("Center cell has 4 neighbors")
    func centerNeighbors() {
        let pos = Position(row: 4, col: 4)
        let neighbors = pos.neighbors
        #expect(neighbors.count == 4)
        #expect(neighbors.contains(Position(row: 3, col: 4)))
        #expect(neighbors.contains(Position(row: 5, col: 4)))
        #expect(neighbors.contains(Position(row: 4, col: 3)))
        #expect(neighbors.contains(Position(row: 4, col: 5)))
    }

    @Test("Top-left corner has 2 neighbors")
    func topLeftCornerNeighbors() {
        let pos = Position(row: 0, col: 0)
        let neighbors = pos.neighbors
        #expect(neighbors.count == 2)
        #expect(neighbors.contains(Position(row: 1, col: 0)))
        #expect(neighbors.contains(Position(row: 0, col: 1)))
    }

    @Test("Bottom-right corner has 2 neighbors")
    func bottomRightCornerNeighbors() {
        let pos = Position(row: 8, col: 8)
        let neighbors = pos.neighbors
        #expect(neighbors.count == 2)
        #expect(neighbors.contains(Position(row: 7, col: 8)))
        #expect(neighbors.contains(Position(row: 8, col: 7)))
    }

    @Test("Edge cell has 3 neighbors")
    func edgeNeighbors() {
        let pos = Position(row: 0, col: 4)
        let neighbors = pos.neighbors
        #expect(neighbors.count == 3)
    }

    @Test("isValid for in-bounds positions")
    func isValidInBounds() {
        #expect(Position(row: 0, col: 0).isValid)
        #expect(Position(row: 8, col: 8).isValid)
        #expect(Position(row: 4, col: 4).isValid)
    }

    @Test("isValid for out-of-bounds positions")
    func isValidOutOfBounds() {
        #expect(!Position(row: -1, col: 0).isValid)
        #expect(!Position(row: 0, col: -1).isValid)
        #expect(!Position(row: 9, col: 0).isValid)
        #expect(!Position(row: 0, col: 9).isValid)
    }

    @Test("Neighbors do not include diagonals")
    func neighborsExcludeDiagonals() {
        let pos = Position(row: 4, col: 4)
        let neighbors = pos.neighbors
        #expect(!neighbors.contains(Position(row: 3, col: 3)))
        #expect(!neighbors.contains(Position(row: 3, col: 5)))
        #expect(!neighbors.contains(Position(row: 5, col: 3)))
        #expect(!neighbors.contains(Position(row: 5, col: 5)))
    }
}

