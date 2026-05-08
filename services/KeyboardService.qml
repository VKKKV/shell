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

    function updateDevices(output: string, backend: string): void {
        if (!SettingsService.liveDataEnabled || deviceBackend !== backend)
            return;

        try {
            const payload = JSON.parse(output);
            const source = backend === "niri" ? (Array.isArray(payload) ? payload : (payload.layouts || payload.keyboards || [])) : (payload.keyboards || []);
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
            statusLine = available ? "keyboard: " + activeLayout + " // " + next.length + " devices // " + backend : "keyboard: no devices // " + backend;
        } catch (error) {
            available = false;
            activeLayout = "UNKNOWN";
            activeKeyboard = "UNKNOWN";
            keyboards = [];
            statusLine = "keyboard: parse fallback // " + backend;
        }
    }

    function stopDeviceProcesses(): void {
        hyprDevicesProcess.running = false;
        niriDevicesProcess.running = false;
    }

    function refresh(): void {
        if (CompositorService.hyprlandActive) {
            deviceBackend = "hyprland";
            niriDevicesProcess.running = false;
            if (!hyprDevicesProcess.running)
                hyprDevicesProcess.running = true;
        } else if (CompositorService.niriActive) {
            deviceBackend = "niri";
            hyprDevicesProcess.running = false;
            if (!niriDevicesProcess.running)
                niriDevicesProcess.running = true;
        } else {
            stopDeviceProcesses();
            deviceBackend = "fallback";
            available = false;
            activeLayout = "UNAVAILABLE";
            activeKeyboard = "UNKNOWN";
            keyboards = [];
            statusLine = "keyboard: compositor fallback";
            return;
        }
    }

    function startPollingIfReady(): void {
        if (SettingsService.loading || !SettingsService.liveDataEnabled)
            return;

        refresh();
        poller.start();
    }

    function stopPolling(): void {
        poller.stop();
        stopDeviceProcesses();
    }

    Component.onCompleted: startPollingIfReady()

    property Timer poller: Timer {
        interval: 10000
        repeat: true
        onTriggered: root.refresh()
    }

    Connections {
        target: SettingsService
        function onLoadingChanged(): void {
            if (SettingsService.loading)
                root.stopPolling();
            else
                root.startPollingIfReady();
        }
        function onLiveDataEnabledChanged(): void {
            if (SettingsService.liveDataEnabled) {
                if (!SettingsService.loading) {
                    root.refresh();
                    root.poller.start();
                }
            } else {
                root.stopPolling();
            }
        }
    }

    property Process hyprDevicesProcess: Process {
        command: ["hyprctl", "devices", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateDevices(text, "hyprland")
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 && root.deviceBackend === "hyprland") {
                root.available = false;
                root.activeLayout = "UNAVAILABLE";
                root.activeKeyboard = "UNKNOWN";
                root.keyboards = [];
                root.statusLine = "keyboard: hyprland fallback";
            }
        }
    }

    property Process niriDevicesProcess: Process {
        command: ["niri", "msg", "keyboard-layouts"]
        stdout: StdioCollector {
            onStreamFinished: root.updateDevices(text, "niri")
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 && root.deviceBackend === "niri") {
                root.available = false;
                root.activeLayout = "UNAVAILABLE";
                root.activeKeyboard = "UNKNOWN";
                root.keyboards = [];
                root.statusLine = "keyboard: niri fallback";
            }
        }
    }
}
