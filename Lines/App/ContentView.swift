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
                    HighScoreView()
                }
                .font(.title2)

                NavigationLink("How to Play") {
                    HowToPlayView()
                }
                .font(.title2)

                NavigationLink("Settings") {
                    SettingsView()
                }
                .font(.title2)

                NavigationLink("About") {
                    AboutView()
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
