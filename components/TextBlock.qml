import "../theme"
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    property string title: ""
    property var lines: []

    Layout.fillWidth: true
    spacing: Theme.densitySmallSpacing * 0.5

    TacticalLabel {
        Layout.fillWidth: true
        text: root.title
        accent: true
    }

    Repeater {
        model: root.lines

        TacticalLabel {
            required property string modelData

            Layout.fillWidth: true
            text: modelData
            elide: Text.ElideRight
        }

    }

}
