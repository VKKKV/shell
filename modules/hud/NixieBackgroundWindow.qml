import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../components"
import "../../services"

PanelWindow {
    id: root

    color: "transparent"
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "void-nixie-bg"

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    NixieWallpaper {
        anchors.fill: parent
        visible: true
    }
}
