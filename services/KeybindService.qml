pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var keybinds: []
    property bool available: false
    property string statusLine: "keybinds: initializing"
    property bool recording: false
    property string recordedCombo: ""
    property string recordStatusLine: "recorder: standby"
    property string pendingCopyText: ""
    property string bindBackend: "none"

    function startRecording(): void {
        recording = true;
        recordedCombo = "";
        recordStatusLine = "recorder: armed, press key chord";
    }

    function cancelRecording(): void {
        recording = false;
        recordStatusLine = recordedCombo.length > 0 ? "recorder: captured " + recordedCombo : "recorder: standby";
    }

    function formatEvent(event: var): string {
        const parts = [];
        if (event.modifiers & Qt.ControlModifier)
            parts.push("CTRL");
        if (event.modifiers & Qt.AltModifier)
            parts.push("ALT");
        if (event.modifiers & Qt.ShiftModifier)
            parts.push("SHIFT");
        if (event.modifiers & Qt.MetaModifier)
            parts.push("SUPER");

        const key = event.text && event.text.length > 0 ? event.text.toUpperCase() : event.key.toString();
        if (key.length > 0 && parts.indexOf(key) < 0)
            parts.push(key);

        return parts.join("+");
    }

    function captureEvent(event: var): void {
        if (!recording)
            return;

        if (event.key === Qt.Key_Escape) {
            cancelRecording();
            event.accepted = true;
            return;
        }

        const combo = formatEvent(event);
        if (combo.length === 0)
            return;

        recordedCombo = combo;
        recording = false;
        recordStatusLine = "recorder: captured " + combo;
        event.accepted = true;
    }

    function copyBindTemplate(): void {
        if (recordedCombo.length === 0) {
            recordStatusLine = "recorder: no chord captured";
            return;
        }

        const parts = recordedCombo.split("+");
        const key = parts.pop() || "KEY";
        const mods = parts.join(" ");
        pendingCopyText = "bind = " + (mods.length > 0 ? mods + ", " : "") + key + ", exec, <command>";
        copyProcess.command = ["wl-copy", pendingCopyText];
        copyProcess.running = true;
    }

    function updateBinds(output: string, backend: string): void {
        if (!SettingsService.liveDataEnabled || bindBackend !== backend)
            return;

        try {
            const payload = JSON.parse(output);
            if (!Array.isArray(payload))
                throw new Error("unsupported binds payload");
            const next = [];
            for (const bind of payload) {
                const mods = bind.modmaskname || bind.modmask || "";
                const key = bind.key || bind.keycode || "?";
                const dispatcher = bind.dispatcher || "dispatch";
                const arg = bind.arg || "";
                next.push({
                    combo: (mods.length > 0 ? mods + "+" : "") + key,
                    action: dispatcher + (arg.length > 0 ? " " + arg : "")
                });
            }
            keybinds = next.slice(0, 12);
            available = next.length > 0;
            statusLine = available ? "keybinds: " + next.length + " binds // " + backend : "keybinds: no binds // " + backend;
        } catch (error) {
            keybinds = [];
            available = false;
            statusLine = "keybinds: parse fallback // " + backend;
        }
    }

    function stopBindProcesses(): void {
        hyprBindsProcess.running = false;
        niriBindsProcess.running = false;
    }

    function refresh(): void {
        if (CompositorService.hyprlandActive) {
            bindBackend = "hyprland";
            niriBindsProcess.running = false;
            if (!hyprBindsProcess.running)
                hyprBindsProcess.running = true;
        } else if (CompositorService.niriActive) {
            bindBackend = "niri";
            hyprBindsProcess.running = false;
            if (!niriBindsProcess.running)
                niriBindsProcess.running = true;
        } else {
            stopBindProcesses();
            bindBackend = "fallback";
            keybinds = [];
            available = false;
            statusLine = "keybinds: compositor fallback";
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
        stopBindProcesses();
    }

    Component.onCompleted: startPollingIfReady()

    property Timer poller: Timer {
        interval: 30000
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

    property Process hyprBindsProcess: Process {
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateBinds(text, "hyprland")
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 && root.bindBackend === "hyprland") {
                root.keybinds = [];
                root.available = false;
                root.statusLine = "keybinds: hyprland fallback";
            }
        }
    }

    property Process niriBindsProcess: Process {
        command: ["niri", "msg", "binds"]
        stdout: StdioCollector {
            onStreamFinished: root.updateBinds(text, "niri")
        }
        onExited: (exitCode) => {
            if (exitCode !== 0 && root.bindBackend === "niri") {
                root.keybinds = [];
                root.available = false;
                root.statusLine = "keybinds: niri fallback";
            }
        }
    }

    property Process copyProcess: Process {
        command: ["wl-copy", root.pendingCopyText]
        onExited: (exitCode) => {
            root.recordStatusLine = exitCode === 0 ? "recorder: template copied" : "recorder: wl-copy fallback";
        }
    }
}
