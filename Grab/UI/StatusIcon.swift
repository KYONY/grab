enum StatusIcon {
    static func symbol(trusted: Bool, enabled: Bool, flashing: Bool) -> String {
        guard trusted else { return "MenuBarNoPermission" }
        guard enabled else { return "MenuBarOff" }
        return flashing ? "MenuBarFlash" : "MenuBarOn"
    }
}
