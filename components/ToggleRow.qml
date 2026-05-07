import "../services"
import "../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string label: ""
    property bool checked: false
    property string tooltip: "Toggle this shell setting."

    signal toggled(bool checked)

    Layout.fillWidth: true
    activeFocusOnTab: true
    spacing: 10
    Keys.onReturnPressed: toggled(!checked)
    Keys.onEnterPressed: toggled(!checked)
    Keys.onSpacePressed: toggled(!checked)

    TacticalLabel {
        Layout.fillWidth: true
        text: root.label
        dim: !root.checked
    }

    Rectangle {
        width: 42
        height: 20
        color: root.checked ? Theme.panelSoft : "transparent"
        border.color: root.checked || root.activeFocus ? Theme.line : Theme.lineDim
        border.width: Theme.lineWidth

        Rectangle {
            width: 14
            height: 14
            anchors.verticalCenter: parent.verticalCenter
            x: root.checked ? parent.width - width - 3 : 3
            color: root.checked ? Theme.line : Theme.textDim
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: TooltipService.show(root.label, root.tooltip, "toggle-" + root.label)
            onExited: TooltipService.clear("toggle-" + root.label)
            onClicked: root.toggled(!root.checked)
        }

    }

}
