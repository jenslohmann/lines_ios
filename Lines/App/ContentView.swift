import SwiftUI

/// Root view — main menu with navigation to game and other screens.
struct ContentView: View {
    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Text("Lines")
                    .font(.system(size: 48, weight: .bold, design: .rounded))

                Spacer()

                NavigationLink("New Game") {
                    GameView(viewModel: viewModel)
                        .navigationTitle("Lines")
                        .onAppear { viewModel.newGame() }
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
        }
    }
}

#Preview {
    ContentView()
}
