import Testing
@testable import Grab

struct CaptureStrategyTests {
    @Test func textWrites() { #expect(CaptureStrategy.next(for: .text("abc")) == .write("abc")) }
    @Test func emptySkips() { #expect(CaptureStrategy.next(for: .empty) == .skip) }
    @Test func unsupportedFallsBack() { #expect(CaptureStrategy.next(for: .unsupported) == .fallbackCopy) }
}

struct ExcludeMatcherTests {
    private let list = ["com.apple.Terminal", "com.apple.finder"]

    @Test func listedExcluded() { #expect(ExcludeMatcher.isExcluded(bundleID: "com.apple.Terminal", list: list)) }
    @Test func unlistedNotExcluded() { #expect(!ExcludeMatcher.isExcluded(bundleID: "com.apple.Safari", list: list)) }
    @Test func nilNotExcluded() { #expect(!ExcludeMatcher.isExcluded(bundleID: nil, list: list)) }
    @Test func emptyListNotExcluded() { #expect(!ExcludeMatcher.isExcluded(bundleID: "com.apple.Terminal", list: [])) }
}

struct FallbackGuardTests {
    @Test(arguments: ["AXTable", "AXOutline", "AXList", "AXBrowser", "AXRow", "AXCell"])
    func collectionRolesBlockCopy(role: String) { #expect(!FallbackGuard.allowsCopy(focusedRole: role)) }

    @Test(arguments: ["AXTextArea", "AXTextField", "AXWebArea", "AXGroup"])
    func otherRolesAllowCopy(role: String) { #expect(FallbackGuard.allowsCopy(focusedRole: role)) }

    @Test func unknownRoleAllowsCopy() { #expect(FallbackGuard.allowsCopy(focusedRole: nil)) }
}
