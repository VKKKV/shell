import "../../services"
import "../../theme"
import QtQuick

Item {
    id: root

    property int panelX: Theme.margin
    property int panelY: Theme.margin
    property int panelWidth: Math.max(320, width - Theme.margin * 2)
    property int panelHeight: Math.max(260, height - Theme.margin * 2)

    visible: SettingsService.panelOpen
    opacity: visible ? 1 : 0

    Rectangle {
        anchors.fill: parent
        color: "#99000000"
    }

    CommandCenterPanel {
        x: root.panelX
        y: root.panelY
        width: root.panelWidth
        height: root.panelHeight
    }
}
