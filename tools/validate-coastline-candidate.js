#!/usr/bin/env node

const fs = require("fs");
const path = require("path");
const { inspectFile } = require("./inspect-coastlines.js");

const REQUIRED_STRING_FIELDS = [
    "candidateName",
    "sourceUrl",
    "naturalEarthVersion",
    "resolution",
    "licenseNote",
    "inputPath",
    "generationCommand",
    "generatedOutputPath",
    "inspectionCommand",
    "reviewerNotes"
];

const REQUIRED_SMOKE_CHECKS = [
    "git diff --check",
    "qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml",
    "timeout 8s quickshell -p ."
];

function usage() {
    console.error(`Usage: node tools/validate-coastline-candidate.js <manifest.json> [--check-output]

Validates a local Natural Earth coastline candidate review manifest.
Use --check-output to inspect the referenced generated JS output and compare
the recorded inspectorStats values.`);
}

function parseArgs(argv) {
    const args = argv.slice(2);
    if (args.length < 1 || args.includes("--help") || args.includes("-h")) {
        usage();
        process.exit(args.length < 1 ? 1 : 0);
    }

    const manifestPath = args[0];
    let checkOutput = false;

    for (let i = 1; i < args.length; i++) {
        if (args[i] === "--check-output") {
            checkOutput = true;
        } else {
            throw new Error(`Unknown argument: ${args[i]}`);
        }
    }

    return { manifestPath, checkOutput };
}

function assertObject(value, label) {
    if (!value || Array.isArray(value) || typeof value !== "object") {
        throw new Error(`${label} must be an object`);
    }
}

function assertStringField(manifest, field) {
    if (typeof manifest[field] !== "string" || manifest[field].trim().length === 0) {
        throw new Error(`${field} must be a non-empty string`);
    }
}

function assertNumberField(value, label) {
    if (typeof value !== "number" || !Number.isFinite(value)) {
        throw new Error(`${label} must be a finite number`);
    }
}

function assertExactNumber(value, expected, label) {
    if (value !== expected) {
        throw new Error(`${label} mismatch: manifest has ${value}, inspected output has ${expected}`);
    }
}

function resolveManifestPath(manifestPath, candidatePath) {
    if (path.isAbsolute(candidatePath)) return candidatePath;
    return path.resolve(path.dirname(manifestPath), candidatePath);
}

function validateSmokeChecks(smokeChecks) {
    if (!Array.isArray(smokeChecks)) {
        throw new Error("smokeChecks must be an array");
    }

    smokeChecks.forEach((check, index) => {
        if (typeof check === "string") return;
        assertObject(check, `smokeChecks[${index}]`);
        if (typeof check.command !== "string" || check.command.trim().length === 0) {
            throw new Error(`smokeChecks[${index}].command must be a non-empty string`);
        }
        if (typeof check.status !== "string" || check.status.trim().length === 0) {
            throw new Error(`smokeChecks[${index}].status must be a non-empty string`);
        }
    });

    REQUIRED_SMOKE_CHECKS.forEach(requiredCommand => {
        const found = smokeChecks.some(check => {
            if (typeof check === "string") return check === requiredCommand;
            if (check && typeof check === "object") return check.command === requiredCommand;
            return false;
        });

        if (!found) {
            throw new Error(`smokeChecks must include: ${requiredCommand}`);
        }
    });
}

function validateInspectorStats(stats) {
    assertObject(stats, "inspectorStats");
    assertNumberField(stats.polylines, "inspectorStats.polylines");
    assertNumberField(stats.points, "inspectorStats.points");
    assertNumberField(stats.byteSize, "inspectorStats.byteSize");
    assertNumberField(stats.averagePointsPerPolyline, "inspectorStats.averagePointsPerPolyline");
    assertNumberField(stats.shortPolylineCount, "inspectorStats.shortPolylineCount");
    assertObject(stats.bounds, "inspectorStats.bounds");
    assertNumberField(stats.bounds.minLat, "inspectorStats.bounds.minLat");
    assertNumberField(stats.bounds.maxLat, "inspectorStats.bounds.maxLat");
    assertNumberField(stats.bounds.minLon, "inspectorStats.bounds.minLon");
    assertNumberField(stats.bounds.maxLon, "inspectorStats.bounds.maxLon");
    assertObject(stats.longestPolyline, "inspectorStats.longestPolyline");
    assertNumberField(stats.longestPolyline.index, "inspectorStats.longestPolyline.index");
    assertNumberField(stats.longestPolyline.points, "inspectorStats.longestPolyline.points");
}

function compareStats(recorded, inspected) {
    assertExactNumber(recorded.polylines, inspected.polylines, "inspectorStats.polylines");
    assertExactNumber(recorded.points, inspected.points, "inspectorStats.points");
    assertExactNumber(recorded.byteSize, inspected.byteSize, "inspectorStats.byteSize");
    assertExactNumber(recorded.bounds.minLat, inspected.bounds.minLat, "inspectorStats.bounds.minLat");
    assertExactNumber(recorded.bounds.maxLat, inspected.bounds.maxLat, "inspectorStats.bounds.maxLat");
    assertExactNumber(recorded.bounds.minLon, inspected.bounds.minLon, "inspectorStats.bounds.minLon");
    assertExactNumber(recorded.bounds.maxLon, inspected.bounds.maxLon, "inspectorStats.bounds.maxLon");
    assertExactNumber(recorded.longestPolyline.index, inspected.longestPolyline.index, "inspectorStats.longestPolyline.index");
    assertExactNumber(recorded.longestPolyline.points, inspected.longestPolyline.points, "inspectorStats.longestPolyline.points");
    assertExactNumber(recorded.averagePointsPerPolyline, inspected.averagePointsPerPolyline, "inspectorStats.averagePointsPerPolyline");
    assertExactNumber(recorded.shortPolylineCount, inspected.shortPolylineCount, "inspectorStats.shortPolylineCount");
}

function validateManifest(manifest, manifestPath, checkOutput) {
    assertObject(manifest, "Manifest");
    REQUIRED_STRING_FIELDS.forEach(field => assertStringField(manifest, field));
    validateInspectorStats(manifest.inspectorStats);
    validateSmokeChecks(manifest.smokeChecks);

    if (checkOutput) {
        const outputPath = resolveManifestPath(manifestPath, manifest.generatedOutputPath);
        if (!fs.existsSync(outputPath)) {
            throw new Error(`generatedOutputPath does not exist: ${outputPath}`);
        }

        compareStats(manifest.inspectorStats, inspectFile(outputPath));
    }
}

function main() {
    const { manifestPath, checkOutput } = parseArgs(process.argv);
    const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
    validateManifest(manifest, manifestPath, checkOutput);
    console.log(`Coastline candidate manifest OK: ${manifestPath}`);
}

if (require.main === module) {
    try {
        main();
    } catch (error) {
        console.error(`validate-coastline-candidate: ${error.message}`);
        process.exit(1);
    }
} else {
    module.exports = {
        compareStats,
        validateInspectorStats,
        validateManifest,
        validateSmokeChecks
    };
}
