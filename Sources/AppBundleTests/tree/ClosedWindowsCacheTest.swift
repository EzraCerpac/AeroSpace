@testable import AppBundle
import XCTest

@MainActor
final class ClosedWindowsCacheTest: XCTestCase {
    override func setUp() async throws {
        setUpWorkspacesForTests()
        resetClosedWindowsCache()
    }

    override func tearDown() async throws { resetClosedWindowsCache() }

    func testRestorePreservesWorkspaceSelectedSinceCaching() async throws {
        let terminalWorkspace = Workspace.get(byName: "T")
        let chatWorkspace = Workspace.get(byName: "2")
        let terminal = TestWindow.new(id: 1, parent: terminalWorkspace.floatingWindowsContainer)
        let chat = TestWindow.new(id: 2, parent: chatWorkspace.floatingWindowsContainer)
        terminalWorkspace.rootTilingContainer.changeOrientation(.v)
        terminalWorkspace.rootTilingContainer.layout = .accordion
        assertTrue(terminal.focusWindow())
        cacheClosedWindowIfNeeded()

        terminalWorkspace.rootTilingContainer.changeOrientation(.h)
        terminalWorkspace.rootTilingContainer.layout = .tiles
        assertTrue(chat.focusWindow())
        chat.nativeFocus()
        assertEquals(mainMonitorInfo.activeWorkspace, chatWorkspace)

        assertTrue(try await restoreClosedWindowsCacheIfNeeded(newlyDetectedWindow: terminal))

        assertEquals(mainMonitorInfo.activeWorkspace, chatWorkspace)
        assertEquals(focus.workspace, chatWorkspace)
        assertEquals(focus.windowOrNil, chat)
        assertEquals(terminalWorkspace.rootTilingContainer.orientation, .v)
        assertEquals(terminalWorkspace.rootTilingContainer.layout, .accordion)
        let visibleWorkspace = mainMonitorInfo.activeWorkspace
        XCTAssertFalse(focusHoveredWindowIfWorkspaceUnchanged(
            terminal,
            capturedWorkspace: visibleWorkspace,
            currentWorkspace: mainMonitorInfo.activeWorkspace,
        ))
        assertEquals(focus.workspace, chatWorkspace)
        assertEquals(TestApp.shared.focusedWindow, chat)
    }

    func testRestoreRecoversLayoutOnTheCurrentWorkspace() async throws {
        let workspace = Workspace.get(byName: name)
        let window = TestWindow.new(id: 1, parent: workspace.floatingWindowsContainer)
        workspace.rootTilingContainer.changeOrientation(.v)
        workspace.rootTilingContainer.layout = .accordion
        assertTrue(window.focusWindow())
        cacheClosedWindowIfNeeded()

        workspace.rootTilingContainer.changeOrientation(.h)
        workspace.rootTilingContainer.layout = .tiles

        assertTrue(try await restoreClosedWindowsCacheIfNeeded(newlyDetectedWindow: window))

        assertEquals(mainMonitorInfo.activeWorkspace, workspace)
        assertEquals(focus.windowOrNil, window)
        assertEquals(workspace.rootTilingContainer.orientation, .v)
        assertEquals(workspace.rootTilingContainer.layout, .accordion)
        XCTAssertTrue(focusHoveredWindowIfWorkspaceUnchanged(
            window,
            capturedWorkspace: mainMonitorInfo.activeWorkspace,
            currentWorkspace: mainMonitorInfo.activeWorkspace,
        ))
        assertEquals(TestApp.shared.focusedWindow, window)
    }
}
