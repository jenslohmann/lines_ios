# Lines — iPhone Game

## Project Overview
**Lines** is an iOS puzzle game built with Swift and SpriteKit, targeting iPhone. The classic "Color Lines" (Lines 98) concept: balls of different colors appear on a 9×9 grid, and the player moves them to form lines of 5+ same-colored balls to score points and clear space. The game ends when the board fills up.

## Tech Stack
- **Language:** Swift 6
- **UI Framework:** SwiftUI (menus, score, overlays)
- **Game Engine:** SpriteKit (game board rendering and animations)
- **Platform:** iOS 17+, iPhone and iPad (native, universal app)
- **Localization:** Danish (da), English (en), French (fr), Japanese (ja) — using String Catalogs (`.xcstrings`)
- **Networking:** Fully offline — no network access required.
- **Sound:** No sound effects initially; architecture supports adding `SKAction.playSoundFileNamed` later.
- **Persistence:** High scores and user preferences (e.g. sound on/off) stored locally via `UserDefaults` or SwiftData.
- **Build System:** Xcode / Swift Package Manager
- **Architecture:** MVVM — `GameViewModel` owns a `GameModel` and exposes state to SwiftUI; SpriteKit scene reads from the view-model.

## Project Structure
```
Lines/
  AGENTS.md
  Lines/
    App/
      LinesApp.swift          # @main entry point
      ContentView.swift        # Root SwiftUI view (menu / game switch)
    Model/
      GameModel.swift          # Core game logic (board, scoring, ball spawning)
      Ball.swift               # Ball value type (color, position)
      Position.swift           # Row/col coordinate
    ViewModel/
      GameViewModel.swift      # ObservableObject bridging model ↔ views
    View/
      GameView.swift           # SwiftUI wrapper hosting the SpriteKit scene
      ScoreView.swift          # Score & next-balls preview
      GameOverView.swift       # Game-over overlay
      HighScoreView.swift      # High score list display
      SettingsView.swift       # Settings screen (sound on/off, etc.)
      AboutView.swift          # About screen (credits, version info)
    Scene/
      GameScene.swift          # SpriteKit scene — grid, ball sprites, animations
      BallNode.swift           # SKSpriteNode subclass for a ball
    Util/
      Pathfinding.swift        # BFS for legal move detection
      Constants.swift          # Grid size, colors, counts, animation durations
    Resources/
      Assets.xcassets          # App icon & color assets
      Localizable.xcstrings    # String Catalog for all localizations
      Sounds/                  # Sound effect files (empty initially)
  Lines.xcodeproj              # Xcode project (or Package.swift)
```

## Game Rules
1. The board is a **9×9** grid, initially empty.
2. Each turn, **3 balls** of random colors appear on random empty cells (7 possible colors).
3. The player taps a ball, then taps an empty cell to move it. A ball can only move if a **clear path** exists (horizontal/vertical, no diagonal, BFS).
4. After a move, if **5 or more** balls of the same color form a contiguous horizontal, vertical, or diagonal line, they are removed and the player scores points. When balls are removed, the 3 new balls do **not** spawn that turn.
5. If no line is formed, 3 new balls spawn.
6. **Score:** 10 points for 5 balls, +10 for each additional ball in the line.
7. Before each turn the player can see which **3 colors** will appear next.
8. The game ends when there are no empty cells left to place new balls.
9. A **high score** list (top 10) is maintained locally, showing score and date.

## Coding Conventions
- Use Swift strict concurrency (`Sendable`, `@MainActor` where appropriate).
- Keep `GameModel` pure and testable — no UIKit/SpriteKit imports.
- Prefer value types (`struct`, `enum`) for model layer.
- Use `Constants` enum (no cases) for magic numbers.
- Document public APIs with `///` doc comments.

## Agent Instructions
- Read this file first before making any changes.
- When modifying game logic, update `GameModel` and add/update unit tests.
- When modifying visuals, work in `GameScene` / `BallNode` and preview in simulator.
- Run `⌘+U` tests after every logic change.
- Keep commits small and focused on one concern.

