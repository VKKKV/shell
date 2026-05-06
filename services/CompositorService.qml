pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string compositorName: HyprlandService.available ? "hyprland" : "fallback"
    readonly property bool available: HyprlandService.available
    readonly property string statusLine: HyprlandService.available ? "compositor: hyprland online" : "compositor: fallback"
    readonly property int activeWorkspace: HyprlandService.activeWorkspace
    readonly property string activeWindowTitle: HyprlandService.activeWindowTitle
    readonly property string activeWindowClass: HyprlandService.activeWindowClass
    readonly property bool activeWindowAvailable: HyprlandService.activeToplevel !== null
    readonly property var currentWorkspaceWindows: HyprlandService.currentWorkspaceWindows

    function isOccupied(id: int): bool {
        return HyprlandService.isOccupied(id);
    }

    function switchWorkspace(id: int): void {
        if (!available)
            return;
        HyprlandService.switchWorkspace(id);
    }

    function focusWindow(windowKey: string): void {
        if (!available)
            return;
        HyprlandService.focusWindow(windowKey);
    }
}
