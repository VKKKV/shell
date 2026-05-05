pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell

Singleton {
    id: root

    property string activeSurface: ""
    property string origin: "center"
    readonly property bool open: activeSurface.length > 0
    readonly property string statusLine: open ? "expansion: " + activeSurface : "expansion: standby"

    function show(surface: string, source: string): void {
        origin = source.length > 0 ? source : "center";
        activeSurface = surface;
    }

    function close(): void {
        activeSurface = "";
    }
}
