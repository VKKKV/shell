pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string query: ""
    property string statusLine: "launcher: initializing"
    property string pendingCopyText: ""
    property bool barOpen: false
    property int selectedIndex: 0
    readonly property int barResultLimit: 4
    property var apps: []
    readonly property var actions: [{
        id: "settings",
        name: "Toggle Command Center",
        command: "settings"
    }, {
        id: "terminal",
        name: "Launch Terminal",
        command: "terminal"
    }, {
        id: "reload",
        name: "Reload Quickshell",
        command: "reload"
    }, {
        id: "lock",
        name: "Lock Session",
        command: "lock"
    }]
    readonly property var filtered: filterEntries()

    onQueryChanged: clampSelection()
    onAppsChanged: clampSelection()

    function filterEntries(): var {
        const needle = query.trim().toLowerCase();
        const raw = query.trim();
        const dynamic = [];

        if (raw.indexOf("=") === 0) {
            const expression = raw.slice(1).trim();
            if (/^[0-9+\-*/(). %]+$/.test(expression) && expression.length > 0) {
                try {
                    const value = Function("return (" + expression + ")")();
                    dynamic.push({
                        type: "calc",
                        id: "calc",
                        name: expression + " = " + value,
                        command: String(value)
                    });
                } catch (error) {
                    dynamic.push({
                        type: "calc",
                        id: "calc-error",
                        name: "calculator parse fallback",
                        command: ""
                    });
                }
            }
        } else if (raw.indexOf("$") === 0) {
            const command = raw.slice(1).trim();
            if (command.length > 0) {
                dynamic.push({
                    type: "shell",
                    id: "shell-command",
                    name: "Execute // " + command,
                    command
                });
            }
        }

        const combined = actions.map(action => ({
            type: "action",
            id: action.id,
            name: action.name,
            command: action.command
        })).concat(dynamic).concat(apps);

        if (needle.length === 0)
            return combined.slice(0, 8);

        return combined.filter(entry => (entry.name + " " + entry.id).toLowerCase().indexOf(needle) >= 0).slice(0, 8);
    }

    function updateApps(output: string): void {
        const seen = new Set();
        const next = [];
        for (const line of output.trim().split("\n")) {
            if (line.length === 0)
                continue;

            const parts = line.split("|");
            const id = parts[0] || "";
            const name = parts.slice(1).join("|") || id;
            if (id.length === 0 || seen.has(id))
                continue;

            seen.add(id);
            next.push({
                type: "app",
                id,
                name,
                command: id
            });
        }
        apps = next.sort((a, b) => a.name.localeCompare(b.name));
        statusLine = "launcher: " + apps.length + " apps indexed";
    }

    function launch(entry: var): void {
        if (!entry)
            return;

        if (entry.type === "app") {
            launchProcess.command = ["gtk-launch", entry.id];
            launchProcess.running = true;
            statusLine = "launcher: app " + entry.name;
            SettingsService.panelOpen = false;
            return;
        }

        if (entry.type === "calc") {
            pendingCopyText = entry.command;
            copyProcess.command = ["wl-copy", pendingCopyText];
            copyProcess.running = true;
            statusLine = "launcher: calculator copied";
            return;
        }

        if (entry.type === "shell") {
            launchProcess.command = ["sh", "-c", entry.command];
            launchProcess.running = true;
            statusLine = "launcher: shell dispatch";
            SettingsService.panelOpen = false;
            return;
        }

        if (entry.command === "settings") {
            SettingsService.togglePanel();
        } else if (entry.command === "terminal") {
            launchProcess.command = ["sh", "-c", "foot || kitty || alacritty || xterm"];
            launchProcess.running = true;
            SettingsService.panelOpen = false;
        } else if (entry.command === "reload") {
            Quickshell.reload(true);
        } else if (entry.command === "lock") {
            SessionService.confirm("lock");
        }
    }

    function openBar(): void {
        barOpen = true;
        clampSelection();
        statusLine = "launcher: bar open";
    }

    function closeBar(): void {
        barOpen = false;
        selectedIndex = 0;
        statusLine = "launcher: bar closed";
    }

    function toggleBar(): void {
        if (barOpen)
            closeBar();
        else
            openBar();
    }

    function clampSelection(): void {
        const count = Math.min(filtered.length, barResultLimit);
        if (count <= 0) {
            selectedIndex = 0;
            return;
        }

        selectedIndex = Math.max(0, Math.min(selectedIndex, count - 1));
    }

    function moveSelection(delta: int): void {
        const count = Math.min(filtered.length, barResultLimit);
        if (count <= 0) {
            selectedIndex = 0;
            return;
        }

        selectedIndex = Math.max(0, Math.min(selectedIndex + delta, count - 1));
    }

    function launchSelected(): void {
        const count = filtered.length;
        if (count <= 0) {
            statusLine = apps.length === 0 ? "launcher: no apps indexed" : "launcher: no matching result";
            return;
        }

        clampSelection();
        launch(filtered[selectedIndex]);
        closeBar();
    }

    function refresh(): void {
        listProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Process listProcess: Process {
        command: ["sh", "-c", "for file in /usr/share/applications/*.desktop \"$HOME\"/.local/share/applications/*.desktop; do [ -f \"$file\" ] || continue; grep -q '^NoDisplay=true' \"$file\" && continue; id=$(basename \"$file\" .desktop); name=$(grep -m1 '^Name=' \"$file\" | cut -d= -f2-); [ -n \"$name\" ] || name=$id; printf '%s|%s\\n' \"$id\" \"$name\"; done"]
        stdout: StdioCollector {
            onStreamFinished: root.updateApps(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.statusLine = "launcher: app scan fallback";
        }
    }

    property Process launchProcess: Process {
        command: ["true"]
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.statusLine = "launcher: command failed";
        }
    }

    property Process copyProcess: Process {
        command: ["wl-copy", root.pendingCopyText]
        onExited: (exitCode) => {
            root.statusLine = exitCode === 0 ? "launcher: copied result" : "launcher: wl-copy fallback";
        }
    }
}
