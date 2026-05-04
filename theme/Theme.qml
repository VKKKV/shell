pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    readonly property color background: "#000000"
    readonly property color panel: "#cc030303"
    readonly property color panelSoft: "#99080808"
    readonly property color line: "#ffb900"
    readonly property color lineDim: "#7f6f5200"
    readonly property color text: "#e8e2c8"
    readonly property color textDim: "#8f8a78"
    readonly property color danger: "#ff4d2e"

    readonly property int margin: 18
    readonly property int gap: 12
    readonly property int panelPadding: 14
    readonly property int lineWidth: 1
    readonly property int heavyLineWidth: 2
    readonly property int topBarHeight: 70
    readonly property int bottomBarHeight: 42
    readonly property int sidePanelWidth: 300
    readonly property int rightPanelWidth: 410

    readonly property string fontFamily: "monospace"
    readonly property int fontTiny: 10
    readonly property int fontSmall: 12
    readonly property int fontNormal: 14
    readonly property int fontLarge: 22
    readonly property int fontClock: 34
}
