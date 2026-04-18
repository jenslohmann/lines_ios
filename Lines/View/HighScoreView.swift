import SwiftUI

/// Displays the top-10 high score list.
struct HighScoreView: View {
    @State private var entries: [HighScoreEntry] = []

    var body: some View {
        List {
            if entries.isEmpty {
                Text("No high scores yet.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(entries.enumerated()), id: \.element.id) { index, entry in
                    HStack {
                        Text("#\(index + 1)")
                            .fontWeight(.bold)
                            .frame(width: 36, alignment: .leading)

                        Text("\(entry.score)")
                            .font(.title3)
                            .fontWeight(.semibold)

                        Spacer()

                        Text(entry.date, style: .date)
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }
                }
            }
        }
        .navigationTitle("High Scores")
        .onAppear {
            entries = HighScoreStore.load()
        }
    }
}

#Preview {
    NavigationStack {
        HighScoreView()
    }
}

