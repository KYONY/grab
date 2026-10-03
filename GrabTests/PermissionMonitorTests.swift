import Testing
@testable import Grab

@MainActor
struct PermissionMonitorTests {
    @MainActor private final class Harness {
        var trusted = false
        var checks = 0
        var fire: (@MainActor () -> Void)?
        var timersMade = 0

        func makeMonitor() -> PermissionMonitor {
            PermissionMonitor(
                check: { [self] in checks += 1; return trusted },
                makeTimer: { [self] handler in
                    timersMade += 1
                    fire = handler
                    return Task {}
                }
            )
        }
    }

    @Test func pollsWhileUntrusted() {
        let h = Harness()
        let monitor = h.makeMonitor()
        monitor.start()
        #expect(!monitor.isTrusted)
        #expect(h.checks == 1)
        h.fire?()
        h.fire?()
        #expect(!monitor.isTrusted)
        #expect(h.checks == 3)
    }

    @Test func stopsAfterTrusted() {
        let h = Harness()
        let monitor = h.makeMonitor()
        monitor.start()
        h.trusted = true
        h.fire?()
        #expect(monitor.isTrusted)
        let before = h.checks
        h.fire?()
        monitor.tick()
        #expect(h.checks == before)
    }

    @Test func startingTrustedDoesNotPoll() {
        let h = Harness()
        h.trusted = true
        let monitor = h.makeMonitor()
        monitor.start()
        #expect(monitor.isTrusted)
        #expect(h.timersMade == 0)
        #expect(h.checks == 1)
    }
}
