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
    spacing: Theme.densitySmallSpacing

    TacticalLabel {
        Layout.preferredWidth: 84
        Layout.minimumWidth: 52
        text: root.label
        dim: !root.accent
        accent: root.accent
        elide: Text.ElideRight
    }

    ProgressBar {
        visible: root.progress >= 0
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.densityProgressHeight
        value: root.progress
    }

    TacticalLabel {
        Layout.fillWidth: root.progress < 0
        Layout.preferredWidth: root.progress >= 0 ? 86 : -1
        Layout.minimumWidth: root.progress >= 0 ? 58 : 0
        horizontalAlignment: root.progress >= 0 ? Text.AlignRight : Text.AlignLeft
        text: root.value
        accent: root.accent
        elide: Text.ElideRight
    }

}
