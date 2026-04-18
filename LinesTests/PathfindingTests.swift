import Testing
@testable import Lines

@Suite("Pathfinding Tests")
struct PathfindingTests {

    @Test("Direct horizontal path on empty board")
    func directHorizontalPath() {
        let from = Position(row: 0, col: 0)
        let to = Position(row: 0, col: 3)
        let path = findPath(from: from, to: to, occupied: [])
        #expect(path != nil)
        #expect(path!.first == from)
        #expect(path!.last == to)
    }

    @Test("Direct vertical path on empty board")
    func directVerticalPath() {
        let from = Position(row: 0, col: 0)
        let to = Position(row: 4, col: 0)
        let path = findPath(from: from, to: to, occupied: [])
        #expect(path != nil)
        #expect(path!.first == from)
        #expect(path!.last == to)
    }

    @Test("Path around an obstacle")
    func pathAroundObstacle() {
        let from = Position(row: 0, col: 0)
        let to = Position(row: 0, col: 2)
        let occupied: Set<Position> = [Position(row: 0, col: 1)]
        let path = findPath(from: from, to: to, occupied: occupied)
        #expect(path != nil)
        #expect(path!.first == from)
        #expect(path!.last == to)
        #expect(!path!.contains(Position(row: 0, col: 1)))
    }

    @Test("No path when fully blocked")
    func noPathWhenBlocked() {
        let from = Position(row: 0, col: 0)
        let to = Position(row: 2, col: 2)
        // Wall around (0,0)
        let occupied: Set<Position> = [
            Position(row: 0, col: 1),
            Position(row: 1, col: 0)
        ]
        let path = findPath(from: from, to: to, occupied: occupied)
        #expect(path == nil)
    }

    @Test("Path from position to itself")
    func samePosition() {
        let pos = Position(row: 4, col: 4)
        let path = findPath(from: pos, to: pos, occupied: [])
        #expect(path != nil)
        #expect(path! == [pos])
    }

    @Test("Path to occupied cell returns nil")
    func destinationOccupied() {
        let from = Position(row: 0, col: 0)
        let to = Position(row: 0, col: 1)
        let occupied: Set<Position> = [Position(row: 0, col: 1)]
        let path = findPath(from: from, to: to, occupied: occupied)
        #expect(path == nil)
    }

    @Test("Path is contiguous — each step is a neighbor of the previous")
    func pathIsContiguous() {
        let from = Position(row: 0, col: 0)
        let to = Position(row: 4, col: 4)
        let path = findPath(from: from, to: to, occupied: [])!
        for i in 1..<path.count {
            #expect(path[i - 1].neighbors.contains(path[i]))
        }
    }

    @Test("No diagonal moves in path")
    func noDiagonalMoves() {
        let from = Position(row: 0, col: 0)
        let to = Position(row: 3, col: 3)
        let path = findPath(from: from, to: to, occupied: [])!
        for i in 1..<path.count {
            let dr = abs(path[i].row - path[i - 1].row)
            let dc = abs(path[i].col - path[i - 1].col)
            #expect(dr + dc == 1)
        }
    }
}

