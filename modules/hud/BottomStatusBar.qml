import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    readonly property string fullDateText: "[" + CalendarService.dayText + " // " + CalendarService.dateText + "]"
    readonly property string shortDateText: "[" + CalendarService.dateText + "]"
    readonly property int rowGap: Theme.densitySmallSpacing
    readonly property int nodeReadoutWidth: Math.min(240, Math.max(160, Math.round(width * 0.14)))
    readonly property int missionDockWidth: Math.min(720, Math.max(420, Math.round(width * 0.42)))
    readonly property int channelReadoutWidth: Math.min(328, Math.max(220, Math.round(width * 0.18)))
    readonly property int fixedRowWidth: Theme.panelPadding * 2 + nodeReadoutWidth + missionDockWidth + channelReadoutWidth + rowGap * 5
    readonly property int availableDateWidth: Math.max(shortDateProbe.implicitWidth, width - fixedRowWidth)
    readonly property bool useShortDate: availableDateWidth < fullDateProbe.implicitWidth

    highlighted: true
    implicitHeight: Math.min(Theme.bottomBarMaxHeight, Math.max(Theme.bottomBarMinHeight, content.implicitHeight + 12))

    TacticalLabel {
        id: fullDateProbe

        visible: false
        text: root.fullDateText
        accent: true
        size: Theme.fontNormal
    }

    TacticalLabel {
        id: shortDateProbe

        visible: false
        text: root.shortDateText
        accent: true
        size: Theme.fontNormal
    }

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
            spacing: root.rowGap

            TacticalLabel {
                Layout.preferredWidth: root.nodeReadoutWidth
                Layout.maximumWidth: 240
                text: "VOID-HYPRLAND // NODE_02 // ID: 10.0.0.12"
                dim: true
                elide: Text.ElideRight
            }

            Item {
                Layout.preferredWidth: root.useShortDate ? shortDateProbe.implicitWidth : fullDateProbe.implicitWidth
                Layout.maximumWidth: root.useShortDate ? shortDateProbe.implicitWidth : Math.max(fullDateProbe.implicitWidth, root.availableDateWidth)
                Layout.minimumWidth: shortDateProbe.implicitWidth
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredHeight: dateLabel.implicitHeight

                TacticalLabel {
                    id: dateLabel

                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    horizontalAlignment: Text.AlignLeft
                    text: root.useShortDate ? root.shortDateText : root.fullDateText
                    accent: true
                    size: Theme.fontNormal
                    elide: Text.ElideRight
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: root.useShortDate
                    enabled: root.useShortDate
                    onEntered: TooltipService.show("CALENDAR DATE", root.fullDateText, "bottom-date")
                    onExited: TooltipService.clear("bottom-date")
                }
            }

            Item {
                Layout.fillWidth: true
            }

            MissionDock {
                Layout.preferredWidth: root.missionDockWidth
                Layout.maximumWidth: 760
                Layout.minimumWidth: 360
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.preferredWidth: root.channelReadoutWidth
                Layout.maximumWidth: 328
                spacing: root.rowGap

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
