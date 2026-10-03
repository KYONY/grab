import XCTest
@testable import Grab

@MainActor
final class SettingsStoreTests: XCTestCase {
    private var suiteName: String!
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = UUID().uuidString
        defaults = UserDefaults(suiteName: suiteName)!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testFirstLaunchDefaults() {
        let store = SettingsStore(defaults: defaults)
        XCTAssertTrue(store.isEnabled)
        XCTAssertEqual(store.excludedBundleIDs, DefaultExcludes.bundleIDs)
        XCTAssertFalse(store.launchAtLogin)
    }

    func testPersistenceRoundTrip() {
        let first = SettingsStore(defaults: defaults)
        first.isEnabled = false
        first.launchAtLogin = true
        first.excludedBundleIDs = ["com.example.b", "com.example.a"]

        let second = SettingsStore(defaults: defaults)
        XCTAssertFalse(second.isEnabled)
        XCTAssertTrue(second.launchAtLogin)
        XCTAssertEqual(second.excludedBundleIDs, ["com.example.b", "com.example.a"])
    }

    func testDeduplicatesPreservingOrder() {
        let store = SettingsStore(defaults: defaults)
        store.excludedBundleIDs = ["a", "b", "a", "c", "b"]
        XCTAssertEqual(store.excludedBundleIDs, ["a", "b", "c"])
        XCTAssertEqual(SettingsStore(defaults: defaults).excludedBundleIDs, ["a", "b", "c"])
    }

    func testEmptiedListIsNotRefilled() {
        let first = SettingsStore(defaults: defaults)
        first.excludedBundleIDs = []
        let second = SettingsStore(defaults: defaults)
        XCTAssertEqual(second.excludedBundleIDs, [])
    }
}
