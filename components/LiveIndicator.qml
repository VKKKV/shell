import "../theme"
import QtQuick

Item {
    id: root

    property string label: ">> LIVE"

    width: content.implicitWidth
    height: content.implicitHeight
    opacity: 0.95

    Row {
        id: content

        anchors.centerIn: parent
        spacing: 6

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
