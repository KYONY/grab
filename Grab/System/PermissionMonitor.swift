import ApplicationServices
import Observation

@MainActor
@Observable
final class PermissionMonitor {
    typealias TimerFactory = @MainActor (@escaping @MainActor () -> Void) -> Task<Void, Never>

    private(set) var isTrusted: Bool

    @ObservationIgnored private let check: () -> Bool
    @ObservationIgnored private let makeTimer: TimerFactory
    @ObservationIgnored private var timer: Task<Void, Never>?

    init(
        check: @escaping () -> Bool = { AXIsProcessTrusted() },
        makeTimer: @escaping TimerFactory = PermissionMonitor.liveTimer
    ) {
        self.check = check
        self.makeTimer = makeTimer
        self.isTrusted = false
    }

    static let liveTimer: TimerFactory = { fire in
        Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                fire()
            }
        }
    }

    func start() {
        guard timer == nil else { return }
        isTrusted = check()
        guard !isTrusted else { return }
        timer = makeTimer { [weak self] in self?.tick() }
    }

    func stop() {
        timer?.cancel()
        timer = nil
    }

    func tick() {
        guard !isTrusted else { return }
        isTrusted = check()
        if isTrusted { stop() }
    }
}
