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

    function activateItem(item: SystemTrayItem): void {
        if (item.onlyMenu && item.hasMenu) {
            item.secondaryActivate();
            return;
        }
        item.activate();
    }

    function openMenu(item: SystemTrayItem): void {
        // Native platform menu display requires a Window, not an Item. Until we own a
        // custom menu surface, use secondary activation like reference shells do.
        if (!item.hasMenu) {
            item.activate();
            return;
        }
        item.secondaryActivate();
    }

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
            border.color: trayCell.modelData.onlyMenu ? Theme.line : (trayCell.modelData.hasMenu ? Theme.lineDim : Theme.border)
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

            Rectangle {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: 5
                height: 5
                visible: trayCell.modelData.hasMenu || trayCell.modelData.onlyMenu
                color: trayCell.modelData.onlyMenu ? Theme.line : Theme.lineDim
            }

            MouseArea {
                id: trayArea

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton)
                        root.openMenu(trayCell.modelData);
                    else
                        root.activateItem(trayCell.modelData);
                }
            }

        }

    }
}
