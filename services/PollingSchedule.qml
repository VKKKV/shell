pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    function startupDelay(slot: int): int {
        return Math.max(0, slot) * 350;
    }
}
