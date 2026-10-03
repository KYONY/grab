import AppKit
import SwiftUI

struct OnboardingView: View {
    var monitor: PermissionMonitor
    var onTrusted: () -> Void = {}

    private static let settingsURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"
    )!

    var body: some View {
        VStack(spacing: 16) {
            Text("Grab needs Accessibility access")
                .font(.title2.bold())
            Text("Grab uses the Accessibility permission to read the text you select. Turn it on for Grab in System Settings.")
                .multilineTextAlignment(.center)
            Button("Open System Settings") {
                NSWorkspace.shared.open(Self.settingsURL)
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(24)
        .frame(width: 380)
        .onChange(of: monitor.isTrusted) { _, trusted in
            if trusted { onTrusted() }
        }
    }
}
