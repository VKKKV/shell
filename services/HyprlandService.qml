pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root

    readonly property int activeWorkspace: Hyprland.focusedWorkspace?.id ?? 1
    readonly property bool available: Hyprland.focusedWorkspace !== null || (Hyprland.workspaces?.values?.length ?? 0) > 0
    readonly property string statusLine: available ? "hyprland: workspace service online" : "hyprland: workspace fallback"
    readonly property var occupiedIds: {
        const values = Hyprland.workspaces?.values || [];
        return values.filter(workspace => workspace.id > 0 && (workspace.lastIpcObject?.windows ?? 0) > 0).map(workspace => workspace.id);
    }

    function isOccupied(id: int): bool {
        return occupiedIds.indexOf(id) >= 0;
    }

    function switchWorkspace(id: int): void {
        if (!available)
            return;
        Hyprland.dispatch(`workspace ${id}`);
    }
}
