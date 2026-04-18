import Testing
import Foundation
@testable import Lines

@Suite("Ball and BallColor Tests")
struct BallTests {

    @Test("BallColor has exactly 7 cases")
    func ballColorCount() {
        #expect(BallColor.allCases.count == Constants.colorCount)
    }

    @Test("BallColor raw values are 0 through 6")
    func ballColorRawValues() {
        let rawValues = BallColor.allCases.map(\.rawValue)
        #expect(rawValues == [0, 1, 2, 3, 4, 5, 6])
    }

    @Test("BallColor.random returns a valid color")
    func ballColorRandom() {
        for _ in 0..<50 {
            let color = BallColor.random()
            #expect(BallColor.allCases.contains(color))
        }
    }

    @Test("Ball has correct properties")
    func ballProperties() {
        let pos = Position(row: 2, col: 3)
        let ball = Ball(color: .red, position: pos)
        #expect(ball.color == .red)
        #expect(ball.position == pos)
    }

    @Test("Each Ball gets a unique ID")
    func ballUniqueIds() {
        let pos = Position(row: 0, col: 0)
        let ball1 = Ball(color: .red, position: pos)
        let ball2 = Ball(color: .red, position: pos)
        #expect(ball1.id != ball2.id)
    }

    @Test("Ball equality is by ID, color, and position")
    func ballEquality() {
        let pos = Position(row: 1, col: 1)
        let id = UUID()
        let ball1 = Ball(id: id, color: .blue, position: pos)
        let ball2 = Ball(id: id, color: .blue, position: pos)
        #expect(ball1 == ball2)
    }
}

