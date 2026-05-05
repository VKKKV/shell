import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

TacticalFrame {
    id: root

    title: "COMMAND CENTER // TACTICAL CONTROL"
    highlighted: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.panelPadding
        anchors.topMargin: 40
        spacing: 14

        TacticalLabel {
            Layout.fillWidth: true
            text: "CTRL+ALT+S TO TOGGLE PANEL // TYPE TO FILTER ACTIONS/APPS"
            dim: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 34
            color: Theme.panelSoft
            border.color: Theme.lineDim
            border.width: Theme.lineWidth

            TextInput {
                id: searchInput

                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                verticalAlignment: Text.AlignVCenter
                color: Theme.text
                selectionColor: Theme.lineDim
                selectedTextColor: Theme.text
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontNormal
                text: LauncherService.query
                onTextChanged: LauncherService.query = text

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchInput.text.length === 0
                    text: "search apps/actions..."
                    color: Theme.textDim
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSmall
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            CommandCenterOverviewColumn {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Rectangle {
                Layout.preferredWidth: Theme.lineWidth
                Layout.fillHeight: true
                color: Theme.lineDim
            }

            CommandCenterSettingsColumn {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Rectangle {
                Layout.preferredWidth: Theme.lineWidth
                Layout.fillHeight: true
                color: Theme.lineDim
            }

            CommandCenterActionsColumn {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
