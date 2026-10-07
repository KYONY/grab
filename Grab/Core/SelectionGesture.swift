import CoreGraphics

enum SelectionGesture {
    static let minimumDragDistance: CGFloat = 4
    static let sameLineTolerance: CGFloat = 8
    static let textRoles: Set<String> = ["AXTextArea", "AXTextField", "AXStaticText", "AXWebArea"]

    static func classify(down: CGPoint, up: CGPoint, clickCount: Int, dragDistance: CGFloat, roleAtDown: String?) -> Bool {
        if let role = roleAtDown, !textRoles.contains(role) {
            return false
        }
        if dragDistance >= minimumDragDistance {
            return isForward(down: down, up: up)
        }
        return clickCount == 2 || clickCount == 3
    }

    // Reading order in global coordinates (y grows downward): a lower line is forward,
    // on the same line left-to-right is forward. A backward drag only selects.
    static func isForward(down: CGPoint, up: CGPoint) -> Bool {
        let dy = up.y - down.y
        if abs(dy) > sameLineTolerance {
            return dy > 0
        }
        return up.x > down.x
    }
}
