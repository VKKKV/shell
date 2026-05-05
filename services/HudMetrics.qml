pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property int topReserved: 0
    property int bottomReserved: 0
    property int leftReserved: 0
    property int rightReserved: 0
}
