import Testing
@testable import Grab

struct ClipboardFilterTests {
    @Test func normalTextWritten() { #expect(ClipboardFilter.shouldWrite(text: "hello", currentClipboard: "other")) }
    @Test func emptyRejected() { #expect(!ClipboardFilter.shouldWrite(text: "", currentClipboard: nil)) }
    @Test func whitespaceOnlyRejected() { #expect(!ClipboardFilter.shouldWrite(text: "   \n\t ", currentClipboard: nil)) }
    @Test func oneCharacterRejected() { #expect(!ClipboardFilter.shouldWrite(text: "a", currentClipboard: nil)) }
    @Test func oneCharacterPaddedRejected() { #expect(!ClipboardFilter.shouldWrite(text: "  a\n", currentClipboard: nil)) }
    @Test func twoCharactersAccepted() { #expect(ClipboardFilter.shouldWrite(text: "ab", currentClipboard: nil)) }
    @Test func duplicateOfClipboardRejected() { #expect(!ClipboardFilter.shouldWrite(text: "same text", currentClipboard: "same text")) }
    @Test func nilClipboardAccepted() { #expect(ClipboardFilter.shouldWrite(text: "hello", currentClipboard: nil)) }
    @Test func differentClipboardAccepted() { #expect(ClipboardFilter.shouldWrite(text: "hello", currentClipboard: "world")) }
}
