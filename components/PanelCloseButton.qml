import "../theme"
import QtQuick

Rectangle {
    id: root

    signal closeRequested()

    implicitWidth: 86
    implicitHeight: 28
    activeFocusOnTab: true
    color: closeArea.containsMouse || activeFocus ? Theme.lineDim : "#33000000"
    border.color: closeArea.containsMouse || activeFocus ? Theme.line : Theme.border
    border.width: Theme.lineWidth
    Keys.onReturnPressed: closeRequested()
    Keys.onEnterPressed: closeRequested()
    Keys.onSpacePressed: closeRequested()

    MouseArea {
        id: closeArea

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onClicked: root.closeRequested()
    }

    TacticalLabel {
        anchors.centerIn: parent
        text: "CLOSE"
        accent: closeArea.containsMouse || root.activeFocus
        size: Theme.fontTiny
    }
}
