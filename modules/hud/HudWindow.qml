import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: panel

    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "void-hud"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    HudLayout {
        id: layout

        anchors.fill: parent
    }

    mask: Region {
        x: 0
        y: 0
        width: panel.width
        height: panel.height
        intersection: Intersection.Xor
        regions: layout.inputRegions
    }

}
