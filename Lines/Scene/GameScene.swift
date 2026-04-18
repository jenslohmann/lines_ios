import SpriteKit
import Combine

/// SpriteKit scene that renders the 9×9 grid, ball sprites, and animations.
/// All interactions happen on the main thread (SpriteKit requirement).
@MainActor
class GameScene: SKScene {

    /// Reference to the view model — set by GameView before presentation.
    weak var viewModel: GameViewModel?

    /// Size of each grid cell in points.
    private var cellSize: CGFloat = 0

    /// Origin (bottom-left) of the grid in scene coordinates.
    private var gridOrigin: CGPoint = .zero

    /// Tracks currently displayed ball nodes by position.
    private var ballNodes: [Position: BallNode] = [:]

    /// The position of the currently highlighted (selected) ball.
    private var highlightedPosition: Position?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Scene Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = PlatformColor.white
        calculateGrid()
        drawGrid()
        subscribeToViewModel()
        syncBoard(animated: false)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        calculateGrid()
        removeAllChildren()
        ballNodes.removeAll()
        drawGrid()
        syncBoard(animated: false)
    }

    // MARK: - Grid Layout

    private func calculateGrid() {
        let side = min(size.width, size.height)
        cellSize = side / CGFloat(Constants.gridSize)
        gridOrigin = CGPoint(
            x: (size.width - side) / 2,
            y: (size.height - side) / 2
        )
    }

    /// Converts a grid Position to scene coordinates (center of cell).
    private func pointForPosition(_ pos: Position) -> CGPoint {
        // SpriteKit y-axis goes up; row 0 = top of grid
        let x = gridOrigin.x + (CGFloat(pos.col) + 0.5) * cellSize
        let y = gridOrigin.y + (CGFloat(Constants.gridSize - 1 - pos.row) + 0.5) * cellSize
        return CGPoint(x: x, y: y)
    }

    /// Converts a scene point to a grid Position, or nil if outside the grid.
    private func positionForPoint(_ point: CGPoint) -> Position? {
        let col = Int((point.x - gridOrigin.x) / cellSize)
        let row = Constants.gridSize - 1 - Int((point.y - gridOrigin.y) / cellSize)
        let pos = Position(row: row, col: col)
        return pos.isValid ? pos : nil
    }

    // MARK: - Drawing

    private func drawGrid() {
        let side = cellSize * CGFloat(Constants.gridSize)

        // Background
        let bg = SKShapeNode(rect: CGRect(origin: gridOrigin,
                                           size: CGSize(width: side, height: side)))
        bg.fillColor = PlatformColor(white: 0.92, alpha: 1)
        bg.strokeColor = .clear
        bg.zPosition = 0
        addChild(bg)

        // Grid lines
        let lineColor = PlatformColor(white: 0.75, alpha: 1)
        for i in 0...Constants.gridSize {
            let offset = CGFloat(i) * cellSize

            // Vertical
            let vLine = SKShapeNode(rect: CGRect(
                x: gridOrigin.x + offset - 0.5,
                y: gridOrigin.y,
                width: 1,
                height: side
            ))
            vLine.fillColor = lineColor
            vLine.strokeColor = .clear
            vLine.zPosition = 1
            addChild(vLine)

            // Horizontal
            let hLine = SKShapeNode(rect: CGRect(
                x: gridOrigin.x,
                y: gridOrigin.y + offset - 0.5,
                width: side,
                height: 1
            ))
            hLine.fillColor = lineColor
            hLine.strokeColor = .clear
            hLine.zPosition = 1
            addChild(hLine)
        }
    }

    // MARK: - ViewModel Observation

    private func subscribeToViewModel() {
        guard let vm = viewModel else { return }

        vm.$model
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.syncBoard(animated: true)
            }
            .store(in: &cancellables)

        vm.$selectedBall
            .receive(on: RunLoop.main)
            .sink { [weak self] selected in
                self?.updateSelection(selected)
            }
            .store(in: &cancellables)
    }

    // MARK: - Board Sync

    private func syncBoard(animated: Bool) {
        guard let vm = viewModel else { return }
        let board = vm.board
        let removedPositions = Set(vm.lastRemovedPositions)

        // Remove nodes for balls no longer on the board
        for (pos, node) in ballNodes {
            if board[pos] == nil {
                if animated && removedPositions.contains(pos) {
                    node.animateRemoval()
                } else {
                    node.removeFromParent()
                }
                ballNodes.removeValue(forKey: pos)
            }
        }

        // Add nodes for new balls
        for (pos, ball) in board {
            if ballNodes[pos] == nil {
                let node = BallNode(ball: ball, cellSize: cellSize)
                node.position = pointForPosition(pos)
                addChild(node)
                if animated {
                    node.animateAppear()
                }
                ballNodes[pos] = node
            }
        }

        // Update positions of existing nodes (in case a ball moved)
        for (pos, ball) in board {
            if let node = ballNodes[pos], node.gridPosition != pos {
                node.gridPosition = pos
                node.position = pointForPosition(pos)
            }
            // Ensure color matches
            if let node = ballNodes[pos], node.ballColor != ball.color {
                node.removeFromParent()
                let newNode = BallNode(ball: ball, cellSize: cellSize)
                newNode.position = pointForPosition(pos)
                addChild(newNode)
                ballNodes[pos] = newNode
            }
        }
    }

    // MARK: - Selection

    private func updateSelection(_ selected: Position?) {
        // Stop previous highlight
        if let prev = highlightedPosition, let node = ballNodes[prev] {
            node.stopSelectedAnimation()
        }

        highlightedPosition = selected

        // Start new highlight
        if let pos = selected, let node = ballNodes[pos] {
            node.animateSelected()
        }
    }

    // MARK: - Move Animation

    /// Animates a ball node along a BFS path, then calls completion.
    func animateMove(path: [Position], completion: @escaping () -> Void) {
        guard path.count >= 2,
              let node = ballNodes[path.first!] else {
            completion()
            return
        }

        // Remove from old position tracking
        ballNodes.removeValue(forKey: path.first!)

        var actions: [SKAction] = []
        for i in 1..<path.count {
            let dest = pointForPosition(path[i])
            actions.append(.move(to: dest, duration: Constants.moveStepDuration))
        }

        node.run(.sequence(actions)) { [weak self] in
            if let last = path.last {
                node.gridPosition = last
                self?.ballNodes[last] = node
            }
            completion()
        }
    }

    // MARK: - Sound Hooks
    //
    // To add sound effects later, call these from the appropriate animation methods.
    // Place .caf/.wav/.mp3 files in Lines/Resources/Sounds/ and use:
    //
    //   run(SKAction.playSoundFileNamed("move.caf", waitForCompletion: false))
    //
    // Hook points:
    //   - Ball selected:  in handleTap(at:) after successful selection
    //   - Ball moved:     in animateMove(path:completion:) before the sequence runs
    //   - Line removed:   in syncBoard(animated:) when animateRemoval is called
    //   - Balls spawned:  in syncBoard(animated:) when animateAppear is called
    //   - Game over:      in syncBoard(animated:) when vm.isGameOver becomes true
    //
    // Check @AppStorage("soundEnabled") before playing:
    //   if UserDefaults.standard.bool(forKey: "soundEnabled") { run(sound) }

    // MARK: - Touch Handling

    #if os(iOS)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        handleTap(at: location)
    }
    #else
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        handleTap(at: location)
    }
    #endif

    private func handleTap(at location: CGPoint) {
        guard let pos = positionForPoint(location) else { return }
        viewModel?.selectCell(pos)
    }
}

