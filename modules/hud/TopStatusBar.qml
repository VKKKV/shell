import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    property int activeWorkspace: 2

    highlighted: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        spacing: Theme.gap

        Column {
            Layout.preferredWidth: 260
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            TacticalLabel {
                text: Time.timeText
                accent: true
                size: Theme.fontClock
            }

            TacticalLabel {
                text: Time.dateText
                dim: true
            }

        }

        Row {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignCenter
            spacing: 10

            Repeater {
                model: 5

                Rectangle {
                    required property int index
                    readonly property bool active: index + 1 === root.activeWorkspace

                    width: 34
                    height: 24
                    color: active ? Theme.line : "transparent"
                    border.color: Theme.line
                    border.width: Theme.lineWidth

                    TacticalLabel {
                        anchors.centerIn: parent
                        text: index + 1
                        color: parent.active ? Theme.background : Theme.line
                        font.bold: true
                    }

                }

            }

        }

        Column {
            Layout.preferredWidth: 310
            Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
            spacing: 4

            TacticalLabel {
                anchors.right: parent.right
                text: "// SYS.PRTS.V2.0"
                accent: true
                size: Theme.fontNormal
            }

            TacticalLabel {
                anchors.right: parent.right
                text: "HYPRLAND // QML RENDERER"
                dim: true
            }

        }

    }

}
