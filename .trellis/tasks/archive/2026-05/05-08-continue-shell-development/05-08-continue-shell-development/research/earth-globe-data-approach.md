# Research: Earth globe coastline data approach

- **Query**: Research whether the proposed Earth module optimization is a good fit for this Quickshell/QML project: Natural Earth coastline data embedded into QML/JS arrays plus Canvas2D rendering with procedural terrain/noise. Focus on Natural Earth licensing/attribution, practical data size for 10m/50m/110m coastlines, preprocessing approaches from GeoJSON/Shapefile to simplified lat/lon arrays, performance implications for QML Canvas2D, and a recommended MVP slice that avoids overengineering.
- **Scope**: mixed
- **Date**: 2026-05-08

## Findings

### Files Found

| File Path | Description |
|---|---|
| `components/RotatingGlobe.qml` | Current Earth/globe implementation; embeds hand-authored coastline arrays and renders them in a QML `Canvas`. |
| `modules/hud/EarthExpansionPanel.qml` | Uses `RotatingGlobe` for the central Earth panel and wires location metadata from `EarthLocationService`. |
| `modules/hud/LeftTacticalPanel.qml` | Uses compact `RotatingGlobe` entry point for Earth geolocation HUD card. |
| `modules/hud/HudLayout.qml` | Places `EarthExpansionPanel` in the HUD layout. |

### Code Patterns

- `components/RotatingGlobe.qml:29-40` projects latitude/longitude to a pseudo-orthographic globe using `rotationPhase`, `Math.sin/cos`, and a simple visibility cutoff.
- `components/RotatingGlobe.qml:42-62` draws each coastline as a visible-segment polyline, reopening the path when a point falls behind the globe.
- `components/RotatingGlobe.qml:74-215` currently embeds coastline-like data directly as QML/JS arrays. The existing data is small and hand-curated rather than generated from a dataset.
- `components/RotatingGlobe.qml:225-400` renders ocean fill, grids, land fill, coastline strokes, signal nodes, terminator, rings, marker, and labels in one `Canvas.onPaint` handler.
- `components/RotatingGlobe.qml:217-223` animates `rotationPhase` continuously, and `components/RotatingGlobe.qml:403-409` calls `globeCanvas.requestPaint()` on rotation, size, expansion, and location changes.

### Natural Earth Licensing / Attribution

- Natural Earth Terms of Use states: "All versions of Natural Earth raster + vector map data found on this website are in the public domain." It allows modifying, electronic dissemination, and commercial use.
- The same page states no permission is needed and crediting the authors is unnecessary.
- Suggested optional attribution text from Natural Earth:
  - Short: `Made with Natural Earth.`
  - Long: `Made with Natural Earth. Free vector and raster map data @ naturalearthdata.com.`
- Practical implication: embedding derived/simplified coastline coordinates in this project is license-compatible; optional attribution can be placed in docs or an about/settings surface if desired.

### Practical Data Size

Natural Earth download pages report compressed shapefile zip sizes:

| Scale | Natural Earth page size | Download/version observed | Measured zip bytes | Measured `.shp` bytes | Records | Parts | Points |
|---|---:|---|---:|---:|---:|---:|---:|
| 10m coastline | 2.93 MB | `ne_10m_coastline.zip`, v4.1.0 | 3,069,451 | 6,806,860 | 4,133 | 4,133 | 410,957 |
| 50m coastline | 445.25 KB | `ne_50m_coastline.zip`, v4.0.0 | 455,936 | 1,046,728 | 1,428 | 1,429 | 60,416 |
| 110m coastline | 83.35 KB | `ne_110m_coastline.zip`, v4.1.0 | 85,352 | 89,652 | 134 | 134 | 5,128 |

Measurement method: downloaded official Natural Earth coastline zips from `https://naciscdn.org/naturalearth/{scale}/physical/ne_{scale}_coastline.zip`, parsed the `.shp` header/records, and counted PolyLine points/parts.

Approximate uncompressed coordinate payload if converted to raw JavaScript numbers:

- 110m: about 5k points. Fine for embedded QML arrays.
- 50m: about 60k points. Potentially acceptable only if aggressively simplified/culled for a small HUD globe; otherwise it adds parse and paint cost for limited visual gain.
- 10m: about 411k points. Poor fit for direct QML array embedding and per-frame Canvas redraw.

### Preprocessing Approaches

Viable preprocessing flow from official Natural Earth source to QML-friendly arrays:

