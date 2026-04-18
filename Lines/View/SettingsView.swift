import SwiftUI

/// Settings screen with sound toggle and other preferences.
struct SettingsView: View {
    @AppStorage("soundEnabled") private var soundEnabled = true

    var body: some View {
        Form {
            Section("Audio") {
                Toggle("Sound Effects", isOn: $soundEnabled)
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}

