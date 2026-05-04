import "../../components"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    highlighted: true

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.panelPadding
        anchors.rightMargin: Theme.panelPadding

        TacticalLabel {
            text: "PRTS-HYPRLAND // NODE_02 // ID: 10.0.0.12"
            dim: true
        }

        TacticalLabel {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: "[ROOT_ACCESS_GRANTED]"
            accent: true
            size: Theme.fontNormal
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
