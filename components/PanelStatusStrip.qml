import "../theme"
import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string leftText: "STATUS // ONLINE"
    property string centerText: "BUS // LIVE"
    property string rightText: "ESC // CLOSE"
    property bool warning: false

    Layout.fillWidth: true
    Layout.preferredHeight: Theme.densityControlHeight
    color: warning ? Theme.lineDim : "#44000000"
    border.color: warning ? Theme.line : Theme.lineDim
    border.width: Theme.lineWidth

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: Theme.densitySmallSpacing

        TacticalLabel {
            Layout.preferredWidth: Math.max(120, parent.width * 0.3)
            text: root.leftText
            accent: true
            elide: Text.ElideRight
        }

        TacticalLabel {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.centerText
            accent: root.warning
            dim: !root.warning
            elide: Text.ElideRight
        }

        TacticalLabel {
            Layout.preferredWidth: Math.max(120, parent.width * 0.3)
            horizontalAlignment: Text.AlignRight
            text: root.rightText
            accent: root.warning
            dim: !root.warning
            elide: Text.ElideRight
        }
    }
}
