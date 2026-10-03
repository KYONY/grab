enum StatusIcon {
    static func symbol(trusted: Bool, enabled: Bool, flashing: Bool) -> String {
        guard trusted else { return "exclamationmark.triangle" }
        guard enabled else { return "minus.circle" }
        return flashing ? "doc.on.clipboard.fill" : "doc.on.clipboard"
    }
}
