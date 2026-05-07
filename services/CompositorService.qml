pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool hyprlandActive: HyprlandService.available
    readonly property bool niriActive: !hyprlandActive && NiriService.available
    readonly property var activeBackend: hyprlandActive ? HyprlandService : (niriActive ? NiriService : null)
    readonly property string compositorName: activeBackend ? activeBackend.compositorName : "fallback"
    readonly property bool available: activeBackend !== null
    readonly property string statusLine: activeBackend ? "compositor: " + compositorName + " online" : "compositor: fallback"
    readonly property int activeWorkspace: activeBackend ? activeBackend.activeWorkspace : 1
    readonly property string activeWindowTitle: activeBackend ? activeBackend.activeWindowTitle : "NO ACTIVE WINDOW"
    readonly property string activeWindowClass: activeBackend ? activeBackend.activeWindowClass : "UNKNOWN"
    readonly property bool activeWindowAvailable: activeBackend ? activeBackend.activeWindowAvailable : false
    readonly property var workspaces: activeBackend ? activeBackend.workspaces : fallbackWorkspaces()
    readonly property var currentWorkspaceWindows: activeBackend ? activeBackend.currentWorkspaceWindows : []
    readonly property string backendStatusLine: "active: " + compositorName + " // hypr " + (HyprlandService.available ? "online" : "fallback") + " // niri " + (NiriService.available ? "online" : "fallback")
    readonly property string workspaceStatusLine: "workspace: " + activeWorkspace + " // rows " + workspaces.length + " // windows " + currentWorkspaceWindows.length
    readonly property var diagnosticRows: [
        ["ACTIVE", backendStatusLine],
        ["HYPR", HyprlandService.statusLine],
        ["NIRI", NiriService.statusLine],
        ["SPACE", workspaceStatusLine],
        ["ACTION", actionStatusLine],
        ["WINDOW", activeWindowClass + " // " + activeWindowTitle]
    ]

    property string actionStatusLine: "action: standby"
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

    function setActionStatus(message: string, level: string): void {
        actionStatusLine = message;
        ServiceLogService.push("compositor", level, message);
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
        return activeBackend ? activeBackend.isOccupied(id) : false;
    }

    function switchWorkspace(id: int): void {
        if (!available) {
            setActionStatus("action: workspace " + id + " unavailable", "warn");
            return;
        }
        setActionStatus("action: switch workspace " + id + " via " + compositorName, "info");
        activeBackend.switchWorkspace(id);
    }

    function focusWindow(windowKey: string): void {
        if (!available) {
            setActionStatus("action: focus window unavailable", "warn");
            return;
        }
        if (!windowKey || windowKey.length === 0) {
            setActionStatus("action: focus window missing key", "warn");
            return;
        }
        setActionStatus("action: focus window via " + compositorName, "info");
        activeBackend.focusWindow(windowKey);
    }

    function logout(): bool {
        if (activeBackend) {
            setActionStatus("action: logout via " + compositorName, "info");
            activeBackend.logout();
            return true;
        }
        setActionStatus("action: compositor logout unavailable", "warn");
        return false;
    }
}
