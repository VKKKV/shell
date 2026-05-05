pragma ComponentBehavior: Bound

import "../../components"
import "../../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets

ColumnLayout {
    id: root

    readonly property var items: SystemTray.items.values

    spacing: 8

    function activateItem(item: SystemTrayItem): void {
        if (item.onlyMenu && item.hasMenu) {
            item.secondaryActivate();
            return;
        }
        item.activate();
    }

    function openMenu(item: SystemTrayItem): void {
        // Avoid PlatformMenuEntry.display() until a Window-backed/custom menu surface exists.
        item.secondaryActivate();
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: "TRAY DRAWER // " + root.items.length + " ITEMS"
        accent: root.items.length > 0
        dim: root.items.length === 0
    }

    TextBlock {
        visible: root.items.length === 0
        title: "STATUS NOTIFIER"
        lines: ["no registered tray clients", "waiting for background apps", "left: activate // right: native menu"]
    }

    TextBlock {
        visible: root.items.length > 0
        title: "TRAY PROTOCOL"
        lines: ["left click activates item", "right click opens native menu when exposed", "menu styling is delegated to platform bridge"]
    }

    Repeater {
        model: root.items

        Rectangle {
            id: trayEntry

            required property SystemTrayItem modelData

            Layout.fillWidth: true
            Layout.preferredHeight: 34
            color: entryArea.containsMouse ? Theme.panelSoft : "transparent"
            border.color: entryArea.containsMouse ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: entryArea

                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: (mouse) => {
                    if (mouse.button === Qt.RightButton)
                        root.openMenu(trayEntry.modelData);
                    else
                        root.activateItem(trayEntry.modelData);
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 8

                Rectangle {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    color: "transparent"
                    border.color: Theme.lineDim
                    border.width: Theme.lineWidth

                    IconImage {
                        id: trayIcon

                        anchors.centerIn: parent
                        width: 16
                        height: 16
                        source: trayEntry.modelData.icon
                        visible: status === Image.Ready
                    }

                    TacticalLabel {
                        anchors.centerIn: parent
                        visible: !trayIcon.visible
                        text: (trayEntry.modelData.id || "?").charAt(0).toUpperCase()
                        accent: true
                    }
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    text: trayEntry.modelData.title || trayEntry.modelData.id || "UNKNOWN TRAY ITEM"
                    accent: entryArea.containsMouse
                }

                TacticalLabel {
                    text: trayEntry.modelData.hasMenu ? "MENU" : "L/R"
                    accent: trayEntry.modelData.hasMenu
                    dim: !trayEntry.modelData.hasMenu
                }
            }
        }
    }
}
