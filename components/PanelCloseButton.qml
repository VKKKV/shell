import "../theme"
import QtQuick

Rectangle {
    id: root

    signal closeRequested()

    implicitWidth: 86
    implicitHeight: 28
    color: closeArea.containsMouse ? Theme.lineDim : "#33000000"
    border.color: closeArea.containsMouse ? Theme.line : Theme.border
    border.width: Theme.lineWidth

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
        accent: closeArea.containsMouse
        size: Theme.fontTiny
    }
}
