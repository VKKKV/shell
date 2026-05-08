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

`tools/fixtures/coastline-sample.geojson` is a tiny tool fixture only. It is not imported by the shell and does not replace the active runtime data in `components/EarthCoastlineData.js`.

## Future Natural Earth 10m Flow

Do not check in unverified large generated data as part of the scaffold. For the future high-precision slice:

1. Download or otherwise obtain Natural Earth 10m coastline GeoJSON outside the runtime shell path.
2. Record the exact source URL/version and license notes in the follow-up task.
3. Run `tools/preprocess-coastlines.js` against the reviewed GeoJSON source.
4. Inspect generated point counts and file size before replacing `components/EarthCoastlineData.js`.
5. Smoke-test `components/RotatingGlobe.qml` interactions: activation, horizontal drag rotation, signal nodes, grid, and optional location marker.
6. Commit only the reviewed generated JS module, not ad-hoc downloads or temporary source archives.

This keeps the globe fully offline at runtime while making the future data replacement repeatable.
