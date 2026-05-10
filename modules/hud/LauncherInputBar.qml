import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts

FocusScope {
    id: root

    implicitHeight: 104
    visible: LauncherService.barOpen

    function focusInput(): void {
        input.forceActiveFocus();
        input.cursorPosition = input.text.length;
    }

    onVisibleChanged: {
        if (visible)
            focusInput();
    }

    Connections {
        target: LauncherService

        function onBarOpenChanged(): void {
            if (LauncherService.barOpen)
                root.focusInput();
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.panelSoft
        border.color: root.activeFocus ? Theme.line : Theme.lineDim
        border.width: Theme.lineWidth

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 28
                spacing: 8

                TacticalLabel {
                    text: "LAUNCH //"
                    accent: true
                    size: Theme.fontSmall
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 28
                    color: Theme.panel
                    border.color: Theme.border
                    border.width: Theme.lineWidth

                    TextInput {
                        id: input

                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.text
                        selectionColor: Theme.lineDim
                        selectedTextColor: Theme.text
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontNormal
                        text: LauncherService.query
                        onTextChanged: LauncherService.query = text
                        Keys.onReturnPressed: event => {
                            LauncherService.launchSelected();
                            event.accepted = true;
                        }
                        Keys.onEnterPressed: event => {
                            LauncherService.launchSelected();
                            event.accepted = true;
                        }
                        Keys.onEscapePressed: event => {
                            LauncherService.closeBar();
                            event.accepted = true;
                        }
                        Keys.onUpPressed: event => {
                            LauncherService.moveSelection(-1);
                            event.accepted = true;
                        }
                        Keys.onDownPressed: event => {
                            LauncherService.moveSelection(1);
                            event.accepted = true;
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text.length === 0
                            text: "type app/action, =calc, or $cmd..."
                            color: Theme.textDim
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSmall
                        }
                    }
                }

                TacticalLabel {
                    text: "CTRL+SPACE"
                    dim: true
                    size: Theme.fontTiny
                }
            }

            TacticalLabel {
                Layout.fillWidth: true
                visible: LauncherService.filtered.length === 0
                text: LauncherService.apps.length === 0 ? "NO APP PROVIDERS INDEXED // ACTIONS ONLY FALLBACK UNAVAILABLE" : "NO RESULTS // REFINE QUERY"
                dim: true
                elide: Text.ElideRight
                size: Theme.fontSmall
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: LauncherService.filtered.length > 0
                spacing: 6

                Repeater {
                    model: LauncherService.filtered.slice(0, LauncherService.barResultLimit)

                    Rectangle {
                        required property var modelData
                        required property int index

                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        color: index === LauncherService.selectedIndex ? Theme.lineDim : "transparent"
                        border.color: index === LauncherService.selectedIndex || resultArea.containsMouse ? Theme.line : Theme.border
                        border.width: Theme.lineWidth

                        MouseArea {
                            id: resultArea

                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: LauncherService.selectedIndex = parent.index
                            onClicked: {
                                LauncherService.selectedIndex = parent.index;
                                LauncherService.launchSelected();
                            }
                        }

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 6
                            spacing: 0

                            TacticalLabel {
                                Layout.fillWidth: true
                                text: modelData.type.toUpperCase()
                                accent: index === LauncherService.selectedIndex
                                dim: index !== LauncherService.selectedIndex
                                size: Theme.fontTiny
                                elide: Text.ElideRight
                            }

                            TacticalLabel {
                                Layout.fillWidth: true
                                text: modelData.name
                                accent: index === LauncherService.selectedIndex || resultArea.containsMouse
                                elide: Text.ElideRight
                                size: Theme.fontSmall
                            }
                        }
                    }
                }
            }
        }
    }
}
