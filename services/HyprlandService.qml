pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property int activeWorkspace: Hyprland.focusedWorkspace?.id ?? 1
    readonly property var activeToplevel: Hyprland.activeToplevel
    readonly property string activeWindowTitle: activeToplevel?.title || "NO ACTIVE WINDOW"
    readonly property string activeWindowClass: activeToplevel?.lastIpcObject?.class || "UNKNOWN"
    readonly property bool available: Hyprland.focusedWorkspace !== null || (Hyprland.workspaces?.values?.length ?? 0) > 0
    readonly property string compositorName: "hyprland"
    readonly property bool activeWindowAvailable: activeToplevel !== null
    readonly property string statusLine: available ? "hyprland: workspace service online" : "hyprland: workspace fallback"
    readonly property var workspaces: workspaceRows()
    readonly property var currentWorkspaceWindows: windowRowsForWorkspace(activeWorkspace)
    readonly property var occupiedIds: {
        const values = Hyprland.workspaces?.values || [];
        return values.filter(workspace => workspace.id > 0 && (workspace.lastIpcObject?.windows ?? 0) > 0).map(workspace => workspace.id);
    }

    function isOccupied(id: int): bool {
        return occupiedIds.indexOf(id) >= 0;
    }

    function workspaceRows(): var {
        const rows = [];
        for (let id = 1; id <= 5; id++) {
            rows.push({
                id: id,
                label: String(id),
                active: id === activeWorkspace,
                occupied: isOccupied(id)
            });
        }
        return rows;
    }

    function switchWorkspace(id: int): void {
        if (!available)
            return;
        Hyprland.dispatch(`workspace ${id}`);
    }

    function compact(text: string, maxLength: int): string {
        if (text.length <= maxLength)
            return text;
        return text.slice(0, Math.max(0, maxLength - 3)) + "...";
    }

    function windowRowsForWorkspace(id: int): var {
        const values = Hyprland.toplevels?.values || [];
        return values.filter(toplevel => toplevel.workspace?.id === id).slice(0, 6).map(toplevel => ({
            windowKey: toplevel.lastIpcObject?.address || compact(toplevel.title || "UNTITLED", 42),
            title: compact(toplevel.title || "UNTITLED", 42),
            appClass: compact(toplevel.lastIpcObject?.class || "unknown", 18),
            active: toplevel === activeToplevel
        }));
    }

    function focusWindow(windowKey: string): void {
        const values = Hyprland.toplevels?.values || [];
        const target = values.find(toplevel => toplevel.lastIpcObject?.address === windowKey || (toplevel.title || "UNTITLED") === windowKey || compact(toplevel.title || "UNTITLED", 42) === windowKey);
        if (target?.lastIpcObject?.address)
            Hyprland.dispatch(`focuswindow address:${target.lastIpcObject.address}`);
    }

    function logout(): void {
        if (available)
            Hyprland.dispatch("exit");
    }
}
