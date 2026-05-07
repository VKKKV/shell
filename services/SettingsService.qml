pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool panelOpen: false
    property bool scanlinesEnabled: true
    property bool liveDataEnabled: true
    property bool leftVisible: true
    property bool centerVisible: true
    property bool rightVisible: true
    property string themeProfile: "amber"
    property string accentColor: "#F2C94C"
    property string backgroundMode: "void"
    property real intensity: 1
    property real fontScale: 1
    property real panelOpacity: 0.8
    property real scanlineStrength: 1
    property real borderOpacity: 1
    property real dimTextOpacity: 1
    property real lineContrast: 1
    property string density: "normal"
    property int updateIntervalMs: 5000
    property string statusLine: "settings: probing helper"
    property string helperPath: "void-shell-settings"
    property string pendingPayload: ""
    property bool loading: true
    property bool applyingSettings: false

    function togglePanel(): void {
        panelOpen = !panelOpen;
    }

    function clampIntensity(value: real): real {
        return Math.max(0.5, Math.min(1.5, value));
    }

    function clampFontScale(value: real): real {
        return Math.max(0.85, Math.min(1.25, value));
    }

    function clampPanelOpacity(value: real): real {
        return Math.max(0.55, Math.min(0.95, value));
    }

    function clampScanlineStrength(value: real): real {
        return Math.max(0.25, Math.min(1.75, value));
    }

    function clampBorderOpacity(value: real): real {
        return Math.max(0.35, Math.min(1, value));
    }

    function clampDimTextOpacity(value: real): real {
        return Math.max(0.45, Math.min(1, value));
    }

    function clampLineContrast(value: real): real {
        return Math.max(0.65, Math.min(1.35, value));
    }

    function clampUpdateInterval(value: int): int {
        return Math.max(1000, Math.min(30000, value));
    }

    function normalizeThemeProfile(value: string): string {
        return ["amber", "green", "blue", "red"].indexOf(value) >= 0 ? value : "amber";
    }

    function normalizeBackgroundMode(value: string): string {
        return ["void", "grid", "radar"].indexOf(value) >= 0 ? value : "void";
    }

    function normalizeDensity(value: string): string {
        return ["compact", "normal", "dense"].indexOf(value) >= 0 ? value : "normal";
    }

    function normalizeAccentColor(value: string): string {
        return /^#[0-9a-fA-F]{6}$/.test(value) ? value.toUpperCase() : "#F2C94C";
    }

    function applySettings(settings: var): void {
        if (!settings || typeof settings !== "object")
            return;

        applyingSettings = true;
        if (settings.visual) {
            if (typeof settings.visual.scanlinesEnabled === "boolean")
                scanlinesEnabled = settings.visual.scanlinesEnabled;
            if (typeof settings.visual.intensity === "number")
                intensity = clampIntensity(settings.visual.intensity);
            if (typeof settings.visual.fontScale === "number")
                fontScale = clampFontScale(settings.visual.fontScale);
            if (typeof settings.visual.panelOpacity === "number")
                panelOpacity = clampPanelOpacity(settings.visual.panelOpacity);
            if (typeof settings.visual.scanlineStrength === "number")
                scanlineStrength = clampScanlineStrength(settings.visual.scanlineStrength);
            if (typeof settings.visual.borderOpacity === "number")
                borderOpacity = clampBorderOpacity(settings.visual.borderOpacity);
            if (typeof settings.visual.dimTextOpacity === "number")
                dimTextOpacity = clampDimTextOpacity(settings.visual.dimTextOpacity);
            if (typeof settings.visual.lineContrast === "number")
                lineContrast = clampLineContrast(settings.visual.lineContrast);
            if (typeof settings.visual.density === "string")
                density = normalizeDensity(settings.visual.density);
            if (typeof settings.visual.profile === "string")
                themeProfile = normalizeThemeProfile(settings.visual.profile);
            if (typeof settings.visual.accentColor === "string")
                accentColor = normalizeAccentColor(settings.visual.accentColor);
            if (typeof settings.visual.backgroundMode === "string")
                backgroundMode = normalizeBackgroundMode(settings.visual.backgroundMode);
        }
        if (settings.data) {
            if (typeof settings.data.liveDataEnabled === "boolean")
                liveDataEnabled = settings.data.liveDataEnabled;
            if (typeof settings.data.updateIntervalMs === "number")
                updateIntervalMs = clampUpdateInterval(settings.data.updateIntervalMs);
        }
        if (settings.panels) {
            if (typeof settings.panels.leftVisible === "boolean")
                leftVisible = settings.panels.leftVisible;
            if (typeof settings.panels.centerVisible === "boolean")
                centerVisible = settings.panels.centerVisible;
            if (typeof settings.panels.rightVisible === "boolean")
                rightVisible = settings.panels.rightVisible;
        }
        applyingSettings = false;
    }

    function settingsPayload(): string {
        return JSON.stringify({
            version: 1,
            visual: {
                scanlinesEnabled: scanlinesEnabled,
                intensity: clampIntensity(intensity),
                fontScale: clampFontScale(fontScale),
                panelOpacity: clampPanelOpacity(panelOpacity),
                scanlineStrength: clampScanlineStrength(scanlineStrength),
                borderOpacity: clampBorderOpacity(borderOpacity),
                dimTextOpacity: clampDimTextOpacity(dimTextOpacity),
                lineContrast: clampLineContrast(lineContrast),
                density: normalizeDensity(density),
                profile: normalizeThemeProfile(themeProfile),
                accentColor: normalizeAccentColor(accentColor),
                backgroundMode: normalizeBackgroundMode(backgroundMode)
            },
            data: {
                liveDataEnabled: liveDataEnabled,
                updateIntervalMs: clampUpdateInterval(updateIntervalMs)
            },
            panels: {
                leftVisible: leftVisible,
                centerVisible: centerVisible,
                rightVisible: rightVisible
            }
        });
    }

    function scheduleSave(): void {
        if (loading || applyingSettings)
            return;
        saveDebounce.restart();
    }

    function saveNow(): void {
        pendingPayload = settingsPayload();
        writeProcess.running = true;
    }

    function updateFromText(text: string): void {
        try {
            applySettings(JSON.parse(text));
            statusLine = "settings: helper sync online";
        } catch (error) {
            statusLine = "settings: helper parse fallback";
        }
    }

    function localHelperPath(): string {
        return decodeURIComponent(Qt.resolvedUrl("../zig-out/bin/void-shell-settings").toString().replace(/^file:\/\//, ""));
    }

    onScanlinesEnabledChanged: scheduleSave()
    onLiveDataEnabledChanged: scheduleSave()
    onLeftVisibleChanged: scheduleSave()
    onCenterVisibleChanged: scheduleSave()
    onRightVisibleChanged: scheduleSave()
    onThemeProfileChanged: {
        const normalized = normalizeThemeProfile(themeProfile);
        if (normalized !== themeProfile) {
            themeProfile = normalized;
            return;
        }
        scheduleSave();
    }
    onAccentColorChanged: {
        const normalized = normalizeAccentColor(accentColor);
        if (normalized !== accentColor) {
            accentColor = normalized;
            return;
        }
        scheduleSave();
    }
    onBackgroundModeChanged: {
        const normalized = normalizeBackgroundMode(backgroundMode);
        if (normalized !== backgroundMode) {
            backgroundMode = normalized;
            return;
        }
        scheduleSave();
    }
    onDensityChanged: {
        const normalized = normalizeDensity(density);
        if (normalized !== density) {
            density = normalized;
            return;
        }
        scheduleSave();
    }
    onIntensityChanged: {
        const clamped = clampIntensity(intensity);
        if (clamped !== intensity) {
            intensity = clamped;
            return;
        }
        scheduleSave();
    }
    onFontScaleChanged: {
        const clamped = clampFontScale(fontScale);
        if (clamped !== fontScale) {
            fontScale = clamped;
            return;
        }
        scheduleSave();
    }
    onPanelOpacityChanged: {
        const clamped = clampPanelOpacity(panelOpacity);
        if (clamped !== panelOpacity) {
            panelOpacity = clamped;
            return;
        }
        scheduleSave();
    }
    onScanlineStrengthChanged: {
        const clamped = clampScanlineStrength(scanlineStrength);
        if (clamped !== scanlineStrength) {
            scanlineStrength = clamped;
            return;
        }
        scheduleSave();
    }
    onBorderOpacityChanged: {
        const clamped = clampBorderOpacity(borderOpacity);
        if (clamped !== borderOpacity) {
            borderOpacity = clamped;
            return;
        }
        scheduleSave();
    }
    onDimTextOpacityChanged: {
        const clamped = clampDimTextOpacity(dimTextOpacity);
        if (clamped !== dimTextOpacity) {
            dimTextOpacity = clamped;
            return;
        }
        scheduleSave();
    }
    onLineContrastChanged: {
        const clamped = clampLineContrast(lineContrast);
        if (clamped !== lineContrast) {
            lineContrast = clamped;
            return;
        }
        scheduleSave();
    }
    onUpdateIntervalMsChanged: {
        const clamped = clampUpdateInterval(updateIntervalMs);
        if (clamped !== updateIntervalMs) {
            updateIntervalMs = clamped;
            return;
        }
        scheduleSave();
    }

    Component.onCompleted: helperProbeProcess.running = true

    property Timer saveDebounce: Timer {
        interval: 300
        repeat: false
        onTriggered: root.saveNow()
    }

    property Process helperProbeProcess: Process {
        command: ["sh", "-c", "if [ -x \"$1\" ]; then printf '%s' \"$1\"; elif command -v void-shell-settings >/dev/null 2>&1; then command -v void-shell-settings; else exit 127; fi", "void-shell-settings-probe", root.localHelperPath()]
        stdout: StdioCollector {
            onStreamFinished: {
                const resolved = text.trim();
                if (resolved.length > 0)
                    root.helperPath = resolved;
            }
        }
        onExited: (exitCode) => {
            if (exitCode === 0)
                root.readProcess.running = true;
            else {
                root.statusLine = "settings: helper unavailable";
                root.loading = false;
            }
        }
    }

    property Process readProcess: Process {
        command: [root.helperPath, "read"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.updateFromText(text);
                root.loading = false;
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.statusLine = "settings: helper read fallback";
                root.loading = false;
            }
        }
    }

    property Process writeProcess: Process {
        command: [root.helperPath, "write", root.pendingPayload]
        stdout: StdioCollector {
            onStreamFinished: root.updateFromText(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.statusLine = "settings: helper write fallback";
        }
    }
}
