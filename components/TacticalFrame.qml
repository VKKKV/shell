import "../theme"
import QtQuick

Rectangle {
    id: root

    property string title: ""
    property bool highlighted: false

    color: Theme.panel
    border.color: highlighted ? Theme.line : Theme.lineDim
    border.width: Theme.lineWidth
    radius: 0
    clip: true

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        width: 26
        height: Theme.heavyLineWidth
        color: Theme.line
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        width: Theme.heavyLineWidth
        height: 26
        color: Theme.line
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 26
        height: Theme.heavyLineWidth
        color: Theme.line
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: Theme.heavyLineWidth
        height: 26
        color: Theme.line
    }

    Text {
        visible: root.title.length > 0
        anchors.left: parent.left
        anchors.leftMargin: Theme.panelPadding
        anchors.top: parent.top
        anchors.topMargin: 7
        text: root.title
        color: Theme.line
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSmall
        font.bold: true
        font.letterSpacing: 1.4
    }

}
