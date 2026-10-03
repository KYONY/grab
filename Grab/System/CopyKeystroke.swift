import Carbon.HIToolbox
import CoreGraphics

enum CopyKeystroke {
    static func post() {
        let key = CGKeyCode(kVK_ANSI_C)
        for keyDown in [true, false] {
            let event = CGEvent(keyboardEventSource: nil, virtualKey: key, keyDown: keyDown)
            event?.flags = .maskCommand
            event?.post(tap: .cghidEventTap)
        }
    }
}
