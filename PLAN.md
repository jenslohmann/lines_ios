# Lines — Implementation Plan

## Phase 1 — Project Scaffold & Constants
1. Create Xcode project (iOS App, SwiftUI lifecycle, iOS 17+, universal iPhone/iPad).
2. **Constants.swift** — `enum Constants` (no cases) with grid size (9), color count (7), balls per turn (3), min line length (5), scoring values, animation durations.
3. **Position.swift** — `struct Position: Hashable, Sendable` with `row`, `col` and neighbor helpers.
4. **Ball.swift** — `struct Ball: Identifiable, Sendable` with `id: UUID`, `color: BallColor` enum (7 cases), `position: Position`.
5. Add `LinesTests` target; write tests for `Position` neighbors and `BallColor` raw values.

## Phase 2 — Game Model & Pathfinding
1. **Pathfinding.swift** — BFS function `findPath(from:to:occupied:) -> [Position]?`, horizontal/vertical movement only.
2. **GameModel.swift** — `struct GameModel` with board state (`[Position: Ball]`), `nextColors: [BallColor]`, `score: Int`, `isGameOver: Bool`. Methods: `spawnBalls()`, `moveBall(from:to:)`, `checkLines() -> [Ball]`, `calculateScore(removed:) -> Int`. Line removal skips the next spawn.
3. Unit tests for: pathfinding (open path, blocked path, no path), line detection (horizontal, vertical, diagonal, exactly 5, 7+), scoring (10 for 5, +10 per extra), spawn failure triggering game over.

## Phase 3 — ViewModel & SwiftUI Shell
1. **GameViewModel.swift** — `@MainActor ObservableObject` owning `GameModel`. Published properties: board, score, nextColors, isGameOver, selectedBall. Methods: `selectCell(_:)` (tap-to-select then tap-to-move), `newGame()`.
2. **ContentView.swift** — root navigation with menu: New Game, High Scores, Settings, About.
3. **GameView.swift** + **ScoreView.swift** — hosts `SpriteView` for the game scene, shows current score and next-3-colors preview.
4. **GameOverView.swift** — overlay with final score and New Game button.
5. **LinesApp.swift** — inject `GameViewModel` as `@StateObject`.

## Phase 4 — SpriteKit Scene & Interaction
1. **BallNode.swift** — `SKShapeNode` subclass drawing a colored circle with gradient fill, idle bounce animation, and pop/remove animation.
2. **GameScene.swift** — draw 9×9 grid, observe `GameViewModel` to sync ball nodes. Handle `touchesBegan` to convert tap → grid `Position` → call into view model.
3. Animations: ball slides step-by-step along BFS path, scale-in on appear, scale-out + fade on removal.
4. Selected-ball highlight (pulsing glow/bounce) when `viewModel.selectedBall` is set.

## Phase 5 — Persistence, Settings & Localization
1. High-score persistence via `UserDefaults` + `Codable` (top 10 entries with score and date). **HighScoreView.swift** displaying the list.
2. **SettingsView.swift** — sound on/off toggle via `@AppStorage`. **AboutView.swift** — version and credits.
3. **Localizable.xcstrings** — String Catalog with all UI strings in da, en, fr, ja. Replace hardcoded strings with `String(localized:)`.
4. App icon and ball color assets in `Assets.xcassets`.

## Phase 6 — Polish & Final Testing
1. Integration tests: simulate a full game loop (new game → moves → line removal → score update → game over).
2. Swift 6 strict concurrency audit — ensure `GameModel` is `Sendable`, mark `GameScene` interactions `@MainActor`, resolve warnings.
3. iPad layout support (centered board with max size constraint), test on multiple screen sizes.
4. Empty `Sounds/` directory with documented hook points in `GameScene` for future `SKAction.playSoundFileNamed`.

## Key Decisions
- **`UserDefaults`** for high scores — simpler than SwiftData for just 10 entries.
- **`SKShapeNode`** with gradient fills for balls — no texture assets needed initially.
- **Step-by-step path animation** — ball slides through each BFS cell for classic feel.

