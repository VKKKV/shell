import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    highlighted: true
    implicitHeight: Math.min(Theme.bottomBarMaxHeight, Math.max(Theme.bottomBarMinHeight, content.implicitHeight + 12))

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.leftMargin: Theme.panelPadding
        anchors.rightMargin: Theme.panelPadding
        anchors.topMargin: 6
        anchors.bottomMargin: 6
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TacticalLabel {
                Layout.maximumWidth: 240
                text: "VOID-HYPRLAND // NODE_02 // ID: 10.0.0.12"
                dim: true
                elide: Text.ElideRight
            }

            TacticalLabel {
                Layout.preferredWidth: 184
                Layout.maximumWidth: 184
                horizontalAlignment: Text.AlignLeft
                text: "[" + CalendarService.dayText + " // " + CalendarService.dateText + "]"
                accent: true
                size: Theme.fontNormal
                elide: Text.ElideRight
            }

            MissionDock {
                Layout.preferredWidth: 720
                Layout.maximumWidth: 760
                Layout.minimumWidth: 360
                Layout.alignment: Qt.AlignVCenter
            }

            RowLayout {
                Layout.preferredWidth: 328
                Layout.maximumWidth: 328
                spacing: 8

                TacticalLabel {
                    Layout.fillWidth: true
                    text: "TACTICAL LAYER ONLINE // SECURE CHANNEL ESTABLISHED"
                    dim: true
                    elide: Text.ElideRight
                }

                LiveIndicator {
                    Layout.alignment: Qt.AlignVCenter
                }

            }
        }

        HudTooltipBox {
            Layout.fillWidth: true
            Layout.maximumWidth: 760
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredHeight: implicitHeight
            compactLine: true
        }

    }

}
