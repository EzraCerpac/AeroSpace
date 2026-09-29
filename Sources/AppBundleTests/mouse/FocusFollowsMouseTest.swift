@testable import AppBundle
import XCTest

@MainActor
final class FocusFollowsMouseTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testPendingHoverDoesNotRestoreAnOldWorkspace() {
        let oldWorkspace = Workspace.get(byName: "old")
        let newWorkspace = Workspace.get(byName: "new")
        let oldWindow = TestWindow.new(id: 1, parent: oldWorkspace.rootTilingContainer)
        let newWindow = TestWindow.new(id: 2, parent: newWorkspace.rootTilingContainer)
        assertTrue(oldWindow.focusWindow())
        assertTrue(newWindow.focusWindow())

        XCTAssertFalse(focusHoveredWindowIfWorkspaceUnchanged(
            oldWindow,
            capturedWorkspace: oldWorkspace,
            currentWorkspace: newWorkspace,
        ))
        assertEquals(focus.windowOrNil, newWindow)
        XCTAssertNil(TestApp.shared.focusedWindow)
    }

    func testHoverStillFocusesAWindowOnTheCurrentWorkspace() {
        let workspace = Workspace.get(byName: name)
        let window = TestWindow.new(id: 1, parent: workspace.rootTilingContainer)

        XCTAssertTrue(focusHoveredWindowIfWorkspaceUnchanged(
            window,
            capturedWorkspace: workspace,
            currentWorkspace: workspace,
        ))
        assertEquals(focus.windowOrNil, window)
        assertEquals(TestApp.shared.focusedWindow, window)
    }
}
