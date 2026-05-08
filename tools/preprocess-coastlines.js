#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const DEFAULT_PRECISION = 3;
const DEFAULT_SIMPLIFY_TOLERANCE = 0;
const DEFAULT_MIN_POINTS = 2;

function usage() {
    console.error(`Usage: node tools/preprocess-coastlines.js <input.geojson> <output.js> [--precision <digits>] [--simplify <degrees>] [--min-points <count>]

Converts offline GeoJSON-like coastline data into the JS array contract used by
components/EarthCoastlineData.js:

    var coastlines = [
        [[lat, lon], [lat, lon]]
    ]

Supported geometries: LineString, MultiLineString, Polygon, MultiPolygon,
GeometryCollection, Feature, and FeatureCollection. Input coordinates must use
standard GeoJSON order: [longitude, latitude].

--simplify applies deterministic Ramer-Douglas-Peucker simplification in
latitude/longitude degree space after coordinate conversion. Use it only for
reviewed runtime candidates where Canvas repaint cost matters.`);
}

function parseArgs(argv) {
    const args = argv.slice(2);
    if (args.length < 2 || args.includes("--help") || args.includes("-h")) {
        usage();
        process.exit(args.length < 2 ? 1 : 0);
    }

    const inputPath = args[0];
    const outputPath = args[1];
    let precision = DEFAULT_PRECISION;
    let simplifyTolerance = DEFAULT_SIMPLIFY_TOLERANCE;
    let minPoints = DEFAULT_MIN_POINTS;

    for (let i = 2; i < args.length; i++) {
        if (args[i] === "--precision") {
            const raw = args[++i];
            precision = Number.parseInt(raw, 10);
            if (!Number.isInteger(precision) || precision < 0 || precision > 8) {
                throw new Error("--precision must be an integer from 0 to 8");
            }
        } else if (args[i] === "--simplify") {
            const raw = args[++i];
            simplifyTolerance = Number.parseFloat(raw);
            if (!Number.isFinite(simplifyTolerance) || simplifyTolerance < 0 || simplifyTolerance > 5) {
                throw new Error("--simplify must be a number from 0 to 5 degrees");
            }
        } else if (args[i] === "--min-points") {
            const raw = args[++i];
            minPoints = Number.parseInt(raw, 10);
            if (!Number.isInteger(minPoints) || minPoints < 2) {
                throw new Error("--min-points must be an integer of at least 2");
            }
        } else {
            throw new Error(`Unknown argument: ${args[i]}`);
        }
    }

    return { inputPath, outputPath, precision, simplifyTolerance, minPoints };
}

function assertArray(value, label) {
    if (!Array.isArray(value)) {
        throw new Error(`${label} must be an array`);
    }
}

function assertObject(value, label) {
    if (!value || Array.isArray(value) || typeof value !== "object") {
        throw new Error(`${label} must be an object`);
    }
}

function isCoordinate(value) {
    return Array.isArray(value)
        && value.length >= 2
        && typeof value[0] === "number"
        && typeof value[1] === "number";
}

function round(value, precision) {
    const factor = 10 ** precision;
    return Math.round(value * factor) / factor;
}

function convertPosition(position, precision) {
    const lon = position[0];
    const lat = position[1];

    if (lat < -90 || lat > 90) {
        throw new Error(`Latitude out of range after GeoJSON conversion: ${lat}`);
    }
    if (lon < -180 || lon > 180) {
        throw new Error(`Longitude out of range after GeoJSON conversion: ${lon}`);
    }

    return [round(lat, precision), round(lon, precision)];
}

function pointsEqual(a, b) {
    return a[0] === b[0] && a[1] === b[1];
}

function removeConsecutiveDuplicates(line) {
    const deduped = [];

    line.forEach(point => {
        if (deduped.length === 0 || !pointsEqual(deduped[deduped.length - 1], point)) {
            deduped.push(point);
        }
    });

    return deduped;
}

function uniquePointCount(line) {
    const points = new Set();
    line.forEach(point => points.add(`${point[0]},${point[1]}`));
    return points.size;
}

