pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell

Singleton {
    id: root

    property string activeSurface: ""
    readonly property bool open: activeSurface.length > 0
    readonly property string statusLine: open ? "expansion: " + activeSurface : "expansion: standby"

    function show(surface: string): void {
        activeSurface = surface;
    }

    function close(): void {
        activeSurface = "";
    }
}
