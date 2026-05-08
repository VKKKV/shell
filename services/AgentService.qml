pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string providerName: "UNCONFIGURED"
    property string state: "unavailable"
    property string statusLine: "agent: provider execution disabled"
    property string responseText: "Provider contract is staged. No command execution is enabled."
    property string errorDetail: ""
    property var providerCommand: []
    property string activePrompt: ""
    property string stdoutText: ""
    property string stderrText: ""
    property bool hermesAvailable: false
    property bool openClawAvailable: false
    property bool probeComplete: false
    readonly property var providerPresets: [
        { id: "disabled", name: "DISABLED", command: [], available: true, detail: "No provider command configured." },
        { id: "hermes", name: "HERMES", command: ["hermes", "--oneshot"], available: hermesAvailable, detail: hermesAvailable ? "Hermes oneshot mode — prompt prints final response to stdout." : "Hermes command not found." },
        { id: "openclaw", name: "OPENCLAW", command: ["openclaw", "agent"], available: openClawAvailable, detail: openClawAvailable ? "OpenClaw local command adapter available." : "OpenClaw command not found." }
    ]
    readonly property bool available: providerCommand.length > 0
    readonly property bool running: state === "running"

    function compact(text: string): string {
        const clean = text.replace(/\s+/g, " ").trim();
        return clean.length > 120 ? clean.slice(0, 117) + "..." : clean;
    }

    function selectProvider(id: string): void {
        if (running) {
            statusLine = "agent: provider switch blocked while running";
            errorDetail = "wait for current provider request to finish";
            ServiceLogService.push("agent", "warn", statusLine);
            return;
        }

        applyProvider(id, false);
    }

    function applyProvider(id: string, fromSettings: bool): void {
        if (running)
            return;

        if (!probeComplete && id !== "disabled") {
            providerName = id.toUpperCase();
            providerCommand = [];
            state = "probing";
            statusLine = "agent: probing provider " + id;
            responseText = "Checking provider command availability.";
            errorDetail = "";
            return;
        }

        const preset = providerPresets.find(entry => entry.id === id) || providerPresets[0];
        providerName = preset.name;
        providerCommand = preset.available ? preset.command : [];
        state = providerCommand.length > 0 ? "idle" : "unavailable";
        statusLine = providerCommand.length > 0 ? "agent: provider selected " + preset.name.toLowerCase() : "agent: provider unavailable " + preset.name.toLowerCase();
        responseText = preset.detail;
        errorDetail = providerCommand.length > 0 ? "" : "provider preset unavailable; command not configured";
        if (!fromSettings && SettingsService.agentProviderId !== preset.id)
            SettingsService.agentProviderId = preset.id;
        ServiceLogService.push("agent", providerCommand.length > 0 ? "info" : "warn", statusLine);
    }

    Component.onCompleted: {
        probeProcess.running = true;
        if (!SettingsService.loading && SettingsService.agentProviderId === "disabled")
            applyProvider(SettingsService.agentProviderId, true);
    }

    onHermesAvailableChanged: if (probeComplete) applyProvider(SettingsService.agentProviderId, true)
    onOpenClawAvailableChanged: if (probeComplete) applyProvider(SettingsService.agentProviderId, true)

    Connections {
        target: SettingsService
        function onLoadingChanged(): void {
            if (!SettingsService.loading && (probeComplete || SettingsService.agentProviderId === "disabled"))
                root.applyProvider(SettingsService.agentProviderId, true);
        }
        function onAgentProviderIdChanged(): void {
            if (probeComplete || SettingsService.agentProviderId === "disabled")
                root.applyProvider(SettingsService.agentProviderId, true);
        }
    }

    function submit(prompt: string): void {
        const clean = prompt.trim();
        if (clean.length === 0)
            return;

        if (running) {
            state = "running";
            statusLine = "agent: busy";
            errorDetail = "request rejected while provider is running";
            ServiceLogService.push("agent", "warn", statusLine);
            return;
        }

        if (providerCommand.length === 0) {
            state = "unavailable";
            statusLine = "agent: provider command missing";
            responseText = "PROMPT STAGED // " + clean;
            errorDetail = "configure a local argv provider before execution";
            ServiceLogService.push("agent", "warn", statusLine);
            return;
        }

        activePrompt = clean;
        stdoutText = "";
        stderrText = "";
        providerProcess.command = providerCommand.concat([clean]);
        state = "running";
        statusLine = "agent: provider running";
        errorDetail = "";
        responseText = "PROMPT DISPATCHED // " + clean;
        timeoutTimer.restart();
        providerProcess.running = true;
        ServiceLogService.push("agent", "info", statusLine);
    }

    Timer {
        id: timeoutTimer

        interval: 30000
        repeat: false
        onTriggered: {
            providerProcess.running = false;
            root.state = "timeout";
            root.statusLine = "agent: provider timeout";
            root.errorDetail = "provider exceeded 30s timeout";
            root.responseText = "PROMPT TIMEOUT // " + root.activePrompt;
            ServiceLogService.push("agent", "warn", root.statusLine);
        }
    }

    Process {
        id: probeProcess

        command: ["sh", "-c", "command -v hermes >/dev/null 2>&1 && printf 'hermes=1\n' || printf 'hermes=0\n'; command -v openclaw >/dev/null 2>&1 && printf 'openclaw=1\n' || printf 'openclaw=0\n'"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.hermesAvailable = text.indexOf("hermes=1") >= 0;
                root.openClawAvailable = text.indexOf("openclaw=1") >= 0;
                root.probeComplete = true;
                root.applyProvider(SettingsService.agentProviderId, true);
            }
        }
        onExited: (exitCode) => {
            if (exitCode !== 0) {
                root.hermesAvailable = false;
                root.openClawAvailable = false;
                root.probeComplete = true;
                root.statusLine = "agent: provider probe fallback";
                root.applyProvider(SettingsService.agentProviderId, true);
            }
        }
    }

    Process {
        id: providerProcess

        command: ["true"]
        stdout: StdioCollector {
            onStreamFinished: root.stdoutText = text
        }
        stderr: StdioCollector {
            onStreamFinished: root.stderrText = text
        }
        onExited: (exitCode) => {
            if (root.state === "timeout")
                return;

            root.timeoutTimer.stop();
            if (exitCode !== 0) {
                root.state = "failed";
                root.statusLine = "agent: provider failed";
                root.errorDetail = compact(root.stderrText.length > 0 ? root.stderrText : "exit " + exitCode);
                root.responseText = "PROMPT FAILED // " + root.activePrompt;
                ServiceLogService.push("agent", "warn", root.statusLine);
                return;
            }

            const cleanOutput = root.stdoutText.trim();
            if (cleanOutput.length === 0) {
                root.state = "failed";
                root.statusLine = "agent: empty response";
                root.errorDetail = "provider returned empty stdout";
                root.responseText = "PROMPT EMPTY // " + root.activePrompt;
                ServiceLogService.push("agent", "warn", root.statusLine);
                return;
            }

            root.state = "ok";
            root.statusLine = "agent: response ready";
            root.errorDetail = "";
            root.responseText = cleanOutput;
            ServiceLogService.push("agent", "info", root.statusLine);
        }
    }
}