function squaredDistanceToSegment(point, start, end) {
    const x = point[1];
    const y = point[0];
    const x1 = start[1];
    const y1 = start[0];
    const x2 = end[1];
    const y2 = end[0];
    const dx = x2 - x1;
    const dy = y2 - y1;

    if (dx === 0 && dy === 0) {
        const px = x - x1;
        const py = y - y1;
        return px * px + py * py;
    }

    const t = Math.max(0, Math.min(1, ((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)));
    const projectedX = x1 + t * dx;
    const projectedY = y1 + t * dy;
    const px = x - projectedX;
    const py = y - projectedY;
    return px * px + py * py;
}

function simplifyLine(line, tolerance) {
    if (tolerance <= 0 || line.length <= 2) return line;

    const toleranceSquared = tolerance * tolerance;
    const keep = new Array(line.length).fill(false);
    const stack = [[0, line.length - 1]];
    keep[0] = true;
    keep[line.length - 1] = true;

    while (stack.length > 0) {
        const segment = stack.pop();
        const start = segment[0];
        const end = segment[1];
        let maxDistance = -1;
        let maxIndex = -1;

        for (let i = start + 1; i < end; i++) {
            const distance = squaredDistanceToSegment(line[i], line[start], line[end]);
            if (distance > maxDistance) {
                maxDistance = distance;
                maxIndex = i;
            }
        }

        if (maxDistance > toleranceSquared && maxIndex !== -1) {
            keep[maxIndex] = true;
            stack.push([start, maxIndex], [maxIndex, end]);
        }
    }

    return line.filter((_, index) => keep[index]);
}

function pushLine(output, coordinates, options, label) {
    assertArray(coordinates, label);

    const line = coordinates.map((position, index) => {
        if (!isCoordinate(position)) {
            throw new Error(`${label}[${index}] must be a GeoJSON coordinate [lon, lat]`);
        }

        return convertPosition(position, options.precision);
    });

    const simplified = removeConsecutiveDuplicates(simplifyLine(removeConsecutiveDuplicates(line), options.simplifyTolerance));

    if (simplified.length >= options.minPoints && uniquePointCount(simplified) >= options.minPoints) {
        output.push(simplified);
    }
}

function collectGeometry(geometry, output, options) {
    if (!geometry) return;
    assertObject(geometry, "GeoJSON geometry");

    switch (geometry.type) {
    case "LineString":
        pushLine(output, geometry.coordinates, options, "LineString coordinates");
        break;
    case "MultiLineString":
        assertArray(geometry.coordinates, "MultiLineString coordinates");
        geometry.coordinates.forEach((line, index) => pushLine(output, line, options, `MultiLineString coordinates[${index}]`));
        break;
    case "Polygon":
        assertArray(geometry.coordinates, "Polygon coordinates");
        geometry.coordinates.forEach((ring, index) => pushLine(output, ring, options, `Polygon coordinates[${index}]`));
        break;
    case "MultiPolygon":
        assertArray(geometry.coordinates, "MultiPolygon coordinates");
        geometry.coordinates.forEach((polygon, polygonIndex) => {
            assertArray(polygon, `MultiPolygon coordinates[${polygonIndex}]`);
            polygon.forEach((ring, ringIndex) => pushLine(output, ring, options, `MultiPolygon coordinates[${polygonIndex}][${ringIndex}]`));
        });
        break;
    case "GeometryCollection":
        assertArray(geometry.geometries, "GeometryCollection geometries");
        geometry.geometries.forEach(child => collectGeometry(child, output, options));
        break;
    default:
        throw new Error(`Unsupported GeoJSON geometry type: ${geometry.type}`);
    }
}

function collectCoastlines(document, options) {
    assertObject(document, "GeoJSON document");
    const output = [];

    if (document.type === "FeatureCollection") {
        assertArray(document.features, "FeatureCollection features");
        document.features.forEach((feature, index) => {
            assertObject(feature, `FeatureCollection features[${index}]`);
            collectGeometry(feature.geometry, output, options);
        });
    } else if (document.type === "Feature") {
        assertObject(document, "Feature");
        collectGeometry(document.geometry, output, options);
    } else {
        collectGeometry(document, output, options);
    }

    return output;
}

function formatNumber(value) {
    return Number.isInteger(value) ? String(value) : String(value).replace(/0+$/, "").replace(/\.$/, "");
}

function formatPoint(point) {
    return `[${formatNumber(point[0])}, ${formatNumber(point[1])}]`;
}

function formatOutput(coastlines, sourcePath) {
    const sourceName = path.basename(sourcePath);
    const lines = [
        "// Generated by tools/preprocess-coastlines.js.",
        `// Source: ${sourceName}`,
        "// Contract: array of polylines containing [lat, lon] pairs.",
        "",
        ".pragma library",
        "",
        "var coastlines = ["
    ];

    coastlines.forEach((polyline, index) => {
        const suffix = index === coastlines.length - 1 ? "" : ",";
        lines.push(`    [${polyline.map(formatPoint).join(", ")}]${suffix}`);
    });

    lines.push("]", "");
    return lines.join("\n");
}

function main() {
    const { inputPath, outputPath, precision, simplifyTolerance, minPoints } = parseArgs(process.argv);
    const input = JSON.parse(fs.readFileSync(inputPath, "utf8"));
    const coastlines = collectCoastlines(input, { precision, simplifyTolerance, minPoints });

    if (coastlines.length === 0) {
        throw new Error("No coastline polylines found in input");
    }

    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, formatOutput(coastlines, inputPath), "utf8");
    console.error(`Wrote ${coastlines.length} polylines to ${outputPath}`);
}

try {
    main();
} catch (error) {
    console.error(`preprocess-coastlines: ${error.message}`);
    process.exit(1);
}
