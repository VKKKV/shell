pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property string providerName: "UNCONFIGURED"
    readonly property string state: "disabled"
    readonly property string statusLine: "agent: provider execution disabled"
    readonly property string responseText: "Provider contract is staged. No command execution is enabled."
    readonly property string errorDetail: ""
    readonly property bool available: false
    readonly property bool running: false

    function submit(prompt: string): void {
        if (prompt.length > 0)
            ServiceLogService.push("agent", "warn", "agent: provider command blocked until contract implementation");
    }
}
