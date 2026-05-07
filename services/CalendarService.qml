pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root

    property date now: new Date()
    readonly property string dayText: Qt.formatDateTime(now, "dddd").toUpperCase()
    readonly property string dateText: Qt.formatDateTime(now, "yyyy-MM-dd")
    readonly property string monthText: Qt.formatDateTime(now, "MMMM yyyy").toUpperCase()
    readonly property var weekRows: monthCache.rows
    readonly property var monthCells: monthCache.cells
    readonly property var agenda: buildAgenda(now)
    readonly property string statusLine: "calendar: local agenda ready"
    readonly property var monthCache: buildMonthCache(now)

    function daysInMonth(year: int, month: int): int {
        return new Date(year, month + 1, 0).getDate();
    }

    function buildMonthRows(date: date): var {
        const year = date.getFullYear();
        const month = date.getMonth();
        const today = date.getDate();
        const firstDay = new Date(year, month, 1).getDay();
        const total = daysInMonth(year, month);
        const rows = [];
        let day = 1 - firstDay;

        for (let row = 0; row < 6; row++) {
            const cells = [];
            for (let col = 0; col < 7; col++) {
                const inMonth = day >= 1 && day <= total;
                cells.push({
                    label: inMonth ? String(day).padStart(2, "0") : "--",
                    active: inMonth && day === today,
                    dim: !inMonth
                });
                day++;
            }
            rows.push(cells);
        }
        return rows;
    }

    function buildMonthCache(date: date): var {
        const rows = buildMonthRows(date);
        const cells = [];
        for (const row of rows) {
            for (const cell of row)
                cells.push(cell);
        }
        return {
            rows,
            cells
        };
    }

    function buildAgenda(date: date): var {
        const hour = date.getHours();
        const phase = hour < 12 ? "MORNING OPS" : (hour < 18 ? "AFTERNOON OPS" : "NIGHT WATCH");
        return [phase, "CHECK HUD VISUALS", "REVIEW SYSTEM STATUS", "PLAN NEXT SHELL SLICE"];
    }

    property Timer ticker: Timer {
        interval: 60000
        repeat: true
        running: true
        triggeredOnStart: true
        onTriggered: root.now = new Date()
    }
}
