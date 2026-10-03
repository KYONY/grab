import Testing
@testable import Grab

struct StatusIconTests {
    private static let warning = "MenuBarNoPermission"
    private static let off = "MenuBarOff"
    private static let on = "MenuBarOn"
    private static let flash = "MenuBarFlash"

    @Test(arguments: [false, true], [false, true])
    func untrustedIsWarning(enabled: Bool, flashing: Bool) {
        #expect(StatusIcon.symbol(trusted: false, enabled: enabled, flashing: flashing) == Self.warning)
    }

    @Test func trustedDisabledIsOff() {
        #expect(StatusIcon.symbol(trusted: true, enabled: false, flashing: false) == Self.off)
    }

    @Test func trustedEnabledIsOn() {
        #expect(StatusIcon.symbol(trusted: true, enabled: true, flashing: false) == Self.on)
    }

    @Test func trustedEnabledFlashingIsFlash() {
        #expect(StatusIcon.symbol(trusted: true, enabled: true, flashing: true) == Self.flash)
    }

    @Test func trustedDisabledFlashingStaysOff() {
        #expect(StatusIcon.symbol(trusted: true, enabled: false, flashing: true) == Self.off)
    }

    @Test func fourSymbolsAreDistinct() {
        #expect(Set([Self.warning, Self.off, Self.on, Self.flash]).count == 4)
    }
}
