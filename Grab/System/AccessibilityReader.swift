import ApplicationServices

protocol SelectionReading {
    func roleAt(_ point: CGPoint) -> String?
    func selectedText(pid: pid_t) -> AXReadResult
    func focusedRole(pid: pid_t) -> String?
}

struct AccessibilityReader: SelectionReading {
    func roleAt(_ point: CGPoint) -> String? {
        let systemWide = AXUIElementCreateSystemWide()
        var element: AXUIElement?
        guard AXUIElementCopyElementAtPosition(systemWide, Float(point.x), Float(point.y), &element) == .success,
              let element else { return nil }
        var value: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &value) == .success else { return nil }
        return value as? String
    }

    func selectedText(pid: pid_t) -> AXReadResult {
        let app = AXUIElementCreateApplication(pid)
        var focused: CFTypeRef?
        let focusError = AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString, &focused)
        guard focusError == .success, let focused, CFGetTypeID(focused) == AXUIElementGetTypeID() else {
            return .unsupported
        }
        let element = focused as! AXUIElement
        var selected: CFTypeRef?
        let error = AXUIElementCopyAttributeValue(element, kAXSelectedTextAttribute as CFString, &selected)
        return Self.map(error: error, value: selected as? String)
    }

    func focusedRole(pid: pid_t) -> String? {
        let app = AXUIElementCreateApplication(pid)
        var focused: CFTypeRef?
        guard AXUIElementCopyAttributeValue(app, kAXFocusedUIElementAttribute as CFString, &focused) == .success,
              let focused, CFGetTypeID(focused) == AXUIElementGetTypeID() else { return nil }
        var role: CFTypeRef?
        guard AXUIElementCopyAttributeValue(focused as! AXUIElement, kAXRoleAttribute as CFString, &role) == .success else { return nil }
        return role as? String
    }

    static func map(error: AXError, value: String?) -> AXReadResult {
        guard error == .success, let value else { return .unsupported }
        return value.isEmpty ? .empty : .text(value)
    }
}
