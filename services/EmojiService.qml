pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: [
        { glyph: "⚡", name: "power" },
        { glyph: "🔥", name: "alert" },
        { glyph: "🛰", name: "satellite" },
        { glyph: "🛡", name: "shield" },
        { glyph: "🧠", name: "brain" },
        { glyph: "🧬", name: "gene" },
        { glyph: "💾", name: "disk" },
        { glyph: "📡", name: "antenna" },
        { glyph: "🔒", name: "lock" },
        { glyph: "🧪", name: "lab" },
        { glyph: "🌐", name: "globe" },
        { glyph: "🚀", name: "launch" }
    ]
    property string statusLine: "emoji: local palette ready"

    function copy(glyph: string): void {
        copyProcess.command = ["wl-copy", glyph];
        copyProcess.running = true;
    }

    property Process copyProcess: Process {
        command: ["wl-copy", ""]
        onExited: (exitCode) => {
            root.statusLine = exitCode === 0 ? "emoji: copied" : "emoji: wl-copy fallback";
        }
    }
}
