# Earth Coastline Preprocessing

The rotating Earth globe renders offline coastline vectors from `components/EarthCoastlineData.js`. Its runtime contract is intentionally small and stable:

```js
var coastlines = [
    [[lat, lon], [lat, lon]]
]
```

Each entry is a polyline. Each point is a `[latitude, longitude]` pair in degrees. `components/RotatingGlobe.qml` imports that array directly and must not fetch map data at runtime.

## Scaffold Tool

Use the Node.js script below to convert GeoJSON-like source data into the same QML/JS module shape:

```bash
node tools/preprocess-coastlines.js tools/fixtures/coastline-sample.geojson /tmp/coastline-sample.generated.js
```

The input uses normal GeoJSON coordinate order, `[longitude, latitude]`. The generated output flips each coordinate into the runtime `[lat, lon]` contract.

Supported GeoJSON object types:

- `FeatureCollection`
- `Feature`
- `LineString`
- `MultiLineString`
- `Polygon`
- `MultiPolygon`
- `GeometryCollection`

Optional precision control:

```bash
node tools/preprocess-coastlines.js input.geojson output.js --precision 4
```

The default precision is 3 decimal places. This is enough for the current tactical HUD scale while keeping generated arrays compact.

Optional simplification and minimum-length filtering are available for reviewed runtime candidates:

```bash
node tools/preprocess-coastlines.js input.geojson output.js --precision 2 --simplify 0.03 --min-points 2
```

`--simplify` uses deterministic Ramer-Douglas-Peucker simplification in latitude/longitude degree space after coordinate conversion and duplicate removal. Keep the tolerance explicit in the manifest because it changes visual fidelity and Canvas repaint cost.

`tools/fixtures/coastline-sample.geojson` is a tiny tool fixture only. It is not imported by the shell and does not replace the active runtime data in `components/EarthCoastlineData.js`.

## Current Runtime Dataset

`components/EarthCoastlineData.js` now contains a reviewed Natural Earth 50m coastline runtime replacement, not the original hand-authored polygons.

- Source: `https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_coastline.geojson`
- Dataset: Natural Earth `ne_50m_coastline`, public domain
- Download date: 2026-05-09
- Local-only candidate path: `/tmp/opencode/coastline-candidates/ne-50m-coastline-2026-05-09/`
- Generation command:

  ```bash
  node tools/preprocess-coastlines.js /tmp/opencode/coastline-candidates/ne-50m-coastline-2026-05-09/input.geojson /tmp/opencode/coastline-candidates/ne-50m-coastline-2026-05-09/generated.js --precision 2 --simplify 0.03
  ```

- Inspector stats:
  - polylines: 1,425
  - points: 28,853
  - generated JS size: 492,359 bytes before the extra provenance header in the committed runtime file; 492,929 bytes in the committed runtime file
  - bounds: latitude `-85.19..83.6`, longitude `-180..180`
  - longest polyline: `#1388` with 5,183 points
  - short polylines: 0

The generator drops degenerate two-point lines that collapse to one unique coordinate after precision rounding and simplification.

Raw downloads and GeoJSON input remain local-only scratch artifacts; only the compact runtime JS module is committed.

## Future Natural Earth 10m Flow

Do not check in unverified large generated data as part of a candidate review. For a future 10m high-precision slice:

1. Download or otherwise obtain Natural Earth 10m coastline GeoJSON outside the runtime shell path.
2. Record the exact source URL/version and license notes in the follow-up task.
3. Run `tools/preprocess-coastlines.js` against the reviewed GeoJSON source.
4. Inspect generated point counts, coordinate bounds, longest polyline, and file size before replacing `components/EarthCoastlineData.js`.
5. Smoke-test `components/RotatingGlobe.qml` interactions: activation, horizontal drag rotation, signal nodes, grid, and optional location marker.
6. Commit only the reviewed generated JS module, not ad-hoc downloads or temporary source archives.

This keeps the globe fully offline at runtime while making the future data replacement repeatable.

## Generated Data Inspection

Use the dependency-free inspector on generated QML/JS modules before considering them for runtime replacement:

```bash
node tools/inspect-coastlines.js /tmp/coastline-sample.generated.js
```

For machine-readable review notes:

```bash
node tools/inspect-coastlines.js /tmp/coastline-sample.generated.js --json
```

The inspector validates the generated module contract and reports:

