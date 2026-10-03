import AppKit
import SwiftUI

struct MenuContent: View {
    @Bindable var settings: SettingsStore
    var permission: PermissionMonitor
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        Toggle("Enabled", isOn: $settings.isEnabled)
            .disabled(!permission.isTrusted)
        Button("Settings…") {
            NSApp.activate()
            openSettings()
        }
        Divider()
        Button("Quit") {
            NSApplication.shared.terminate(nil)
        }
    }
}
