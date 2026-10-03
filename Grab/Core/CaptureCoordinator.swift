import AppKit

@MainActor
protocol PasteboardAccessing {
    var changeCount: Int { get }
    var currentString: String? { get }
    func write(_ text: String)
    func snapshot() -> [[NSPasteboard.PasteboardType: Data]]
    func restore(_ items: [[NSPasteboard.PasteboardType: Data]])
}

extension PasteboardWriter: PasteboardAccessing {}

struct FrontmostApp: Equatable {
    let bundleID: String?
    let pid: pid_t
}

@MainActor
final class CaptureCoordinator {
    static let readDelay: TimeInterval = 0.06
    static let copyDelay: TimeInterval = 0.15

    private let settings: SettingsStore
    private let isTrusted: () -> Bool
    private let frontmostApp: () -> FrontmostApp?
    private let reader: SelectionReading
    private let postCopy: () -> Void
    private let pasteboard: PasteboardAccessing
    private let schedule: (TimeInterval, @escaping @MainActor () -> Void) -> Void
    private let onCopied: () -> Void

    init(
        settings: SettingsStore,
        isTrusted: @escaping () -> Bool,
        frontmostApp: @escaping () -> FrontmostApp? = CaptureCoordinator.liveFrontmostApp,
        reader: SelectionReading,
        postCopy: @escaping () -> Void = CopyKeystroke.post,
        pasteboard: PasteboardAccessing,
        schedule: @escaping (TimeInterval, @escaping @MainActor () -> Void) -> Void = CaptureCoordinator.liveSchedule,
        onCopied: @escaping () -> Void
    ) {
        self.settings = settings
        self.isTrusted = isTrusted
        self.frontmostApp = frontmostApp
        self.reader = reader
        self.postCopy = postCopy
        self.pasteboard = pasteboard
        self.schedule = schedule
        self.onCopied = onCopied
    }

    nonisolated static func liveFrontmostApp() -> FrontmostApp? {
        guard let app = NSWorkspace.shared.frontmostApplication else { return nil }
        return FrontmostApp(bundleID: app.bundleIdentifier, pid: app.processIdentifier)
    }

    nonisolated static func liveSchedule(_ delay: TimeInterval, _ action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(delay))
            action()
        }
    }

    func handle(_ gesture: MouseGesture) {
        guard settings.isEnabled, isTrusted(), let app = frontmostApp() else { return }
        guard !ExcludeMatcher.isExcluded(bundleID: app.bundleID, list: settings.excludedBundleIDs) else { return }
        guard SelectionGesture.classify(
            down: gesture.down,
            up: gesture.up,
            clickCount: gesture.clickCount,
            dragDistance: gesture.dragDistance,
            roleAtDown: gesture.roleAtDown
        ) else { return }

        schedule(Self.readDelay) { [self] in
            switch CaptureStrategy.next(for: reader.selectedText(pid: app.pid)) {
            case .write(let text):
                if ClipboardFilter.shouldWrite(text: text, currentClipboard: pasteboard.currentString) {
                    pasteboard.write(text)
                    onCopied()
                }
            case .fallbackCopy:
                fallbackCopy()
            case .skip:
                break
            }
        }
    }

    private func fallbackCopy() {
        let previousCount = pasteboard.changeCount
        let previousString = pasteboard.currentString
        let previousItems = pasteboard.snapshot()
        postCopy()
        schedule(Self.copyDelay) { [self] in
            guard pasteboard.changeCount != previousCount else { return }
            guard let new = pasteboard.currentString,
                  ClipboardFilter.shouldWrite(text: new, currentClipboard: previousString) else {
                pasteboard.restore(previousItems)
                return
            }
            pasteboard.write(new)
            onCopied()
        }
    }
}
