import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    spacing: 6
    clip: true

    Repeater {
        model: CompositorService.currentWorkspaceWindows

        Rectangle {
            id: dockItem

            required property var modelData

            readonly property string windowKey: modelData.windowKey || modelData.title

            Layout.preferredWidth: 176
            Layout.maximumWidth: 220
            Layout.preferredHeight: 28
            clip: true
            color: modelData.active ? Theme.lineDim : (dockArea.containsMouse ? Theme.panelSoft : "transparent")
            border.color: modelData.active ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: dockArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: CompositorService.focusWindow(dockItem.windowKey)
                onEntered: TooltipService.show("FOCUS WINDOW", "Focus " + dockItem.modelData.appClass + " via compositor window key. Target: " + dockItem.modelData.title + ".", "dock-" + dockItem.windowKey)
                onExited: TooltipService.clear("dock-" + dockItem.windowKey)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                TacticalLabel {
                    Layout.maximumWidth: 74
                    text: modelData.appClass.toUpperCase()
                    accent: modelData.active
                    dim: !modelData.active
                    elide: Text.ElideRight
                    clip: true
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.title
                    accent: dockArea.containsMouse || modelData.active
                    elide: Text.ElideRight
                    clip: true
                }
            }
        }
    }

    TacticalLabel {
        visible: CompositorService.currentWorkspaceWindows.length === 0
        Layout.fillWidth: true
        text: "NO WINDOWS"
        dim: true
        elide: Text.ElideRight
    }
}
