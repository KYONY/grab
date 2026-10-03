import AppKit
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Bindable var settings: SettingsStore
    @State private var selection = Set<String>()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Excluded apps")
                .font(.headline)
            List(settings.excludedBundleIDs, id: \.self, selection: $selection) { id in
                ExcludedAppRow(bundleID: id)
            }
            .frame(minHeight: 160)
            HStack(spacing: 6) {
                Menu {
                    ForEach(RunningApps.candidates(excluding: settings.excludedBundleIDs)) { app in
                        Button(app.name) { add(app.bundleID) }
                    }
                    Divider()
                    Button("Choose app…") { chooseApp() }
                } label: {
                    Image(systemName: "plus")
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                Button {
                    settings.excludedBundleIDs.removeAll { selection.contains($0) }
                    selection.removeAll()
                } label: {
                    Image(systemName: "minus")
                }
                .disabled(selection.isEmpty)
            }
            Toggle("Launch at login", isOn: launchBinding)
        }
        .padding(20)
        .frame(width: 420)
        .onAppear { settings.launchAtLogin = LoginItem.isEnabled }
    }

    private var launchBinding: Binding<Bool> {
        Binding(
            get: { settings.launchAtLogin },
            set: { wanted in
                if wanted { LoginItem.register() } else { LoginItem.unregister() }
                settings.launchAtLogin = LoginItem.isEnabled
            }
        )
    }

    private func add(_ bundleID: String) {
        guard !settings.excludedBundleIDs.contains(bundleID) else { return }
        settings.excludedBundleIDs.append(bundleID)
    }

    private func chooseApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        guard panel.runModal() == .OK, let url = panel.url,
              let id = Bundle(url: url)?.bundleIdentifier else { return }
        add(id)
    }
}

private struct ExcludedAppRow: View {
    let bundleID: String

    var body: some View {
        let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        HStack(spacing: 8) {
            if let url {
                Image(nsImage: NSWorkspace.shared.icon(forFile: url.path))
                    .resizable()
                    .frame(width: 24, height: 24)
                VStack(alignment: .leading, spacing: 0) {
                    Text(FileManager.default.displayName(atPath: url.path).replacingOccurrences(of: ".app", with: ""))
                    Text(bundleID)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                Text(bundleID)
            }
        }
    }
}
