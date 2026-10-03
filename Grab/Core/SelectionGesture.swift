import CoreGraphics

enum SelectionGesture {
    static let minimumDragDistance: CGFloat = 4
    static let textRoles: Set<String> = ["AXTextArea", "AXTextField", "AXStaticText", "AXWebArea"]

    static func classify(down: CGPoint, up: CGPoint, clickCount: Int, dragDistance: CGFloat, roleAtDown: String?) -> Bool {
        if let role = roleAtDown, !textRoles.contains(role) {
            return false
        }
        return dragDistance >= minimumDragDistance || clickCount == 2 || clickCount == 3
    }
}
