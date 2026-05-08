#!/usr/bin/env node

const fs = require("fs");

function usage() {
    console.error(`Usage: node tools/inspect-coastlines.js <generated-coastlines.js> [--json]

Inspects a generated coastline JS module before it replaces runtime data.
The input must contain the current contract:

    var coastlines = [
        [[lat, lon], [lat, lon]]
    ]`);
}

function parseArgs(argv) {
    const args = argv.slice(2);
    if (args.length < 1 || args.includes("--help") || args.includes("-h")) {
        usage();
        process.exit(args.length < 1 ? 1 : 0);
    }

    const inputPath = args[0];
    let json = false;

    for (let i = 1; i < args.length; i++) {
        if (args[i] === "--json") {
            json = true;
        } else {
            throw new Error(`Unknown argument: ${args[i]}`);
        }
    }

    return { inputPath, json };
}

function loadCoastlines(source, inputPath) {
    const literal = extractCoastlineArrayLiteral(source, inputPath);
    let coastlines;

    try {
        coastlines = JSON.parse(literal);
    } catch (error) {
        throw new Error(`Could not parse coastlines array literal in ${inputPath}: ${error.message}`);
    }

    if (!Array.isArray(coastlines)) {
        throw new Error("Input must define var coastlines as an array");
    }

    return coastlines;
}

function extractCoastlineArrayLiteral(source, inputPath) {
    const declaration = /\bvar\s+coastlines\s*=/g;
    const match = declaration.exec(source);

    if (!match) {
        throw new Error(`Input ${inputPath} must contain 'var coastlines = [...]'`);
    }

    let index = skipIgnored(source, match.index + match[0].length);

    if (source[index] !== "[") {
        throw new Error(`Input ${inputPath} must assign an array literal to var coastlines`);
    }

    const start = index;
    let depth = 0;

    while (index < source.length) {
        const char = source[index];

        if (char === "/" && source[index + 1] === "/") {
            index = skipLineComment(source, index);
            continue;
        }

        if (char === "/" && source[index + 1] === "*") {
            index = skipBlockComment(source, index);
            continue;
        }

        if (char === "[") {
            depth++;
        } else if (char === "]") {
            depth--;
            if (depth === 0) {
                return source.slice(start, index + 1);
            }
        }

        index++;
    }

    throw new Error(`Input ${inputPath} has an unterminated coastlines array literal`);
}

function skipIgnored(source, index) {
    while (index < source.length) {
        const char = source[index];

        if (/\s/.test(char)) {
            index++;
            continue;
        }

        if (char === "/" && source[index + 1] === "/") {
            index = skipLineComment(source, index);
            continue;
        }

        if (char === "/" && source[index + 1] === "*") {
            index = skipBlockComment(source, index);
            continue;
        }

        return index;
    }

    return index;
}

function skipLineComment(source, index) {
    const nextNewline = source.indexOf("\n", index + 2);
    return nextNewline === -1 ? source.length : nextNewline + 1;
}

function skipBlockComment(source, index) {
    const end = source.indexOf("*/", index + 2);

    if (end === -1) {
        throw new Error("Unterminated block comment while reading coastlines array literal");
    }

    return end + 2;
}

function inspectCoastlines(coastlines, byteSize) {
    let pointCount = 0;
    let minLat = Infinity;
    let maxLat = -Infinity;
    let minLon = Infinity;
    let maxLon = -Infinity;
    let longestPolylineIndex = -1;
    let longestPolylinePoints = 0;
    let shortPolylineCount = 0;

    coastlines.forEach((polyline, polylineIndex) => {
        if (!Array.isArray(polyline)) {
            throw new Error(`coastlines[${polylineIndex}] must be a polyline array`);
        }

        if (polyline.length < 2) {
            shortPolylineCount++;
        }

        if (polyline.length > longestPolylinePoints) {
            longestPolylineIndex = polylineIndex;
            longestPolylinePoints = polyline.length;
        }

        polyline.forEach((point, pointIndex) => {
            if (!Array.isArray(point) || point.length < 2) {
                throw new Error(`coastlines[${polylineIndex}][${pointIndex}] must be a [lat, lon] pair`);
            }

            const lat = point[0];
            const lon = point[1];

            if (typeof lat !== "number" || typeof lon !== "number" || !Number.isFinite(lat) || !Number.isFinite(lon)) {
                throw new Error(`coastlines[${polylineIndex}][${pointIndex}] must contain finite numeric lat/lon values`);
            }
            if (lat < -90 || lat > 90) {
                throw new Error(`Latitude out of range at coastlines[${polylineIndex}][${pointIndex}]: ${lat}`);
            }
            if (lon < -180 || lon > 180) {
                throw new Error(`Longitude out of range at coastlines[${polylineIndex}][${pointIndex}]: ${lon}`);
            }

            pointCount++;
            minLat = Math.min(minLat, lat);
            maxLat = Math.max(maxLat, lat);
            minLon = Math.min(minLon, lon);
            maxLon = Math.max(maxLon, lon);
        });
    });

    if (pointCount === 0) {
        throw new Error("No coastline points found");
    }

    return {
        polylines: coastlines.length,
        points: pointCount,
        byteSize,
        bounds: {
            minLat,
            maxLat,
            minLon,
            maxLon
        },
        longestPolyline: {
            index: longestPolylineIndex,
            points: longestPolylinePoints
        },
        averagePointsPerPolyline: Number((pointCount / coastlines.length).toFixed(2)),
        shortPolylineCount
    };
}

function formatStats(stats, inputPath) {
    return [
        `Coastline stats for ${inputPath}`,
        `  Polylines: ${stats.polylines}`,
        `  Points: ${stats.points}`,
        `  File size: ${stats.byteSize} bytes`,
        `  Bounds: lat ${stats.bounds.minLat}..${stats.bounds.maxLat}, lon ${stats.bounds.minLon}..${stats.bounds.maxLon}`,
        `  Longest polyline: #${stats.longestPolyline.index} (${stats.longestPolyline.points} points)`,
        `  Average points/polyline: ${stats.averagePointsPerPolyline}`,
        `  Short polylines (<2 points): ${stats.shortPolylineCount}`
    ].join("\n");
}

function inspectFile(inputPath) {
    const source = fs.readFileSync(inputPath, "utf8");
    const coastlines = loadCoastlines(source, inputPath);

    return inspectCoastlines(coastlines, Buffer.byteLength(source, "utf8"));
}

function main() {
    const { inputPath, json } = parseArgs(process.argv);
    const stats = inspectFile(inputPath);

    if (json) {
        console.log(JSON.stringify(stats, null, 2));
    } else {
        console.log(formatStats(stats, inputPath));
    }
}

if (require.main === module) {
    try {
        main();
    } catch (error) {
        console.error(`inspect-coastlines: ${error.message}`);
        process.exit(1);
    }
} else {
    module.exports = {
        formatStats,
        inspectCoastlines,
        inspectFile,
        loadCoastlines
    };
}
