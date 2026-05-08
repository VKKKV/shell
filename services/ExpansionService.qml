pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell

Singleton {
    id: root

    property string activeSurface: ""
    property string origin: "center"
    readonly property bool open: activeSurface.length > 0
    readonly property string statusLine: open ? "expansion: " + activeSurface : "expansion: standby"

    function validSurface(surface: string): bool {
        return ["orbital", "media", "earth", "agent", "cpu", "network", "power", "filesystem", "logs"].indexOf(surface) >= 0;
    }

    function show(surface: string, source: string): void {
        if (!validSurface(surface))
            return;
        origin = source.length > 0 ? source : "center";
        activeSurface = surface;
    }

    function close(): void {
        activeSurface = "";
    }
}
