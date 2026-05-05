import "../../components"
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
