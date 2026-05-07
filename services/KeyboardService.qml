pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string activeLayout: "UNKNOWN"
    property string activeKeyboard: "UNKNOWN"
    property var keyboards: []
    property bool available: false
    property string statusLine: "keyboard: initializing"
    property string deviceBackend: "none"

    function normalizeLayout(value: string): string {
        const text = value.trim();
        return text.length > 0 ? text.toUpperCase() : "UNKNOWN";
    }

    function updateDevices(output: string): void {
        try {
            const payload = JSON.parse(output);
            const source = deviceBackend === "niri" ? (Array.isArray(payload) ? payload : (payload.layouts || payload.keyboards || [])) : (payload.keyboards || []);
            const next = [];
            let active = null;

            for (const keyboard of source) {
                const name = keyboard.name || keyboard.display_name || keyboard.short_name || "unknown keyboard";
                const layout = normalizeLayout(keyboard.active_keymap || keyboard.layout || keyboard.name || "");
                const main = keyboard.main === true || keyboard.is_active === true || keyboard.active === true;
                const entry = {
                    name,
                    layout,
                    main
                };
                next.push(entry);
                if (!active || main)
                    active = entry;
            }

            keyboards = next;
            available = next.length > 0;
            activeKeyboard = active ? active.name : "UNKNOWN";
            activeLayout = active ? active.layout : "UNKNOWN";
            statusLine = available ? "keyboard: " + activeLayout + " // " + next.length + " devices // " + deviceBackend : "keyboard: no devices // " + deviceBackend;
        } catch (error) {
            available = false;
            activeLayout = "UNKNOWN";
            activeKeyboard = "UNKNOWN";
            keyboards = [];
            statusLine = "keyboard: parse fallback // " + deviceBackend;
        }
    }

    function refresh(): void {
        if (CompositorService.hyprlandActive) {
            deviceBackend = "hyprland";
            devicesProcess.command = ["hyprctl", "devices", "-j"];
        } else if (CompositorService.niriActive) {
            deviceBackend = "niri";
            devicesProcess.command = ["niri", "msg", "keyboard-layouts"];
        } else {
            deviceBackend = "fallback";
            available = false;
            activeLayout = "UNAVAILABLE";
            activeKeyboard = "UNKNOWN";
            keyboards = [];
            statusLine = "keyboard: compositor fallback";
            return;
        }
        devicesProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Timer poller: Timer {
        interval: 10000
        repeat: true
        running: SettingsService.liveDataEnabled
        onTriggered: root.refresh()
    }

    Connections {
        target: SettingsService
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                root.refresh();
                root.poller.restart();
            }
        }
    }

    property Process devicesProcess: Process {
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateDevices(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.available = false;
                root.activeLayout = "UNAVAILABLE";
                root.activeKeyboard = "UNKNOWN";
                root.keyboards = [];
                root.statusLine = "keyboard: hyprctl fallback";
            }
        }
    }
}
