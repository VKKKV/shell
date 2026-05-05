pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import "../services"

QtObject {
    readonly property string profile: SettingsService.themeProfile
    readonly property color background: "#000000"
    readonly property color panel: "#cc030303"
    readonly property color panelSoft: "#99080808"
    readonly property color line: profile === "green" ? "#52ff7a" : (profile === "blue" ? "#55b7ff" : (profile === "red" ? "#ff4d2e" : "#ffb900"))
    readonly property color lineDim: profile === "green" ? "#7f1f6f32" : (profile === "blue" ? "#7f1e577f" : (profile === "red" ? "#7f6f1d14" : "#7f6f5200"))
    readonly property color text: profile === "green" ? "#d8ffe0" : (profile === "blue" ? "#d8ecff" : (profile === "red" ? "#ffe0d8" : "#e8e2c8"))
    readonly property color textDim: profile === "green" ? "#82a88a" : (profile === "blue" ? "#8199aa" : (profile === "red" ? "#aa8179" : "#8f8a78"))
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
    readonly property int rightPanelWidth: 410
    readonly property int sidePanelMinWidth: 240
    readonly property int rightPanelMinWidth: 320
    readonly property int sidePanelMaxWidth: 320
    readonly property int rightPanelMaxWidth: 440
    readonly property int compactWidth: 1500

    readonly property string fontFamily: "monospace"
    readonly property int fontTiny: 10
    readonly property int fontSmall: 12
    readonly property int fontNormal: 14
    readonly property int fontLarge: 22
    readonly property int fontClock: 34
}
