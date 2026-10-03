import Foundation

enum ClipboardFilter {
    static let minimumLength = 2

    static func shouldWrite(text: String, currentClipboard: String?) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= minimumLength else { return false }
        return text != currentClipboard
    }
}
