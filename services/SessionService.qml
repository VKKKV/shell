pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string pendingAction: ""
    property string statusLine: "session: armed confirmation required"

    function arm(action: string): void {
        pendingAction = action;
        statusLine = "session: confirm " + action;
        confirmationTimer.restart();
    }

    function clear(): void {
        pendingAction = "";
        statusLine = "session: confirmation cleared";
        confirmationTimer.stop();
    }

    function commandForAction(action: string): var {
        if (action === "lock")
            return ["loginctl", "lock-session"];
        if (action === "logout") {
            const user = Quickshell.env("USER") || "";
            if (user.length > 0)
                return ["loginctl", "terminate-user", user];
            const session = Quickshell.env("XDG_SESSION_ID") || "";
            return session.length > 0 ? ["loginctl", "terminate-session", session] : [];
        }
        if (action === "reboot")
            return ["systemctl", "reboot"];
        if (action === "shutdown")
            return ["systemctl", "poweroff"];
        return [];
    }

    function confirm(action: string): void {
        if (pendingAction !== action) {
            arm(action);
            return;
        }

        if (action === "logout" && CompositorService.logout()) {
            statusLine = "session: logout via " + CompositorService.compositorName;
            pendingAction = "";
            confirmationTimer.stop();
            return;
        }

        const nextCommand = commandForAction(action);
        if (nextCommand.length === 0) {
            statusLine = "session: unknown action";
            clear();
            return;
        }

        commandProcess.command = nextCommand;
        commandProcess.running = true;
        statusLine = "session: executing " + action;
        pendingAction = "";
        confirmationTimer.stop();
    }

    property Timer confirmationTimer: Timer {
        interval: 5000
        repeat: false
        onTriggered: root.clear()
    }

    property Process commandProcess: Process {
        command: ["true"]
        onExited: (exitCode) => {
            root.statusLine = exitCode === 0 ? "session: command dispatched" : "session: command failed";
        }
    }
}
