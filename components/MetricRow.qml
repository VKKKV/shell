import "../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string label: ""
    property string value: ""
    property real progress: -1
    property bool accent: false

    Layout.fillWidth: true
    spacing: 8

    TacticalLabel {
        Layout.preferredWidth: 92
        Layout.minimumWidth: 58
        text: root.label
        dim: !root.accent
        accent: root.accent
    }

    ProgressBar {
        visible: root.progress >= 0
        Layout.fillWidth: true
        Layout.preferredHeight: 8
        value: root.progress
    }

    TacticalLabel {
        Layout.fillWidth: root.progress < 0
        Layout.preferredWidth: root.progress >= 0 ? 72 : -1
        Layout.minimumWidth: root.progress >= 0 ? 48 : 0
        horizontalAlignment: root.progress >= 0 ? Text.AlignRight : Text.AlignLeft
        text: root.value
        accent: root.accent
    }

}
