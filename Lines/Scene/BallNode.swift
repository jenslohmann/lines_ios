import SpriteKit

#if canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#else
import AppKit
typealias PlatformColor = NSColor
#endif

/// SKShapeNode subclass representing a ball on the game board.
@MainActor
class BallNode: SKShapeNode {
    /// The ball color this node represents.
    let ballColor: BallColor
    /// The grid position of this ball.
    var gridPosition: Position

    /// Creates a ball node for the given ball, sized to fit within a cell.
    init(ball: Ball, cellSize: CGFloat) {
        self.ballColor = ball.color
        self.gridPosition = ball.position
        let radius = cellSize * 0.38
        super.init()
        self.path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius,
                                              width: radius * 2, height: radius * 2),
                           transform: nil)
        self.fillColor = ball.color.platformColor
        self.strokeColor = ball.color.platformColor.withAlphaComponent(0.7)
        self.lineWidth = 1.5
        self.name = ball.id.uuidString
        self.zPosition = 10

        // Glossy highlight
        let highlight = SKShapeNode(ellipseOf: CGSize(width: radius * 1.0, height: radius * 0.6))
        highlight.position = CGPoint(x: 0, y: radius * 0.25)
        highlight.fillColor = PlatformColor.white.withAlphaComponent(0.25)
        highlight.strokeColor = .clear
        highlight.zPosition = 1
        addChild(highlight)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Animations

    /// Appear animation — scale from zero.
    func animateAppear() {
        setScale(0)
        run(.scale(to: 1.0, duration: Constants.appearDuration))
    }

    /// Removal animation — shrink and fade out, then remove.
    func animateRemoval(completion: @escaping () -> Void = {}) {
        let shrink = SKAction.scale(to: 0, duration: Constants.removeDuration)
        let fade = SKAction.fadeOut(withDuration: Constants.removeDuration)
        let group = SKAction.group([shrink, fade])
        run(group) { [weak self] in
            self?.removeFromParent()
            completion()
        }
    }

    /// Selection bounce animation — repeating pulse.
    func animateSelected() {
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.3)
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.3)
        let bounce = SKAction.sequence([scaleUp, scaleDown])
        run(.repeatForever(bounce), withKey: "selected")
    }

    /// Stop selection animation.
    func stopSelectedAnimation() {
        removeAction(forKey: "selected")
        run(.scale(to: 1.0, duration: 0.1))
    }
}

// MARK: - BallColor → UIColor

extension BallColor {
    var platformColor: PlatformColor {
        switch self {
        case .red:     PlatformColor(red: 0.90, green: 0.22, blue: 0.21, alpha: 1)
        case .green:   PlatformColor(red: 0.30, green: 0.78, blue: 0.35, alpha: 1)
        case .blue:    PlatformColor(red: 0.20, green: 0.50, blue: 0.90, alpha: 1)
        case .yellow:  PlatformColor(red: 0.95, green: 0.82, blue: 0.20, alpha: 1)
        case .cyan:    PlatformColor(red: 0.20, green: 0.82, blue: 0.87, alpha: 1)
        case .magenta: PlatformColor(red: 0.75, green: 0.25, blue: 0.80, alpha: 1)
        case .orange:  PlatformColor(red: 0.95, green: 0.55, blue: 0.15, alpha: 1)
        }
    }
}





