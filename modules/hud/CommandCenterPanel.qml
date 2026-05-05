import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

CentralPanelChrome {
    id: root

    title: "COMMAND CENTER // TACTICAL CONTROL"
    headerText: "CTRL+ALT+S TO TOGGLE PANEL // TYPE TO FILTER ACTIONS/APPS"
    commandCenter: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

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

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: overviewColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                CommandCenterOverviewColumn {
                    id: overviewColumn

                    width: parent.width
                }
            }

            Rectangle {
                Layout.preferredWidth: Theme.lineWidth
                Layout.fillHeight: true
                color: Theme.lineDim
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: settingsColumn.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                CommandCenterSettingsColumn {
                    id: settingsColumn

                    width: parent.width
                }
            }

            Rectangle {
                Layout.preferredWidth: Theme.lineWidth
                Layout.fillHeight: true
                color: Theme.lineDim
            }

            Flickable {
                Layout.fillWidth: true
                Layout.fillHeight: true
                contentWidth: width
                contentHeight: actionStack.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                clip: true

                ColumnLayout {
                    id: actionStack

                    width: parent.width
                    spacing: Theme.densitySpacing

                    CommandCenterDiagnosticsColumn {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: Theme.lineWidth
                        color: Theme.lineDim
                    }

                    CommandCenterActionsColumn {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
