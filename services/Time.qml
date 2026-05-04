pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

QtObject {
    id: root

    property date now: new Date()

    readonly property string timeText: Qt.formatDateTime(now, "hh:mm:ss")
    readonly property string dateText: Qt.formatDateTime(now, "yyyy-MM-dd ddd").toUpperCase()

    Timer {
        interval: 1000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }
}
