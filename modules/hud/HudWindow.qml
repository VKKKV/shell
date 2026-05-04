import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: panel

    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "void-hud"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    HudLayout {
        anchors.fill: parent
    }

}
