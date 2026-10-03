enum AXReadResult: Equatable, Sendable {
    case text(String)
    case empty
    case unsupported
}

enum CaptureAction: Equatable, Sendable {
    case write(String)
    case skip
    case fallbackCopy
}

enum CaptureStrategy {
    static func next(for result: AXReadResult) -> CaptureAction {
        switch result {
        case .text(let text): .write(text)
        case .empty: .skip
        case .unsupported: .fallbackCopy
        }
    }
}

enum ExcludeMatcher {
    static func isExcluded(bundleID: String?, list: [String]) -> Bool {
        guard let bundleID else { return false }
        return list.contains(bundleID)
    }
}
