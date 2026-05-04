pragma ComponentBehavior: Bound

import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
    id: root

    readonly property var items: SystemTray.items.values

    spacing: 6

    TacticalLabel {
        text: "TRAY " + root.items.length
        accent: root.items.length > 0
        dim: root.items.length === 0
    }

    Repeater {
        model: root.items

        Rectangle {
            id: trayCell

            required property SystemTrayItem modelData

            width: 22
            height: 18
            color: trayArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            IconImage {
                id: trayIcon

                anchors.centerIn: parent
                width: 14
                height: 14
                source: trayCell.modelData.icon
                visible: status === Image.Ready
            }

            TacticalLabel {
                anchors.centerIn: parent
                visible: !trayIcon.visible
                text: (trayCell.modelData.id || "?").charAt(0).toUpperCase()
                accent: true
            }

            MouseArea {
                id: trayArea

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton)
                        trayCell.modelData.secondaryActivate();
                    else
                        trayCell.modelData.activate();
                }
            }

        }

    }
}
