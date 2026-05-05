import "../../services"
import "../../theme"
import QtQuick

Item {
    id: root

    visible: SettingsService.panelOpen
    opacity: visible ? 1 : 0

    Rectangle {
        anchors.fill: parent
        color: "#99000000"
    }

    CommandCenterPanel {
        width: Math.min(920, parent.width - Theme.margin * 2)
        height: Math.min(620, parent.height - Theme.margin * 2)
        anchors.centerIn: parent
    }
}
