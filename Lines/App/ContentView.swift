import SwiftUI

/// Root view — main menu with navigation to game and other screens.
struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()
    @State private var isPlaying = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Lines")
                    .font(.system(size: 48, weight: .bold, design: .rounded))

                Spacer()

                Button("New Game") {
                    viewModel.newGame()
                    isPlaying = true
                }
                .font(.title2)

                NavigationLink("High Scores") {
                    Text("High Scores — coming soon")
                        .navigationTitle("High Scores")
                }
                .font(.title2)

                NavigationLink("How to Play") {
                    Text("How to Play — coming soon")
                        .navigationTitle("How to Play")
                }
                .font(.title2)

                NavigationLink("Settings") {
                    Text("Settings — coming soon")
                        .navigationTitle("Settings")
                }
                .font(.title2)

                NavigationLink("About") {
                    Text("About — coming soon")
                        .navigationTitle("About")
                }
                .font(.title2)

                Spacer()
            }
            .sheet(isPresented: $isPlaying) {
                NavigationStack {
                    GameView(viewModel: viewModel)
                        .navigationTitle("Lines")
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Menu") {
                                    isPlaying = false
                                }
                            }
                        }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
