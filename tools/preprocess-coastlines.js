#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const DEFAULT_PRECISION = 3;

function usage() {
    console.error(`Usage: node tools/preprocess-coastlines.js <input.geojson> <output.js> [--precision <digits>]

Converts offline GeoJSON-like coastline data into the JS array contract used by
components/EarthCoastlineData.js:

    var coastlines = [
        [[lat, lon], [lat, lon]]
    ]

Supported geometries: LineString, MultiLineString, Polygon, MultiPolygon,
GeometryCollection, Feature, and FeatureCollection. Input coordinates must use
standard GeoJSON order: [longitude, latitude].`);
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

    for (let i = 2; i < args.length; i++) {
        if (args[i] === "--precision") {
            const raw = args[++i];
            precision = Number.parseInt(raw, 10);
            if (!Number.isInteger(precision) || precision < 0 || precision > 8) {
                throw new Error("--precision must be an integer from 0 to 8");
            }
        } else {
            throw new Error(`Unknown argument: ${args[i]}`);
        }
    }

    return { inputPath, outputPath, precision };
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

function pushLine(output, coordinates, precision, label) {
    assertArray(coordinates, label);

    const line = coordinates.map((position, index) => {
        if (!isCoordinate(position)) {
            throw new Error(`${label}[${index}] must be a GeoJSON coordinate [lon, lat]`);
        }

        return convertPosition(position, precision);
    });

    if (line.length >= 2) {
        output.push(line);
    }
}

function collectGeometry(geometry, output, precision) {
    if (!geometry) return;
    assertObject(geometry, "GeoJSON geometry");

    switch (geometry.type) {
    case "LineString":
        pushLine(output, geometry.coordinates, precision, "LineString coordinates");
        break;
    case "MultiLineString":
        assertArray(geometry.coordinates, "MultiLineString coordinates");
        geometry.coordinates.forEach((line, index) => pushLine(output, line, precision, `MultiLineString coordinates[${index}]`));
        break;
    case "Polygon":
        assertArray(geometry.coordinates, "Polygon coordinates");
        geometry.coordinates.forEach((ring, index) => pushLine(output, ring, precision, `Polygon coordinates[${index}]`));
        break;
    case "MultiPolygon":
        assertArray(geometry.coordinates, "MultiPolygon coordinates");
        geometry.coordinates.forEach((polygon, polygonIndex) => {
            assertArray(polygon, `MultiPolygon coordinates[${polygonIndex}]`);
            polygon.forEach((ring, ringIndex) => pushLine(output, ring, precision, `MultiPolygon coordinates[${polygonIndex}][${ringIndex}]`));
        });
        break;
    case "GeometryCollection":
        assertArray(geometry.geometries, "GeometryCollection geometries");
        geometry.geometries.forEach(child => collectGeometry(child, output, precision));
        break;
    default:
        throw new Error(`Unsupported GeoJSON geometry type: ${geometry.type}`);
    }
}

function collectCoastlines(document, precision) {
    assertObject(document, "GeoJSON document");
    const output = [];

    if (document.type === "FeatureCollection") {
        assertArray(document.features, "FeatureCollection features");
        document.features.forEach((feature, index) => {
            assertObject(feature, `FeatureCollection features[${index}]`);
            collectGeometry(feature.geometry, output, precision);
        });
    } else if (document.type === "Feature") {
        assertObject(document, "Feature");
        collectGeometry(document.geometry, output, precision);
    } else {
        collectGeometry(document, output, precision);
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
    const { inputPath, outputPath, precision } = parseArgs(process.argv);
    const input = JSON.parse(fs.readFileSync(inputPath, "utf8"));
    const coastlines = collectCoastlines(input, precision);

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
