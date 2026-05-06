import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    spacing: 6

    Repeater {
        model: CompositorService.currentWorkspaceWindows

        Rectangle {
            id: dockItem

            required property var modelData

            readonly property string windowKey: modelData.windowKey || modelData.title

            Layout.preferredWidth: 128
            Layout.preferredHeight: 24
            color: modelData.active ? Theme.lineDim : (dockArea.containsMouse ? Theme.panelSoft : "transparent")
            border.color: modelData.active ? Theme.line : Theme.lineDim
            border.width: Theme.lineWidth

            MouseArea {
                id: dockArea

                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onClicked: CompositorService.focusWindow(dockItem.windowKey)
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 6

                TacticalLabel {
                    text: modelData.appClass.toUpperCase()
                    accent: modelData.active
                    dim: !modelData.active
                }

                TacticalLabel {
                    Layout.fillWidth: true
                    text: modelData.title
                    accent: dockArea.containsMouse || modelData.active
                    elide: Text.ElideRight
                }
            }
        }
    }

    TacticalLabel {
        visible: CompositorService.currentWorkspaceWindows.length === 0
        text: "NO WINDOWS"
        dim: true
    }
}
