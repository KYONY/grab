import AppKit

struct MouseGesture {
    let down: CGPoint
    let up: CGPoint
    let clickCount: Int
    let dragDistance: CGFloat
    let roleAtDown: String?
}

@MainActor
final class MouseMonitor {
    private let reader: SelectionReading
    private let handler: @MainActor (MouseGesture) -> Void
    private var monitor: Any?
    private var downPoint: CGPoint = .zero
    private var lastPoint: CGPoint = .zero
    private var dragDistance: CGFloat = 0
    private var roleAtDown: String?

    init(reader: SelectionReading, handler: @escaping @MainActor (MouseGesture) -> Void) {
        self.reader = reader
        self.handler = handler
    }

    func start() {
        guard monitor == nil else { return }
        monitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]
        ) { [weak self] event in
            let type = event.type
            let location = event.cgEvent?.location ?? .zero
            let clickCount = event.clickCount
            MainActor.assumeIsolated {
                self?.handle(type: type, location: location, clickCount: clickCount)
            }
        }
    }

    func stop() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
    }

    func handle(type: NSEvent.EventType, location: CGPoint, clickCount: Int) {
        switch type {
        case .leftMouseDown:
            downPoint = location
            lastPoint = location
            dragDistance = 0
            roleAtDown = reader.roleAt(location)
        case .leftMouseDragged:
            dragDistance += hypot(location.x - lastPoint.x, location.y - lastPoint.y)
            lastPoint = location
        case .leftMouseUp:
            handler(MouseGesture(
                down: downPoint,
                up: location,
                clickCount: clickCount,
                dragDistance: dragDistance,
                roleAtDown: roleAtDown
            ))
        default:
            break
        }
    }
}
