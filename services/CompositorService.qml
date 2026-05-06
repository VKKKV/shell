pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool hyprlandActive: HyprlandService.available
    readonly property bool niriActive: !hyprlandActive && NiriService.available
    readonly property string compositorName: hyprlandActive ? "hyprland" : (niriActive ? "niri" : "fallback")
    readonly property bool available: hyprlandActive || niriActive
    readonly property string statusLine: hyprlandActive ? "compositor: hyprland online" : (niriActive ? "compositor: niri online" : "compositor: fallback")
    readonly property int activeWorkspace: hyprlandActive ? HyprlandService.activeWorkspace : (niriActive ? NiriService.activeWorkspace : 1)
    readonly property string activeWindowTitle: hyprlandActive ? HyprlandService.activeWindowTitle : (niriActive ? NiriService.activeWindowTitle : "NO ACTIVE WINDOW")
    readonly property string activeWindowClass: hyprlandActive ? HyprlandService.activeWindowClass : (niriActive ? NiriService.activeWindowClass : "UNKNOWN")
    readonly property bool activeWindowAvailable: hyprlandActive ? HyprlandService.activeToplevel !== null : (niriActive && NiriService.activeWindowAvailable)
    readonly property var currentWorkspaceWindows: hyprlandActive ? HyprlandService.currentWorkspaceWindows : (niriActive ? NiriService.currentWorkspaceWindows : [])

    function isOccupied(id: int): bool {
        if (hyprlandActive)
            return HyprlandService.isOccupied(id);
        if (niriActive)
            return NiriService.isOccupied(id);
        return false;
    }

    function switchWorkspace(id: int): void {
        if (!available)
            return;
        if (hyprlandActive)
            HyprlandService.switchWorkspace(id);
        else if (niriActive)
            NiriService.switchWorkspace(id);
    }

    function focusWindow(windowKey: string): void {
        if (!available)
            return;
        if (hyprlandActive)
            HyprlandService.focusWindow(windowKey);
        else if (niriActive)
            NiriService.focusWindow(windowKey);
    }
}
