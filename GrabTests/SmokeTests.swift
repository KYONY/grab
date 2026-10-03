import XCTest

final class SmokeTests: XCTestCase {
    func testHostBundleIdentifier() {
        XCTAssertEqual(Bundle.main.bundleIdentifier, "com.pryima.grab")
    }
}
