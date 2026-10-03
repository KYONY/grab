import ApplicationServices
import Testing
@testable import Grab

struct AccessibilityReaderTests {
    @Test func successWithTextIsText() {
        #expect(AccessibilityReader.map(error: .success, value: "abc") == .text("abc"))
    }

    @Test func successWithEmptyStringIsEmpty() {
        #expect(AccessibilityReader.map(error: .success, value: "") == .empty)
    }

    @Test func successWithNilIsUnsupported() {
        #expect(AccessibilityReader.map(error: .success, value: nil) == .unsupported)
    }

    @Test(arguments: [AXError.attributeUnsupported, .noValue, .cannotComplete, .failure])
    func errorsAreUnsupported(error: AXError) {
        #expect(AccessibilityReader.map(error: error, value: "ignored") == .unsupported)
    }
}
