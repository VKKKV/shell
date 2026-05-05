pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import "../services"

QtObject {
    readonly property string profile: SettingsService.themeProfile
    readonly property color background: "#000000"
    readonly property color panel: "#cc030303"
    readonly property color panelSoft: "#99080808"
    readonly property color line: SettingsService.accentColor
    readonly property color lineDim: dimAccent(SettingsService.accentColor)
    readonly property color text: "#E0E0E0"
    readonly property color textDim: "#828282"
    readonly property color border: "#333333"
    readonly property color terminalGreen: "#96BF48"
    readonly property color danger: "#ff4d2e"

    readonly property int margin: 18
    readonly property int gap: 12
    readonly property int panelPadding: 14
    readonly property int lineWidth: 1
    readonly property int heavyLineWidth: 2
    readonly property int topBarMinHeight: 70
    readonly property int topBarMaxHeight: 180
    readonly property int bottomBarMinHeight: 42
    readonly property int bottomBarMaxHeight: 96
    readonly property int sidePanelMaxHeight: 760
    readonly property int sidePanelWidth: 300
    readonly property int rightPanelWidth: 460
    readonly property int sidePanelMinWidth: 240
    readonly property int rightPanelMinWidth: 320
    readonly property int sidePanelMaxWidth: 320
    readonly property int rightPanelMaxWidth: 560
    readonly property int compactWidth: 1500

    readonly property string fontFamily: "monospace"
    readonly property int fontTiny: scaledFont(10)
    readonly property int fontSmall: scaledFont(12)
    readonly property int fontNormal: scaledFont(14)
    readonly property int fontLarge: scaledFont(22)
    readonly property int fontClock: scaledFont(34)

    function dimAccent(value: string): string {
        return /^#[0-9a-fA-F]{6}$/.test(value) ? "#66" + value.slice(1) : "#66F2C94C";
    }

    function scaledFont(value: int): int {
        return Math.max(8, Math.round(value * SettingsService.fontScale));
    }
}
