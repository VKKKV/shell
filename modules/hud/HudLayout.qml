import "../../components"
import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    readonly property bool compact: width > 0 && width < Theme.compactWidth
    readonly property int contentWidth: Math.max(0, width - Theme.margin * 2)
    readonly property int sideWidth: Math.max(Theme.sidePanelMinWidth, Math.min(Theme.sidePanelMaxWidth, Math.max(leftPanel.implicitWidth, Math.round(contentWidth * (compact ? 0.18 : 0.19)))))
    readonly property int rightWidth: Math.max(Theme.rightPanelMinWidth, Math.min(Theme.rightPanelMaxWidth, Math.max(rightPanel.implicitWidth, Math.round(contentWidth * (compact ? 0.29 : 0.3)))))
    readonly property int topHeight: Math.min(Theme.topBarMaxHeight, Math.max(Theme.topBarMinHeight, topBar.implicitHeight))
    readonly property int bottomHeight: Math.min(Theme.bottomBarMaxHeight, Math.max(Theme.bottomBarMinHeight, bottomBar.implicitHeight))
    readonly property int sideAvailableHeight: Math.max(0, height - topHeight - bottomHeight - Theme.margin * 4)
    readonly property int leftHeight: Math.min(sideAvailableHeight, Math.max(0, leftPanel.implicitHeight))
    readonly property int rightHeight: Math.min(sideAvailableHeight, Math.max(0, rightPanel.implicitHeight))
    readonly property int topReserved: topBar.height + Theme.margin * 2
    readonly property int bottomReserved: bottomBar.height + Theme.margin * 2
    readonly property int leftReserved: leftPanel.visible ? leftPanel.width + Theme.margin * 2 : 0
    readonly property int rightReserved: rightPanel.visible ? rightPanel.width + Theme.margin * 2 : 0
    readonly property int centerSafeWidth: Math.max(320, width - leftReserved - rightReserved - Theme.margin * 2)
    readonly property int centerSafeHeight: Math.max(260, height - topReserved - bottomReserved - Theme.margin * 2)
    readonly property int expansionWidth: Math.max(320, centerSafeWidth)
    readonly property int expansionHeight: Math.max(260, centerSafeHeight)
    readonly property int expansionTargetX: leftReserved + Math.max(0, width - leftReserved - rightReserved - expansionWidth) / 2
    readonly property int expansionTargetY: topReserved + Math.max(0, height - topReserved - bottomReserved - expansionHeight) / 2
    readonly property int orbitalOriginX: leftPanel.x + leftPanel.width * 0.5
    readonly property int orbitalOriginY: leftPanel.y + Math.min(260, leftPanel.height * 0.42) * 0.5 + 38
    readonly property int mediaOriginX: leftPanel.x + leftPanel.width * 0.5
    readonly property int mediaOriginY: leftPanel.y + Math.min(leftPanel.height - 30, 560)
    readonly property int cpuOriginX: rightPanel.x + rightPanel.width * 0.5
    readonly property int cpuOriginY: rightPanel.y + 90
    readonly property int networkOriginX: rightPanel.x + rightPanel.width * 0.5
    readonly property int networkOriginY: rightPanel.y + Math.min(rightPanel.height - 80, 360)
    readonly property int powerOriginX: rightPanel.x + rightPanel.width * 0.5
    readonly property int powerOriginY: rightPanel.y + 170
    readonly property int filesystemOriginX: rightPanel.x + rightPanel.width * 0.5
    readonly property int filesystemOriginY: rightPanel.y + Math.min(rightPanel.height - 50, 470)
    readonly property int logOriginX: rightPanel.x + rightPanel.width * 0.5
    readonly property int logOriginY: rightPanel.y + Math.min(rightPanel.height - 30, 600)
    readonly property var inputRegions: [topInputRegion, leftInputRegion, rightInputRegion, bottomInputRegion, settingsInputRegion, expansionInputRegion, toastInputRegion]

    function syncMetrics(): void {
        HudMetrics.topReserved = topReserved;
        HudMetrics.bottomReserved = bottomReserved;
        HudMetrics.leftReserved = leftReserved;
        HudMetrics.rightReserved = rightReserved;
    }

    Component.onCompleted: syncMetrics()
    onTopReservedChanged: syncMetrics()
    onBottomReservedChanged: syncMetrics()
    onLeftReservedChanged: syncMetrics()
    onRightReservedChanged: syncMetrics()

    ScanlineOverlay {
        visible: SettingsService.scanlinesEnabled
        anchors.fill: parent
        lineOpacity: 0.025 * SettingsService.intensity * SettingsService.scanlineStrength
    }

    Rectangle {
        visible: SettingsService.backgroundMode !== "void"
        anchors.fill: parent
        color: SettingsService.backgroundMode === "radar" ? "#11000000" : "transparent"
        opacity: 0.18 * SettingsService.intensity
    }

    GridLayout {
        visible: SettingsService.backgroundMode === "grid"
        anchors.fill: parent
        anchors.margins: Theme.margin
        columns: 12
        rowSpacing: 0
        columnSpacing: 0
        opacity: 0.14 * SettingsService.intensity

        Repeater {
            model: 96

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                border.color: Theme.lineDim
                border.width: Theme.lineWidth
            }
        }
    }

    Item {
        visible: SettingsService.backgroundMode === "radar"
        anchors.fill: parent
        opacity: 0.22 * SettingsService.intensity

        Repeater {
            model: 5

            Rectangle {
                required property int index

                anchors.centerIn: parent
                width: Math.min(parent.width, parent.height) * (0.18 + index * 0.13)
                height: width
                radius: width / 2
                color: "transparent"
                border.color: Theme.lineDim
                border.width: Theme.lineWidth
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.78
            height: Theme.lineWidth
            color: Theme.lineDim
            rotation: 28
        }
    }

    TopStatusBar {
        id: topBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.margin
        height: root.topHeight

        Behavior on height {
            NumberAnimation { duration: Theme.motionResizeMs; easing.type: Easing.OutCubic }
        }
    }

    LeftTacticalPanel {
        id: leftPanel

        visible: SettingsService.leftVisible
        width: root.sideWidth
        height: root.leftHeight
        anchors.left: parent.left
        anchors.top: topBar.bottom
        anchors.margins: Theme.margin

        Behavior on width {
            NumberAnimation { duration: Theme.motionResizeMs; easing.type: Easing.OutCubic }
        }

        Behavior on height {
            NumberAnimation { duration: Theme.motionResizeMs; easing.type: Easing.OutCubic }
        }
    }

    RightMonitorPanel {
        id: rightPanel

        visible: SettingsService.rightVisible
        width: root.rightWidth
        height: root.rightHeight
        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.margins: Theme.margin

        Behavior on width {
            NumberAnimation { duration: Theme.motionResizeMs; easing.type: Easing.OutCubic }
        }

        Behavior on height {
            NumberAnimation { duration: Theme.motionResizeMs; easing.type: Easing.OutCubic }
        }
    }

    BottomStatusBar {
        id: bottomBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: Theme.margin
        height: root.bottomHeight

        Behavior on height {
            NumberAnimation { duration: Theme.motionResizeMs; easing.type: Easing.OutCubic }
        }
    }

    SettingsPanel {
        id: settingsPanel

        anchors.fill: parent
        panelX: root.expansionTargetX
        panelY: root.expansionTargetY
        panelWidth: root.expansionWidth
        panelHeight: root.expansionHeight
    }

    Item {
        id: expansionLayer

        visible: ExpansionService.open
        opacity: visible ? 1 : 0
        anchors.fill: parent

        Behavior on opacity {
            NumberAnimation { duration: Theme.motionFadeMs; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.fill: parent
            color: "#66000000"

            MouseArea {
                anchors.fill: parent
                onClicked: ExpansionService.close()
            }
        }

        ExpansionPanelSlot {
            active: ExpansionService.activeSurface === "orbital"
            width: root.expansionWidth
            height: root.expansionHeight
            targetX: root.expansionTargetX
            targetY: root.expansionTargetY
            originX: root.orbitalOriginX
            originY: root.orbitalOriginY

            OrbitalExpansionPanel {
                anchors.fill: parent
            }
        }

        ExpansionPanelSlot {
            active: ExpansionService.activeSurface === "media"
            width: root.expansionWidth
            height: root.expansionHeight
            targetX: root.expansionTargetX
            targetY: root.expansionTargetY
            originX: root.mediaOriginX
            originY: root.mediaOriginY

            MediaExpansionPanel {
                anchors.fill: parent
            }
        }

        ExpansionPanelSlot {
            active: ExpansionService.activeSurface === "cpu"
            width: root.expansionWidth
            height: root.expansionHeight
            targetX: root.expansionTargetX
            targetY: root.expansionTargetY
            originX: root.cpuOriginX
            originY: root.cpuOriginY

            CpuExpansionPanel {
                anchors.fill: parent
            }
        }

        ExpansionPanelSlot {
            active: ExpansionService.activeSurface === "network"
            width: root.expansionWidth
            height: root.expansionHeight
            targetX: root.expansionTargetX
            targetY: root.expansionTargetY
            originX: root.networkOriginX
            originY: root.networkOriginY

            NetworkExpansionPanel {
                anchors.fill: parent
            }
        }

        ExpansionPanelSlot {
            active: ExpansionService.activeSurface === "power"
            width: root.expansionWidth
            height: root.expansionHeight
            targetX: root.expansionTargetX
            targetY: root.expansionTargetY
            originX: root.powerOriginX
            originY: root.powerOriginY

            PowerExpansionPanel {
                anchors.fill: parent
            }
        }

        ExpansionPanelSlot {
            active: ExpansionService.activeSurface === "filesystem"
            width: root.expansionWidth
            height: root.expansionHeight
            targetX: root.expansionTargetX
            targetY: root.expansionTargetY
            originX: root.filesystemOriginX
            originY: root.filesystemOriginY

            FilesystemExpansionPanel {
                anchors.fill: parent
            }
        }

        ExpansionPanelSlot {
            active: ExpansionService.activeSurface === "logs"
            width: root.expansionWidth
            height: root.expansionHeight
            targetX: root.expansionTargetX
            targetY: root.expansionTargetY
            originX: root.logOriginX
            originY: root.logOriginY

            LogExpansionPanel {
                anchors.fill: parent
            }
        }
    }

    NotificationToast {
        id: notificationToast

        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.rightMargin: Theme.margin
        anchors.topMargin: Theme.gap
    }

    Region {
        id: topInputRegion

        x: topBar.x
        y: topBar.y
        width: topBar.width
        height: topBar.height
        intersection: Intersection.Subtract
    }

    Region {
        id: leftInputRegion

        x: leftPanel.x
        y: leftPanel.y
        width: leftPanel.visible ? leftPanel.width : 0
        height: leftPanel.visible ? leftPanel.height : 0
        intersection: Intersection.Subtract
    }

    Region {
        id: rightInputRegion

        x: rightPanel.x
        y: rightPanel.y
        width: rightPanel.visible ? rightPanel.width : 0
        height: rightPanel.visible ? rightPanel.height : 0
        intersection: Intersection.Subtract
    }

    Region {
        id: bottomInputRegion

        x: bottomBar.x
        y: bottomBar.y
        width: bottomBar.width
        height: bottomBar.height
        intersection: Intersection.Subtract
    }

    Region {
        id: settingsInputRegion

        x: 0
        y: 0
        width: settingsPanel.visible ? root.width : 0
        height: settingsPanel.visible ? root.height : 0
        intersection: Intersection.Subtract
    }

    Region {
        id: expansionInputRegion

        x: 0
        y: 0
        width: expansionLayer.visible ? root.width : 0
        height: expansionLayer.visible ? root.height : 0
        intersection: Intersection.Subtract
    }

    Region {
        id: toastInputRegion

        x: notificationToast.x
        y: notificationToast.y
        width: notificationToast.visible ? notificationToast.width : 0
        height: notificationToast.visible ? notificationToast.height : 0
        intersection: Intersection.Subtract
    }

    Shortcut {
        sequence: "Ctrl+Alt+S"
        onActivated: SettingsService.togglePanel()
    }

    Shortcut {
        sequence: "Escape"
        enabled: SettingsService.panelOpen || ExpansionService.open
        onActivated: {
            if (ExpansionService.open)
                ExpansionService.close();
            else
                SettingsService.panelOpen = false;
        }
    }

}
