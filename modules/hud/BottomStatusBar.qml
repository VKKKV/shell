import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    highlighted: true
    implicitHeight: Math.min(Theme.bottomBarMaxHeight, Math.max(Theme.bottomBarMinHeight, content.implicitHeight + Theme.panelPadding))

    RowLayout {
        id: content

        anchors.fill: parent
        anchors.leftMargin: Theme.panelPadding
        anchors.rightMargin: Theme.panelPadding
        anchors.topMargin: 6
        anchors.bottomMargin: 6

        TacticalLabel {
            text: "VOID-HYPRLAND // NODE_02 // ID: 10.0.0.12"
            dim: true
        }

        TacticalLabel {
            Layout.preferredWidth: 220
            horizontalAlignment: Text.AlignLeft
            text: "[" + CalendarService.dayText + " // " + CalendarService.dateText + "]"
            accent: true
            size: Theme.fontNormal
        }

        MissionDock {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
        }

        Row {
            spacing: 12

            TacticalLabel {
                text: "TACTICAL LAYER ONLINE // SECURE CHANNEL ESTABLISHED"
                dim: true
            }

            LiveIndicator {
            }

        }

    }

}
