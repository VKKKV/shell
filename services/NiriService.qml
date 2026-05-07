pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool available: false
    property int activeWorkspace: 1
    property string activeWindowTitle: "NO ACTIVE WINDOW"
    property string activeWindowClass: "UNKNOWN"
    property bool activeWindowAvailable: false
    property string statusLine: "niri: initializing"
    property var rawWorkspaces: []
    property var workspaces: []
    property var currentWorkspaceWindows: []
    property var knownWindows: []
    property var pendingFocusId: ""

    readonly property string compositorName: "niri"

    function compact(text: string, maxLength: int): string {
        if (text.length <= maxLength)
            return text;
        return text.slice(0, Math.max(0, maxLength - 3)) + "...";
    }

    function fallback(message: string): void {
        available = false;
        activeWorkspace = 1;
        activeWindowTitle = "NO ACTIVE WINDOW";
        activeWindowClass = "UNKNOWN";
        activeWindowAvailable = false;
        rawWorkspaces = [];
        workspaces = [];
        currentWorkspaceWindows = [];
        knownWindows = [];
        statusLine = message;
    }

    function normalizeWorkspaceId(workspace: var): int {
        const raw = workspace?.idx ?? workspace?.id ?? workspace?.name ?? 1;
        const numeric = Number(raw);
        return Number.isFinite(numeric) && numeric > 0 ? Math.round(numeric) : 1;
    }

    function windowWorkspaceId(window: var): int {
        const raw = window?.workspace_id ?? window?.workspace?.id ?? window?.workspace_idx ?? 1;
        const numeric = Number(raw);
        return Number.isFinite(numeric) && numeric > 0 ? Math.round(numeric) : activeWorkspace;
    }

    function hasWindowOnWorkspace(id: int): bool {
        return knownWindows.some(window => windowWorkspaceId(window) === id);
    }

    function shapeWorkspaces(values: var): var {
        return values.map(workspace => {
            const id = normalizeWorkspaceId(workspace);
            const active = workspace?.is_active === true || workspace?.is_focused === true || workspace?.active === true || workspace?.focused === true;
            const occupied = (workspace?.active_window_id ?? null) !== null || (workspace?.windows ?? 0) > 0 || hasWindowOnWorkspace(id);
            return {
                id: id,
                label: workspace?.name || String(id),
                active: active,
                occupied: occupied
            };
        }).sort((left, right) => left.id - right.id);
    }

    function refreshWorkspaceOccupancy(): void {
        if (rawWorkspaces.length === 0)
            return;

        workspaces = shapeWorkspaces(rawWorkspaces);
    }

    function updateWorkspaces(output: string): void {
        try {
            const payload = JSON.parse(output || "[]");
            const values = Array.isArray(payload) ? payload : [];
            const rows = shapeWorkspaces(values);

            rawWorkspaces = values;
            workspaces = rows;
            const activeRow = rows.find(row => row.active);
            activeWorkspace = activeRow?.id ?? (rows.length > 0 ? rows[0].id : 1);
            available = rows.length > 0;
            statusLine = available ? "niri: workspace service online" : "niri: workspace fallback";
            windowProcess.running = true;
        } catch (error) {
            fallback("niri: workspace parse fallback");
        }
    }

    function updateWindows(output: string): void {
        try {
            const payload = JSON.parse(output || "[]");
            const values = Array.isArray(payload) ? payload : [];
            knownWindows = values;
            refreshWorkspaceOccupancy();
            const activeWindow = values.find(window => window?.is_focused === true || window?.focused === true || window?.is_active === true || window?.active === true);
            const rows = values.filter(window => windowWorkspaceId(window) === activeWorkspace).slice(0, 6).map(window => ({
                id: String(window?.id ?? window?.app_id ?? window?.title ?? ""),
                windowKey: String(window?.id ?? window?.app_id ?? window?.title ?? ""),
                title: compact(window?.title || "UNTITLED", 42),
                appClass: compact(window?.app_id || window?.app_class || "unknown", 18),
                active: activeWindow !== undefined && window === activeWindow
            }));

            currentWorkspaceWindows = rows;
            activeWindowAvailable = activeWindow !== undefined;
            activeWindowTitle = activeWindowAvailable ? compact(activeWindow.title || "UNTITLED", 64) : "NO ACTIVE WINDOW";
            activeWindowClass = activeWindowAvailable ? compact(activeWindow.app_id || activeWindow.app_class || "unknown", 24) : "UNKNOWN";
            available = true;
            statusLine = "niri: workspace/window service online";
        } catch (error) {
            currentWorkspaceWindows = [];
            activeWindowAvailable = false;
            activeWindowTitle = "NO ACTIVE WINDOW";
            activeWindowClass = "UNKNOWN";
            statusLine = "niri: window parse fallback";
        }
    }

    function isOccupied(id: int): bool {
        return workspaces.some(workspace => workspace.id === id && workspace.occupied);
    }

    function switchWorkspace(id: int): void {
        if (!available)
            return;
        switchProcess.command = ["niri", "msg", "action", "focus-workspace", String(id)];
        switchProcess.running = true;
    }

    function focusWindow(windowKey: string): void {
        if (!available)
            return;

        const target = currentWorkspaceWindows.find(window => window.id === windowKey || window.title === windowKey);
        if (!target || target.id.length === 0)
            return;

        pendingFocusId = target.id;
        focusProcess.command = ["niri", "msg", "action", "focus-window", "--id", pendingFocusId];
        focusProcess.running = true;
    }

    function refresh(): void {
        workspaceProcess.running = true;
    }

    Component.onCompleted: refresh()

    property Timer poller: Timer {
        interval: 3000
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

    property Process workspaceProcess: Process {
        command: ["sh", "-c", "command -v niri >/dev/null 2>&1 && niri msg --json workspaces || exit 127"]
        stdout: StdioCollector {
            onStreamFinished: root.updateWorkspaces(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0)
                root.fallback("niri: command fallback");
        }
    }

    property Process windowProcess: Process {
        command: ["sh", "-c", "command -v niri >/dev/null 2>&1 && niri msg --json windows || exit 127"]
        stdout: StdioCollector {
            onStreamFinished: root.updateWindows(text)
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.currentWorkspaceWindows = [];
                root.activeWindowAvailable = false;
                root.activeWindowTitle = "NO ACTIVE WINDOW";
                root.activeWindowClass = "UNKNOWN";
                root.statusLine = root.available ? "niri: window fallback" : "niri: command fallback";
            }
        }
    }

    property Process switchProcess: Process {
        command: ["true"]
        onExited: (exitCode) => {
            root.statusLine = exitCode === 0 ? "niri: workspace switch dispatched" : "niri: workspace switch fallback";
            root.refresh();
        }
    }

    property Process focusProcess: Process {
        command: ["true"]
        onExited: (exitCode) => {
            root.statusLine = exitCode === 0 ? "niri: focus dispatched" : "niri: focus fallback";
            root.refresh();
        }
    }
}
