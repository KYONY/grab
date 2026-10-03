import Testing
import AppKit
@testable import Grab

@MainActor
final class FakePasteboard: PasteboardAccessing {
    var changeCount = 0
    var currentString: String?
    var writes: [String] = []

    func write(_ text: String) {
        writes.append(text)
        currentString = text
        changeCount += 1
    }

    func snapshot() -> [[NSPasteboard.PasteboardType: Data]] {
        currentString.map { [[.string: Data($0.utf8)]] } ?? []
    }

    func restore(_ items: [[NSPasteboard.PasteboardType: Data]]) {
        currentString = items.first?[.string].flatMap { String(data: $0, encoding: .utf8) }
        changeCount += 1
    }
}

final class FakeReader: SelectionReading {
    var result: AXReadResult = .text("hello")
    var focused: String?
    private(set) var readCount = 0

    func roleAt(_ point: CGPoint) -> String? { nil }

    func selectedText(pid: pid_t) -> AXReadResult {
        readCount += 1
        return result
    }

    func focusedRole(pid: pid_t) -> String? { focused }
}

@MainActor
struct CaptureCoordinatorTests {
    let pasteboard = FakePasteboard()
    let reader = FakeReader()
    let settings: SettingsStore
    var trusted = true
    var app: FrontmostApp? = FrontmostApp(bundleID: "com.example.app", pid: 42)

    init() {
        let defaults = UserDefaults(suiteName: UUID().uuidString)!
        settings = SettingsStore(defaults: defaults)
        settings.excludedBundleIDs = ["com.example.excluded"]
    }

    final class Counters {
        var copies = 0
        var flashes = 0
    }

    let drag = MouseGesture(down: .zero, up: CGPoint(x: 50, y: 0), clickCount: 1, dragDistance: 50, roleAtDown: "AXStaticText")
    let click = MouseGesture(down: .zero, up: .zero, clickCount: 1, dragDistance: 0, roleAtDown: "AXStaticText")

    func run(
        _ gesture: MouseGesture,
        counters: Counters,
        copyEffect: (@MainActor () -> Void)? = nil
    ) {
        let pasteboard = pasteboard
        let trusted = trusted
        let app = app
        let coordinator = CaptureCoordinator(
            settings: settings,
            isTrusted: { trusted },
            frontmostApp: { app },
            reader: reader,
            postCopy: {
                counters.copies += 1
                if let copyEffect { MainActor.assumeIsolated { copyEffect() } }
            },
            pasteboard: pasteboard,
            schedule: { _, action in MainActor.assumeIsolated { action() } },
            onCopied: { counters.flashes += 1 }
        )
        coordinator.handle(gesture)
    }

    @Test func disabledDoesNothing() {
        settings.isEnabled = false
        let c = Counters()
        run(drag, counters: c)
        #expect(pasteboard.writes.isEmpty)
        #expect(reader.readCount == 0)
    }

    @Test func untrustedDoesNothing() {
        var test = self
        test.trusted = false
        let c = Counters()
        test.run(drag, counters: c)
        #expect(test.pasteboard.writes.isEmpty)
        #expect(test.reader.readCount == 0)
    }

    @Test func excludedAppDoesNothing() {
        var test = self
        test.app = FrontmostApp(bundleID: "com.example.excluded", pid: 1)
        let c = Counters()
        test.run(drag, counters: c)
        #expect(test.pasteboard.writes.isEmpty)
        #expect(test.reader.readCount == 0)
    }

    @Test func nonSelectionGestureDoesNotRead() {
        let c = Counters()
        run(click, counters: c)
        #expect(reader.readCount == 0)
        #expect(pasteboard.writes.isEmpty)
    }

    @Test func emptySelectionSkips() {
        reader.result = .empty
        let c = Counters()
        run(drag, counters: c)
        #expect(c.copies == 0)
        #expect(pasteboard.writes.isEmpty)
        #expect(c.flashes == 0)
    }

    @Test func unsupportedPostsCopy() {
        reader.result = .unsupported
        let c = Counters()
        run(drag, counters: c)
        #expect(c.copies == 1)
    }

    @Test func copyWithUnchangedChangeCountDoesNotWrite() {
        reader.result = .unsupported
        let c = Counters()
        run(drag, counters: c)
        #expect(pasteboard.writes.isEmpty)
        #expect(c.flashes == 0)
    }

    @Test func copyWithChangedChangeCountRewritesAndFlashes() {
        reader.result = .unsupported
        pasteboard.currentString = "old"
        let pasteboard = pasteboard
        let c = Counters()
        run(drag, counters: c) {
            pasteboard.currentString = "copied text"
            pasteboard.changeCount += 1
        }
        #expect(pasteboard.writes == ["copied text"])
        #expect(c.flashes == 1)
    }

    @Test func copyOfFilteredTextRestoresPreviousClipboard() {
        reader.result = .unsupported
        pasteboard.currentString = "old"
        let pasteboard = pasteboard
        let c = Counters()
        run(drag, counters: c) {
            pasteboard.currentString = "a"
            pasteboard.changeCount += 1
        }
        #expect(pasteboard.writes.isEmpty)
        #expect(pasteboard.currentString == "old")
        #expect(c.flashes == 0)
    }

    @Test func focusedListDoesNotPostCopy() {
        reader.result = .unsupported
        reader.focused = "AXOutline"
        let c = Counters()
        run(drag, counters: c)
        #expect(c.copies == 0)
        #expect(pasteboard.writes.isEmpty)
    }

    @Test func duplicateTextDoesNotWrite() {
        pasteboard.currentString = "hello"
        let c = Counters()
        run(drag, counters: c)
        #expect(pasteboard.writes.isEmpty)
        #expect(c.flashes == 0)
    }

    @Test func happyPathWritesAndFlashes() {
        let c = Counters()
        run(drag, counters: c)
        #expect(pasteboard.writes == ["hello"])
        #expect(c.flashes == 1)
    }
}
