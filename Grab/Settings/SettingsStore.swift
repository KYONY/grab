import Foundation
import Observation

@MainActor
@Observable
final class SettingsStore {
    private enum Key {
        static let isEnabled = "isEnabled"
        static let excludedBundleIDs = "excludedBundleIDs"
        static let launchAtLogin = "launchAtLogin"
    }

    @ObservationIgnored private let defaults: UserDefaults

    var isEnabled: Bool {
        didSet { defaults.set(isEnabled, forKey: Key.isEnabled) }
    }

    var excludedBundleIDs: [String] {
        didSet {
            let unique = Self.deduplicated(excludedBundleIDs)
            if unique != excludedBundleIDs {
                excludedBundleIDs = unique
                return
            }
            defaults.set(excludedBundleIDs, forKey: Key.excludedBundleIDs)
        }
    }

    var launchAtLogin: Bool {
        didSet { defaults.set(launchAtLogin, forKey: Key.launchAtLogin) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isEnabled = defaults.object(forKey: Key.isEnabled) as? Bool ?? true
        if let stored = defaults.stringArray(forKey: Key.excludedBundleIDs) {
            excludedBundleIDs = Self.deduplicated(stored)
        } else {
            excludedBundleIDs = DefaultExcludes.bundleIDs
            defaults.set(DefaultExcludes.bundleIDs, forKey: Key.excludedBundleIDs)
        }
        launchAtLogin = defaults.bool(forKey: Key.launchAtLogin)
    }

    private static func deduplicated(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        return ids.filter { seen.insert($0).inserted }
    }
}
