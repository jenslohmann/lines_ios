import SwiftUI
import SpriteKit

/// SwiftUI wrapper hosting the SpriteKit game scene and score overlay.
struct GameView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        VStack(spacing: 0) {
            ScoreView(score: viewModel.score, nextColors: viewModel.nextColors)
                .padding(.vertical, 8)

            ZStack {
                GeometryReader { geometry in
                    SpriteView(scene: makeScene(size: CGSize(width: geometry.size.width,
                                                              height: geometry.size.height)))
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .ignoresSafeArea()
                }

                // Game over overlay
                if viewModel.isGameOver {
                    GameOverView(score: viewModel.score) {
                        viewModel.newGame()
                    }
                }
            }
        }
    }

    private func makeScene(size: CGSize) -> GameScene {
        let scene = GameScene(size: size)
        scene.scaleMode = .resizeFill
        scene.viewModel = viewModel
        return scene
    }
}

#Preview {
    let vm = GameViewModel()
    GameView(viewModel: vm)
        .onAppear { vm.newGame() }
}

