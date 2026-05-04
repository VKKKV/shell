import "../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string prompt: ""
    property string content: ""
    property bool accent: false

    Layout.fillWidth: true
    spacing: 8

    TacticalLabel {
        visible: root.prompt.length > 0
        text: root.prompt
        accent: true
    }

    TacticalLabel {
        Layout.fillWidth: true
        text: root.content
        accent: root.accent
        elide: Text.ElideRight
    }

}
