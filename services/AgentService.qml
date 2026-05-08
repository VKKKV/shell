pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property string providerName: "UNCONFIGURED"
    property string state: "disabled"
    property string statusLine: "agent: provider execution disabled"
    property string responseText: "Provider contract is staged. No command execution is enabled."
    property string errorDetail: ""
    readonly property bool available: false
    readonly property bool running: false

    function submit(prompt: string): void {
        const clean = prompt.trim();
        if (clean.length === 0)
            return;

        state = "blocked";
        statusLine = "agent: submit blocked until provider command exists";
        responseText = "PROMPT STAGED // " + clean;
        errorDetail = "provider command execution is disabled";
        ServiceLogService.push("agent", "warn", statusLine);
    }
}
