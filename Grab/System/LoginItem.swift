import ServiceManagement

enum LoginItem {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func register() {
        do { try SMAppService.mainApp.register() } catch {}
    }

    static func unregister() {
        do { try SMAppService.mainApp.unregister() } catch {}
    }
}
