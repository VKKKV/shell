import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    property bool compactLine: false

    implicitWidth: 420
    implicitHeight: compactLine ? 38 : 72
    highlighted: TooltipService.active
    title: compactLine ? "HINT BUS" : "TOOLTIP // FIXED HINT BUS"
    opacity: TooltipService.active ? 0.98 : 0.72

    Behavior on opacity {
        NumberAnimation { duration: Theme.motionFadeMs; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        visible: !root.compactLine
        anchors.fill: parent
        anchors.leftMargin: Theme.panelPadding
        anchors.rightMargin: Theme.panelPadding
        anchors.topMargin: 32
        anchors.bottomMargin: 8
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            TacticalLabel {
                text: TooltipService.active ? "[HOVER]" : "[STBY]"
                accent: TooltipService.active
                dim: !TooltipService.active
                size: Theme.fontTiny
            }

            TacticalLabel {
                Layout.fillWidth: true
                text: TooltipService.title
                accent: TooltipService.active
                elide: Text.ElideRight
            }
        }

        TacticalLabel {
            Layout.fillWidth: true
            text: TooltipService.detail
            dim: !TooltipService.active
            size: Theme.fontTiny
            elide: Text.ElideRight
        }
    }

    RowLayout {
        visible: root.compactLine
        anchors.fill: parent
        anchors.leftMargin: Theme.panelPadding
        anchors.rightMargin: Theme.panelPadding
        anchors.topMargin: 10
        anchors.bottomMargin: 6
        spacing: 8

        TacticalLabel {
            text: TooltipService.active ? "[HOVER]" : "[STBY]"
            accent: TooltipService.active
            dim: !TooltipService.active
            size: Theme.fontTiny
        }

        TacticalLabel {
            Layout.preferredWidth: 160
            text: TooltipService.title
            accent: TooltipService.active
            elide: Text.ElideRight
        }

        TacticalLabel {
            Layout.fillWidth: true
            text: TooltipService.detail
            dim: !TooltipService.active
            size: Theme.fontTiny
            elide: Text.ElideRight
        }
    }
}
