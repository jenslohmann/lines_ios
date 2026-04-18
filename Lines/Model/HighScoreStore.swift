import Foundation

/// A single high-score entry.
struct HighScoreEntry: Codable, Identifiable, Sendable {
    var id: UUID = UUID()
    let score: Int
    let date: Date
}

/// Manages the local top-10 high score list via UserDefaults.
struct HighScoreStore {
    private static let key = "highScores"
    private static let maxEntries = 10

    /// Loads the current high scores, sorted descending.
    static func load() -> [HighScoreEntry] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let entries = try? JSONDecoder().decode([HighScoreEntry].self, from: data)
        else { return [] }
        return entries.sorted { $0.score > $1.score }
    }

    /// Saves a new score if it qualifies for the top 10.
    /// - Returns: `true` if the score was added to the list.
    @discardableResult
    static func save(score: Int) -> Bool {
        var entries = load()
        if entries.count >= maxEntries, let lowest = entries.last, score <= lowest.score {
            return false
        }
        entries.append(HighScoreEntry(score: score, date: Date()))
        entries.sort { $0.score > $1.score }
        if entries.count > maxEntries {
            entries = Array(entries.prefix(maxEntries))
        }
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
        return true
    }

    /// Clears all high scores.
    static func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

