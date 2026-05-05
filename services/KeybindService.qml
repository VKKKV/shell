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

    function updateBinds(output: string): void {
        try {
            const payload = JSON.parse(output);
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
            statusLine = available ? "keybinds: " + next.length + " binds" : "keybinds: no binds";
        } catch (error) {
            keybinds = [];
            available = false;
            statusLine = "keybinds: parse fallback";
        }
    }

    function refresh(): void {
        bindsProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Timer poller: Timer {
        interval: 30000
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

    property Process bindsProcess: Process {
        command: ["hyprctl", "binds", "-j"]
        stdout: StdioCollector {
            onStreamFinished: root.updateBinds(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.keybinds = [];
                root.available = false;
                root.statusLine = "keybinds: hyprctl fallback";
            }
        }
    }
}
