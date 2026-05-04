import "../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    property var lines: []

    Layout.fillWidth: true
    spacing: 5

    TacticalLabel {
        Layout.fillWidth: true
        text: root.title
        accent: true
    }

    Repeater {
        model: root.lines

        TerminalLine {
            required property var modelData

            prompt: modelData[0]
            content: modelData[1]
            accent: modelData.length > 2 ? modelData[2] : false
        }

    }

}
