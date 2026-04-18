import SwiftUI

/// Displays the current score and the next 3 ball colors.
struct ScoreView: View {
    let score: Int
    let nextColors: [BallColor]

    var body: some View {
        HStack {
            Text("Score: \(score)")
                .font(.title2)
                .fontWeight(.bold)

            Spacer()

            HStack(spacing: 4) {
                Text("Next:")
                    .font(.subheadline)
                ForEach(Array(nextColors.enumerated()), id: \.offset) { _, color in
                    Circle()
                        .fill(color.swiftUIColor)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.horizontal)
    }
}

/// Maps BallColor to SwiftUI Color for display.
extension BallColor {
    var swiftUIColor: Color {
        switch self {
        case .red: .red
        case .green: .green
        case .blue: .blue
        case .yellow: .yellow
        case .cyan: .cyan
        case .magenta: .purple
        case .orange: .orange
        }
    }
}

#Preview {
    ScoreView(score: 42, nextColors: [.red, .blue, .green])
}

