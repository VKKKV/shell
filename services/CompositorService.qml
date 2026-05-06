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
    readonly property var workspaces: hyprlandActive ? HyprlandService.workspaces : (niriActive ? NiriService.workspaces : fallbackWorkspaces())
    readonly property var currentWorkspaceWindows: hyprlandActive ? HyprlandService.currentWorkspaceWindows : (niriActive ? NiriService.currentWorkspaceWindows : [])
    readonly property string backendStatusLine: "active: " + compositorName + " // hypr " + (HyprlandService.available ? "online" : "fallback") + " // niri " + (NiriService.available ? "online" : "fallback")
    readonly property string workspaceStatusLine: "workspace: " + activeWorkspace + " // rows " + workspaces.length + " // windows " + currentWorkspaceWindows.length
    readonly property var diagnosticRows: [
        ["ACTIVE", backendStatusLine],
        ["HYPR", HyprlandService.statusLine],
        ["NIRI", NiriService.statusLine],
        ["SPACE", workspaceStatusLine],
        ["WINDOW", activeWindowClass + " // " + activeWindowTitle]
    ]

    property string lastLoggedBackend: ""
    property string lastLoggedBackendStatus: ""
    property string lastLoggedWorkspaceStatus: ""

    function logLevelFor(message: string): string {
        return message.toLowerCase().indexOf("fallback") >= 0 ? "warn" : "info";
    }

    function logStatusChange(kind: string, current: string, last: string): string {
        if (current === last)
            return last;

        ServiceLogService.push("compositor", logLevelFor(current), kind + ": " + current);
        return current;
    }

    function syncLogState(): void {
        lastLoggedBackend = logStatusChange("backend", compositorName, lastLoggedBackend);
        lastLoggedBackendStatus = logStatusChange("status", backendStatusLine, lastLoggedBackendStatus);
        lastLoggedWorkspaceStatus = logStatusChange("workspace", workspaceStatusLine, lastLoggedWorkspaceStatus);
    }

    Component.onCompleted: syncLogState()

    onCompositorNameChanged: syncLogState()
    onBackendStatusLineChanged: syncLogState()
    onWorkspaceStatusLineChanged: syncLogState()

    function fallbackWorkspaces(): var {
        const rows = [];
        for (let id = 1; id <= 5; id++) {
            rows.push({
                id: id,
                label: String(id),
                active: id === activeWorkspace,
                occupied: false
            });
        }
        return rows;
    }

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
