import SwiftUI

/// About screen showing app name, version, and credits.
struct AboutView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🔮")
                .font(.system(size: 64))

            Text("Lines")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Version \(appVersion)")
                .foregroundStyle(.secondary)

            Text("A classic Color Lines puzzle game.")
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            VStack(spacing: 8) {
                Text("This project is open source.")
                    .font(.subheadline)

                Link("github.com/jenslohmann/lines_ios",
                     destination: URL(string: "https://github.com/jenslohmann/lines_ios")!)
                    .font(.subheadline)
            }

            Spacer()

            Text("© 2026 Jens Lohmann")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.bottom, 32)
        }
        .navigationTitle("About")
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

