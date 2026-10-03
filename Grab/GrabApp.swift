import AppKit
import Observation
import SwiftUI

@MainActor
@Observable
final class AppModel {
    static let shared = AppModel()
    static let flashDuration: Duration = .milliseconds(300)

    let settings = SettingsStore()
    let permission = PermissionMonitor()
    private(set) var flashing = false

    @ObservationIgnored private var coordinator: CaptureCoordinator?
    @ObservationIgnored private var mouseMonitor: MouseMonitor?
    @ObservationIgnored private var flashTask: Task<Void, Never>?
    @ObservationIgnored private var onboardingWindow: NSWindow?

    private init() {
        let reader = AccessibilityReader()
        let coordinator = CaptureCoordinator(
            settings: settings,
            isTrusted: { [permission] in permission.isTrusted },
            reader: reader,
            pasteboard: PasteboardWriter(),
            onCopied: { [weak self] in self?.flash() }
        )
        self.coordinator = coordinator
        mouseMonitor = MouseMonitor(reader: reader) { [coordinator] gesture in
            coordinator.handle(gesture)
        }
    }

    var iconName: String {
        StatusIcon.symbol(trusted: permission.isTrusted, enabled: settings.isEnabled, flashing: flashing)
    }

    func start() {
        permission.start()
        mouseMonitor?.start()
        if !permission.isTrusted { showOnboarding() }
    }

    private func flash() {
        flashTask?.cancel()
        flashing = true
        flashTask = Task { [weak self] in
            try? await Task.sleep(for: Self.flashDuration)
            guard !Task.isCancelled else { return }
            self?.flashing = false
        }
    }

    private func showOnboarding() {
        let view = OnboardingView(monitor: permission) { [weak self] in
            self?.onboardingWindow?.close()
            self?.onboardingWindow = nil
        }
        let window = NSWindow(contentViewController: NSHostingController(rootView: view))
        window.title = "Grab"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.center()
        onboardingWindow = window
        NSApp.activate()
        window.makeKeyAndOrderFront(nil)
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        guard ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil else { return }
        MainActor.assumeIsolated { AppModel.shared.start() }
    }
}

@main
struct GrabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    private let model = AppModel.shared

    var body: some Scene {
        MenuBarExtra {
            MenuContent(settings: model.settings, permission: model.permission)
        } label: {
            Image(systemName: model.iconName)
        }
        Settings {
            SettingsView(settings: model.settings)
        }
    }
}
