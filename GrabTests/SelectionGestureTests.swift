import CoreGraphics
import Testing
@testable import Grab

struct SelectionGestureTests {
    private func classify(drag: CGFloat = 0, clicks: Int = 1, role: String? = nil) -> Bool {
        SelectionGesture.classify(down: .zero, up: CGPoint(x: drag, y: 0), clickCount: clicks, dragDistance: drag, roleAtDown: role)
    }

    @Test func dragBelowThresholdRejected() { #expect(!classify(drag: 3.9)) }
    @Test func dragAtThresholdAccepted() { #expect(classify(drag: 4.0)) }
    @Test func dragAboveThresholdAccepted() { #expect(classify(drag: 50)) }

    @Test func singleClickRejected() { #expect(!classify(clicks: 1)) }
    @Test func doubleClickAccepted() { #expect(classify(clicks: 2)) }
    @Test func tripleClickAccepted() { #expect(classify(clicks: 3)) }
    @Test func quadrupleClickRejected() { #expect(!classify(clicks: 4)) }

    @Test(arguments: ["AXTextArea", "AXTextField", "AXStaticText", "AXWebArea"])
    func textRolesAccepted(role: String) { #expect(classify(drag: 10, role: role)) }

    @Test func nonTextRoleRejected() {
        #expect(!classify(drag: 10, role: "AXButton"))
        #expect(!classify(clicks: 2, role: "AXButton"))
    }

    @Test func nilRoleAccepted() { #expect(classify(drag: 10, role: nil)) }

    @Test func textRoleWithoutGestureRejected() { #expect(!classify(drag: 1, clicks: 1, role: "AXTextArea")) }

    private func classifyDrag(from down: CGPoint, to up: CGPoint, clicks: Int = 1) -> Bool {
        let distance = hypot(up.x - down.x, up.y - down.y)
        return SelectionGesture.classify(down: down, up: up, clickCount: clicks, dragDistance: distance, roleAtDown: nil)
    }

    @Test func rightToLeftDragRejected() { #expect(!classifyDrag(from: CGPoint(x: 100, y: 0), to: .zero)) }
    @Test func rightToLeftDragWithJitterRejected() { #expect(!classifyDrag(from: CGPoint(x: 100, y: 0), to: CGPoint(x: 0, y: 5))) }
    @Test func leftToRightDragWithJitterAccepted() { #expect(classifyDrag(from: .zero, to: CGPoint(x: 100, y: -5))) }
    @Test func downwardDragEndingLeftAccepted() { #expect(classifyDrag(from: CGPoint(x: 200, y: 0), to: CGPoint(x: 10, y: 40))) }
    @Test func upwardDragEndingRightRejected() { #expect(!classifyDrag(from: CGPoint(x: 10, y: 40), to: CGPoint(x: 200, y: 0))) }
    @Test func backwardDragAfterDoubleClickRejected() { #expect(!classifyDrag(from: CGPoint(x: 100, y: 0), to: .zero, clicks: 2)) }
}
