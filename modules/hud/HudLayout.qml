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
    readonly property int rightWidth: Math.max(Theme.rightPanelMinWidth, Math.min(Theme.rightPanelMaxWidth, Math.max(rightPanel.implicitWidth, Math.round(contentWidth * (compact ? 0.25 : 0.26)))))
    readonly property int topHeight: Math.min(Theme.topBarMaxHeight, Math.max(Theme.topBarMinHeight, topBar.implicitHeight))
    readonly property int bottomHeight: Math.min(Theme.bottomBarMaxHeight, Math.max(Theme.bottomBarMinHeight, bottomBar.implicitHeight))
    readonly property int sideAvailableHeight: Math.max(0, height - topHeight - bottomHeight - Theme.margin * 4)
    readonly property int leftHeight: Math.min(sideAvailableHeight, Math.max(0, leftPanel.implicitHeight))
    readonly property int rightHeight: Math.min(sideAvailableHeight, Math.max(0, rightPanel.implicitHeight))
    readonly property var inputRegions: [topInputRegion, leftInputRegion, rightInputRegion, bottomInputRegion, settingsInputRegion]

    ScanlineOverlay {
        visible: SettingsService.scanlinesEnabled
        anchors.fill: parent
        lineOpacity: 0.025 * SettingsService.intensity
    }

    TopStatusBar {
        id: topBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: Theme.margin
        height: root.topHeight

        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
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
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
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
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }

        Behavior on height {
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
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
            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
        }
    }

    SettingsPanel {
        id: settingsPanel

        anchors.fill: parent
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

    Shortcut {
        sequence: "Ctrl+Alt+S"
        onActivated: SettingsService.togglePanel()
    }

}
