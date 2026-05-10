# High-Precision Coastline Candidate Review

## Natural Earth 10m Candidate

- Candidate: `ne-10m-coastline-2026-05-10`
- Source URL: `https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_10m_coastline.geojson`
- Dataset/license: Natural Earth `ne_10m_coastline`, public domain notice from the Natural Earth source family.
- Local-only candidate directory: `/tmp/opencode/coastline-candidates/ne-10m-coastline-2026-05-10/`
- Raw input and generated candidate were intentionally kept outside the repo.

Generation command:

```bash
node tools/preprocess-coastlines.js /tmp/opencode/coastline-candidates/ne-10m-coastline-2026-05-10/input.geojson /tmp/opencode/coastline-candidates/ne-10m-coastline-2026-05-10/generated.js --precision 2 --simplify 0.03
```

Inspection command:

```bash
node tools/inspect-coastlines.js /tmp/opencode/coastline-candidates/ne-10m-coastline-2026-05-10/generated.js --json
```

Inspector stats:

```json
{
  "polylines": 3690,
  "points": 70823,
  "byteSize": 1209415,
  "bounds": {
    "minLat": -85.22,
    "maxLat": 83.63,
    "minLon": -180,
    "maxLon": 180
  },
  "longestPolyline": {
    "index": 248,
    "points": 2557
  },
  "averagePointsPerPolyline": 19.19,
  "shortPolylineCount": 0
}
```

Manifest validation:

```bash
node tools/validate-coastline-candidate.js /tmp/opencode/coastline-candidates/ne-10m-coastline-2026-05-10/manifest.json --check-output
```

Result: passed.

## Runtime Decision

Rejected the 10m candidate for runtime replacement in this slice. Compared with the current committed Natural Earth 50m runtime data (1,425 polylines, 28,853 points, 492,929 bytes including provenance header), the reviewed 10m candidate is about 2.59x more polylines, 2.45x more points, and 2.45x bytes. That cost lands directly on the central Earth panel activation path because `RotatingGlobe.qml` imports the JS array synchronously and repaints the Canvas on activation/drag.

The current 50m dataset remains the better trade-off for the HUD scale. The implementation therefore keeps `components/EarthCoastlineData.js` unchanged and tightens expanded-mode renderer budgets in `components/RotatingGlobe.qml`:

- Expanded coastline point stride now samples every second coastline point instead of every point.
- Expanded land-fill pass now processes every second polyline instead of every polyline.
- Expanded procedural terrain point stride now samples every fourth point instead of every second point.
- Major coastline underlay threshold increased from 44 to 72 points to reduce duplicate stroke work on small island outlines.

This preserves compact left-panel fidelity and keeps the central panel visually rich while reducing open/activation repaint pressure.

## Smoke Evidence

- Candidate manifest validation with `--check-output`: passed.
- `git diff --check`: passed.
- `qmllint shell.qml modules/**/*.qml components/*.qml services/*.qml theme/*.qml`: passed.
- `timeout 8s quickshell -p .`: passed; logs included `Configuration Loaded`.