- polyline count
- total point count
- UTF-8 file size in bytes
- min/max latitude and longitude
- longest polyline index and length
- average points per polyline
- any short polylines with fewer than two points

The command is an evaluation aid only. It does not fetch data and does not change active runtime coastline data.

## Natural Earth Review Checklist

Before checking in any Natural Earth 10m-generated replacement for `components/EarthCoastlineData.js`, record the following in the task or review notes:

- Source URL and dataset name, including whether the source is Natural Earth `ne_10m_coastline` or another reviewed file.
- Dataset version or download date.
- License/public-domain note. Natural Earth data is generally public domain, but record the exact notice used by the downloaded source.
- Local input path used for generation. Keep raw downloads and temporary converted GeoJSON outside the runtime shell path unless they are intentionally reviewed and committed.
- Generation command, including precision. Example:

  ```bash
  node tools/preprocess-coastlines.js /tmp/ne_10m_coastline.geojson /tmp/ne_10m_coastline.generated.js --precision 3
  ```

- Inspection command and output. Example:

  ```bash
  node tools/inspect-coastlines.js /tmp/ne_10m_coastline.generated.js
  ```

- Size/performance review before replacement:
  - Point count should intentionally target the high-detail roadmap, roughly 10K+ coordinate points, instead of accidentally importing only a tiny sample.
  - Generated JS size should be reviewed against Canvas2D startup and repaint cost; split or simplify the data if local smoke testing becomes visibly slow.
  - Coordinate bounds should stay within latitude `-90..90` and longitude `-180..180`.
  - Longest polyline length should be reviewed for rendering hot spots if drag repainting stutters.
- Required smoke checks after a candidate replacement:
  - `git diff --check`
  - `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`
  - `timeout 8s quickshell -p .`
  - Manual globe checks: click/activate, horizontal drag rotation, signal nodes, grid, optional location marker, and no runtime map-data fetches.

## Candidate Review Workflow

Generated Natural Earth candidates must be reviewed as local artifacts before any runtime data replacement. Keep raw downloads, converted GeoJSON, and large generated JS modules outside the repo unless a follow-up replacement task explicitly approves them. `/tmp/opencode/coastline-candidates/<candidate-name>/` is the preferred scratch location for agent runs.

Suggested local layout:

```text
/tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/
├── input.geojson
├── generated.js
└── manifest.json
```

The manifest records provenance and review evidence. Start from this shape:

```json
{
    "candidateName": "ne-10m-coastline-YYYY-MM-DD",
    "sourceUrl": "https://...",
    "naturalEarthVersion": "Natural Earth 10m, downloaded YYYY-MM-DD",
    "resolution": "10m",
    "licenseNote": "Natural Earth public-domain notice copied from the source page.",
    "inputPath": "/tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/input.geojson",
    "generationCommand": "node tools/preprocess-coastlines.js /tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/input.geojson /tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/generated.js --precision 3",
    "generatedOutputPath": "/tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/generated.js",
    "inspectionCommand": "node tools/inspect-coastlines.js /tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/generated.js --json",
    "inspectorStats": {
        "polylines": 0,
        "points": 0,
        "byteSize": 0,
        "bounds": {
            "minLat": 0,
            "maxLat": 0,
            "minLon": 0,
            "maxLon": 0
        },
        "longestPolyline": {
            "index": 0,
            "points": 0
        },
        "averagePointsPerPolyline": 0,
        "shortPolylineCount": 0
    },
    "smokeChecks": [
        {
            "command": "git diff --check",
            "status": "pending"
        },
        {
            "command": "qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml",
            "status": "pending"
        },
        {
            "command": "timeout 8s quickshell -p .",
            "status": "pending"
        }
    ],
    "reviewerNotes": "Record size/performance concerns, visual review notes, and whether this candidate is approved for a runtime replacement task."
}
```

Validate the manifest shape without touching runtime data:

```bash
node tools/validate-coastline-candidate.js /tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/manifest.json
```

When the generated output file is present locally, compare the manifest's recorded `inspectorStats` against the file:

```bash
node tools/validate-coastline-candidate.js /tmp/opencode/coastline-candidates/ne-10m-coastline-YYYY-MM-DD/manifest.json --check-output
```

`tools/fixtures/coastline-candidate-sample.manifest.json` is a tiny validator fixture for the checked-in sample pipeline. It is not a Natural Earth candidate and is not imported by the shell.
