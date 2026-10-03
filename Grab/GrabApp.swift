import SwiftUI

@main
struct GrabApp: App {
    var body: some Scene {
        MenuBarExtra("Grab", systemImage: "doc.on.clipboard") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}
