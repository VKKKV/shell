import "../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string text: ""
    property string tag: ""

    Layout.fillWidth: true
    spacing: Theme.densitySmallSpacing

    Rectangle {
        Layout.preferredWidth: 16
        Layout.preferredHeight: Theme.lineWidth
        color: Theme.line
    }

    TacticalLabel {
        text: root.tag.length > 0 ? root.tag + " // " + root.text : root.text
        accent: true
        size: Theme.fontTiny
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: Theme.lineWidth
        color: Theme.lineDim
    }
}
