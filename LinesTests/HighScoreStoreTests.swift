import Testing
import Foundation
@testable import Lines

@Suite("HighScoreStore Tests", .serialized)
struct HighScoreStoreTests {

    init() {
        HighScoreStore.clear()
    }

    @Test("Saving a score adds it to the list")
    func saveScore() {
        HighScoreStore.clear()
        let added = HighScoreStore.save(score: 100)
        #expect(added)
        let scores = HighScoreStore.load()
        #expect(scores.count == 1)
        #expect(scores.first?.score == 100)
    }

    @Test("Scores are sorted descending")
    func sortedDescending() {
        HighScoreStore.clear()
        HighScoreStore.save(score: 50)
        HighScoreStore.save(score: 200)
        HighScoreStore.save(score: 100)
        let scores = HighScoreStore.load()
        #expect(scores.map(\.score) == [200, 100, 50])
    }

    @Test("Only top 10 scores are kept")
    func maxTenEntries() {
        HighScoreStore.clear()
        for i in 1...12 {
            HighScoreStore.save(score: i * 10)
        }
        let scores = HighScoreStore.load()
        #expect(scores.count == 10)
        #expect(scores.first?.score == 120)
        #expect(scores.last?.score == 30)
    }

    @Test("Score below lowest top-10 is rejected")
    func rejectLowScore() {
        HighScoreStore.clear()
        for i in 1...10 {
            HighScoreStore.save(score: i * 100)
        }
        let added = HighScoreStore.save(score: 5)
        #expect(!added)
        #expect(HighScoreStore.load().count == 10)
    }

    @Test("Clear removes all scores")
    func clearScores() {
        HighScoreStore.clear()
        HighScoreStore.save(score: 42)
        HighScoreStore.clear()
        #expect(HighScoreStore.load().isEmpty)
    }
}