1. Download Natural Earth coastline as Shapefile or GeoJSON.
2. Simplify offline, not at QML runtime.
3. Convert geometry into arrays shaped like the current `RotatingGlobe.qml` expects: `[[lat, lon], ...]` per polyline, or a compact JS module exporting `coastlines`.
4. Optionally filter tiny detached islands/short polylines for HUD readability.
5. Quantize/round coordinates to a small decimal precision appropriate for a 180-360 px globe.

External tooling references:

- TopoJSON Simplify describes topology-preserving simplification and filtering for smaller files and faster rendering. It exposes `presimplify`, `simplify`, `filter`, and CLI `toposimplify`, including spherical-area simplification for lon/lat data.
- Mapshaper command docs have moved to `https://mapshaper.org/docs/reference.html`; mapshaper is a common CLI path for `-simplify`, `-filter`, and `-o format=geojson` style preprocessing from shapefile/GeoJSON.

QML-facing representation notes:

- Keep generated data separate from drawing logic if possible, e.g. a `.js` data module imported by `RotatingGlobe.qml`, but still under source control as static data.
- Match current `[lat, lon]` ordering because `drawPolyline()` calls `project(points[i][0], points[i][1])`.
- Avoid loading/parsing large GeoJSON at runtime; QML should receive already-minimized numeric arrays.

### QML Canvas2D Performance Implications

- Qt `Canvas` supports only 2D context and paints from `onPaint` after `requestPaint()` / `markDirty()`.
- Qt 6 docs state the default render target is `Canvas.Image`, a `QImage` buffer; with accelerated graphics APIs each update can require a texture upload.
- Qt docs explicitly warn: "In general large canvases, frequent updates, and animation should be avoided with the Canvas.Image render target," and note JavaScript `Context2D` is more expensive/less performant than C++ `QQuickPaintedItem`/`QPainter` for heavier drawing.
- This project's globe is animated continuously (`NumberAnimation on rotationPhase` plus `onRotationPhaseChanged: globeCanvas.requestPaint()`), so coastline point count directly affects repeated JavaScript projection and path drawing cost.
- Procedural terrain/noise generated per paint would multiply the cost. If used, it should be very low resolution, deterministic, and/or cached rather than recomputed across the full globe every frame.

### Recommended MVP Slice

Recommended MVP: use Natural Earth 110m coastline only, preprocess offline into a small static `[lat, lon]` array module, replace or augment the current hand-authored coastline data, and keep terrain/noise minimal/cached or defer it.

MVP boundaries that avoid overengineering:

- Start with 110m coastline because it is about 5,128 points and visually sufficient for a small rotating HUD globe.
- Do not embed 10m coastline directly; the measured about 410,957 points is not a good match for continuous QML Canvas animation.
- Avoid 50m until there is a demonstrated visual need; measured about 60,416 points may still be high for per-frame QML Canvas projection.
- Keep preprocessing as a one-time script or documented manual pipeline; do not add runtime GIS parsing.
- Keep Natural Earth attribution optional but add a lightweight note if generated data is committed.
- Treat procedural terrain/noise as a separate visual layer: a simple shaded/ocean gradient or sparse cached texture is a safer first slice than dynamic full-globe noise.

### External References

- [Natural Earth Terms of Use](https://www.naturalearthdata.com/about/terms-of-use/) — public domain status, no permission/credit required, optional attribution text.
- [Natural Earth 10m Coastline](https://www.naturalearthdata.com/downloads/10m-physical-vectors/10m-coastline/) — 2.93 MB shapefile download, includes major islands, v4.1.0.
- [Natural Earth 50m Coastline](https://www.naturalearthdata.com/downloads/50m-physical-vectors/50m-coastline/) — 445.25 KB shapefile download, generalized from 10m, v4.0.0.
- [Natural Earth 110m Coastline](https://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-coastline/) — 83.35 KB shapefile download, v4.1.0.
- [Qt Canvas QML Type](https://doc.qt.io/qt-6/qml-qtquick-canvas.html) — Canvas2D behavior, render target/strategy, and performance cautions for large/frequently updated canvases.
- [TopoJSON Simplify](https://github.com/topojson/topojson-simplify) — topology-preserving simplification/filtering for smaller files and faster rendering.
- [Mapshaper command reference](https://mapshaper.org/docs/reference.html) — CLI preprocessing reference location.

### Related Specs

- `.trellis/spec/frontend/index.md` — frontend guidelines index exists; not read for this research-only task.

## Caveats / Not Found

- The current task PRD is for a completed docs/HUD readability slice, not specifically for Earth dataset replacement; this research was requested as a separate topic under the active task research directory.
- Exact generated `.js` file size depends on simplification threshold, numeric precision, formatting/minification, and whether tiny islands are filtered.
- No runtime benchmark was performed; performance assessment is based on Qt Canvas documentation, current code structure, and measured point counts.
