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
    property real intensity: 1
    property int updateIntervalMs: 5000
    property string statusLine: "settings: defaults active"
    property string helperPath: "./zig-out/bin/void-shell-settings"
    property string pendingPayload: ""
    property bool loading: true
    property bool applyingSettings: false

    function togglePanel(): void {
        panelOpen = !panelOpen;
    }

    function clampIntensity(value: real): real {
        return Math.max(0.5, Math.min(1.5, value));
    }

    function clampUpdateInterval(value: int): int {
        return Math.max(1000, Math.min(30000, value));
    }

    function normalizeThemeProfile(value: string): string {
        return ["amber", "green", "blue", "red"].indexOf(value) >= 0 ? value : "amber";
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
            if (typeof settings.visual.profile === "string")
                themeProfile = normalizeThemeProfile(settings.visual.profile);
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
                profile: normalizeThemeProfile(themeProfile)
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
    onIntensityChanged: {
        const clamped = clampIntensity(intensity);
        if (clamped !== intensity) {
            intensity = clamped;
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

    Component.onCompleted: readProcess.running = true

    property Timer saveDebounce: Timer {
        interval: 300
        repeat: false
        onTriggered: root.saveNow()
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
