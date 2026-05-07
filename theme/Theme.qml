pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import "../services"

QtObject {
    readonly property string profile: SettingsService.themeProfile
    readonly property color background: "#000000"
    readonly property color panel: alphaColor("#030303", SettingsService.panelOpacity)
    readonly property color panelSoft: alphaColor("#080808", Math.max(0.35, SettingsService.panelOpacity * 0.75))
    readonly property color line: contrastAccent(SettingsService.accentColor, SettingsService.lineContrast)
    readonly property color lineDim: dimAccent(SettingsService.accentColor)
    readonly property color text: "#E0E0E0"
    readonly property color textDim: alphaColor("#828282", SettingsService.dimTextOpacity)
    readonly property color border: alphaColor("#333333", SettingsService.borderOpacity)
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
    readonly property real densityScale: SettingsService.density === "compact" ? 0.85 : (SettingsService.density === "dense" ? 1.15 : 1)
    readonly property int densitySpacing: scaledDensity(10)
    readonly property int densitySmallSpacing: scaledDensity(6)
    readonly property int densityControlHeight: scaledDensity(24)
    readonly property int densityRowHeight: scaledDensity(30)
    readonly property int densityCardHeight: scaledDensity(74)
    readonly property int densityGraphHeight: scaledDensity(96)
    readonly property int densityProgressHeight: Math.max(5, scaledDensity(8))
    readonly property int motionResizeMs: 180
    readonly property int motionDeployMs: 230
    readonly property int motionFadeMs: 170
    readonly property real motionCollapsedScale: 0.08

    readonly property string fontFamily: "monospace"
    readonly property int fontTiny: scaledFont(10)
    readonly property int fontSmall: scaledFont(12)
    readonly property int fontNormal: scaledFont(14)
    readonly property int fontLarge: scaledFont(22)
    readonly property int fontClock: scaledFont(34)

    function dimAccent(value: string): string {
        return alphaColor(/^#[0-9a-fA-F]{6}$/.test(value) ? contrastAccent(value, SettingsService.lineContrast) : "#F2C94C", 0.4);
    }

    function scaledFont(value: int): int {
        return Math.max(8, Math.round(value * SettingsService.fontScale));
    }

    function scaledDensity(value: int): int {
        return Math.max(1, Math.round(value * densityScale));
    }

    function alphaColor(rgb: string, opacity: real): string {
        const alpha = Math.max(0, Math.min(255, Math.round(opacity * 255)));
        return "#" + alpha.toString(16).padStart(2, "0") + rgb.slice(1);
    }

    function contrastAccent(value: string, contrast: real): string {
        if (!/^#[0-9a-fA-F]{6}$/.test(value))
            return "#F2C94C";
        const red = contrastChannel(parseInt(value.slice(1, 3), 16), contrast);
        const green = contrastChannel(parseInt(value.slice(3, 5), 16), contrast);
        const blue = contrastChannel(parseInt(value.slice(5, 7), 16), contrast);
        return "#" + red + green + blue;
    }

    function contrastChannel(value: int, contrast: real): string {
        const adjusted = Math.max(0, Math.min(255, Math.round(128 + (value - 128) * contrast)));
        return adjusted.toString(16).padStart(2, "0");
    }
}
