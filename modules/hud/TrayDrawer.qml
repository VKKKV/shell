pragma ComponentBehavior: Bound

import "../../components"
import "../../services"
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
        if (!item.hasMenu) {
            item.activate();
            return;
        }
        item.secondaryActivate();
    }

    function affordanceText(item: SystemTrayItem): string {
        if (item.onlyMenu)
            return "ONLY";
        if (item.hasMenu)
            return "MENU";
        return "ACT";
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
        lines: ["no registered tray clients", "waiting for background apps", "left: activate // right: menu when advertised"]
    }

    TextBlock {
        visible: root.items.length > 0
        title: "TRAY PROTOCOL"
        lines: ["MENU: right click sends secondary activation", "ONLY: item primarily exposes a menu", "ACT: no menu advertised; right click falls back to activate", "native menu styling is delegated to platform bridge"]
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
                onEntered: TooltipService.show("TRAY ITEM", "Left click activates " + (trayEntry.modelData.title || trayEntry.modelData.id || "tray item") + "; right click uses menu fallback: " + root.affordanceText(trayEntry.modelData) + ".", "tray-drawer-" + (trayEntry.modelData.id || trayEntry.modelData.title))
                onExited: TooltipService.clear("tray-drawer-" + (trayEntry.modelData.id || trayEntry.modelData.title))
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
                    border.color: trayEntry.modelData.onlyMenu ? Theme.line : (trayEntry.modelData.hasMenu ? Theme.lineDim : Theme.border)
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
                    text: root.affordanceText(trayEntry.modelData)
                    accent: trayEntry.modelData.hasMenu || trayEntry.modelData.onlyMenu
                    dim: !trayEntry.modelData.hasMenu && !trayEntry.modelData.onlyMenu
                }
            }
        }
    }
}
