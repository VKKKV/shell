import "../../services"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property string edge
    readonly property int thickness: {
        if (edge === "top")
            return HudMetrics.topReserved;
        if (edge === "bottom")
            return HudMetrics.bottomReserved;
        if (edge === "left")
            return HudMetrics.leftReserved;
        if (edge === "right")
            return HudMetrics.rightReserved;
        return 0;
    }

    color: "transparent"
    implicitWidth: edge === "left" || edge === "right" ? thickness : 1
    implicitHeight: edge === "top" || edge === "bottom" ? thickness : 1
    visible: thickness > 0
    mask: Region {}

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "void-hud-exclusion-" + edge
    WlrLayershell.exclusionMode: thickness > 0 ? ExclusionMode.Auto : ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: edge === "top"
        bottom: edge === "bottom"
        left: edge === "left" || edge === "top" || edge === "bottom"
        right: edge === "right" || edge === "top" || edge === "bottom"
    }
}
