import "../theme"
import QtQuick

Row {
    id: root

    property string label: ">> LIVE"

    spacing: 6
    height: childrenRect.height
    width: childrenRect.width
    opacity: 0.95

    Rectangle {
        width: 7
        height: 7
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.line
    }

    TacticalLabel {
        text: root.label
        accent: true
    }

    SequentialAnimation on opacity {
        loops: Animation.Infinite

        NumberAnimation {
            to: 0.42
            duration: 650
        }

        NumberAnimation {
            to: 1
            duration: 650
        }

    }

}
