pragma Singleton

import QtQuick

QtObject {
    function startupDelay(slot: int): int {
        return Math.max(0, slot) * 350;
    }
}
