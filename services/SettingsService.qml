pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool panelOpen: false
    property bool scanlinesEnabled: true
    property bool liveDataEnabled: true
    property real intensity: 1

    function togglePanel(): void {
        panelOpen = !panelOpen;
    }
}
