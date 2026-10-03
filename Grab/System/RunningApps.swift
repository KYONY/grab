import AppKit

struct RunningApp: Identifiable {
    let bundleID: String
    let name: String
    var id: String { bundleID }
}

enum RunningApps {
    @MainActor
    static func candidates(excluding excluded: [String]) -> [RunningApp] {
        let taken = Set(excluded)
        var seen = Set<String>()
        return NSWorkspace.shared.runningApplications
            .compactMap { app -> RunningApp? in
                guard app.activationPolicy == .regular,
                      let id = app.bundleIdentifier,
                      !taken.contains(id),
                      seen.insert(id).inserted else { return nil }
                return RunningApp(bundleID: id, name: app.localizedName ?? id)
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
