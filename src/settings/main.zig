const std = @import("std");

const Settings = struct {
    scanlines_enabled: bool = true,
    intensity: f64 = 1.0,
    font_scale: f64 = 1.0,
    panel_opacity: f64 = 0.8,
    scanline_strength: f64 = 1.0,
    border_opacity: f64 = 1.0,
    dim_text_opacity: f64 = 1.0,
    line_contrast: f64 = 1.0,
    density: []const u8 = "normal",
    profile: []const u8 = "amber",
    accent_color: []const u8 = "#F2C94C",
    background_mode: []const u8 = "void",
    live_data_enabled: bool = true,
    network_geolocation_enabled: bool = false,
    update_interval_ms: i64 = 5000,
    left_visible: bool = true,
    center_visible: bool = true,
    right_visible: bool = true,
};

const current_settings_version = 1;

const defaults_json =
    \\{
    \\  "version": 1,
    \\  "visual": {
    \\    "scanlinesEnabled": true,
    \\    "intensity": 1.0,
    \\    "fontScale": 1.0,
    \\    "panelOpacity": 0.8,
    \\    "scanlineStrength": 1.0,
    \\    "borderOpacity": 1.0,
    \\    "dimTextOpacity": 1.0,
    \\    "lineContrast": 1.0,
    \\    "density": "normal",
    \\    "profile": "amber",
    \\    "accentColor": "#F2C94C",
    \\    "backgroundMode": "void"
    \\  },
    \\  "data": {
    \\    "liveDataEnabled": true,
    \\    "networkGeolocationEnabled": false,
    \\    "updateIntervalMs": 5000
    \\  },
    \\  "panels": {
    \\    "leftVisible": true,
    \\    "centerVisible": true,
    \\    "rightVisible": true
    \\  }
    \\}
;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    const args = try init.minimal.args.toSlice(init.arena.allocator());
    const command = if (args.len > 1) args[1] else "defaults";

    if (std.mem.eql(u8, command, "defaults")) {
        try writeStdout(io, defaults_json ++ "\n");
    } else if (std.mem.eql(u8, command, "read")) {
        try readSettings(allocator, io, init.environ_map);
    } else if (std.mem.eql(u8, command, "write")) {
        if (args.len < 3)
            return error.MissingJsonPayload;
        const payload = args[2];
        try writeSettings(allocator, io, init.environ_map, payload);
    } else {
        try writeStderr(io, "usage: void-shell-settings [defaults|read|write '<json>']\n");
        return error.UnknownCommand;
    }
}

fn settingsPath(allocator: std.mem.Allocator, environ_map: *const std.process.Environ.Map) ![]u8 {
    if (environ_map.get("XDG_CONFIG_HOME")) |config_home|
        return std.fs.path.join(allocator, &.{ config_home, "void-shell", "settings.json" });
    const home = environ_map.get("HOME") orelse return error.EnvironmentVariableMissing;
    return std.fs.path.join(allocator, &.{ home, ".config", "void-shell", "settings.json" });
}

fn ensureSettingsDir(allocator: std.mem.Allocator, io: std.Io, path: []const u8) void {
    const dir_path = std.fs.path.dirname(path) orelse return;
    std.Io.Dir.cwd().createDirPath(io, dir_path) catch |err| {
        writeStderrAlloc(allocator, io, "warning: failed to create settings directory: {s}\n", .{@errorName(err)}) catch {};
        if (err == error.PathAlreadyExists)
            return;
    };
}

fn readSettings(allocator: std.mem.Allocator, io: std.Io, environ_map: *const std.process.Environ.Map) !void {
    const path = try settingsPath(allocator, environ_map);
    defer allocator.free(path);

    const data = std.Io.Dir.cwd().readFileAlloc(io, path, allocator, .limited(1024 * 1024)) catch |err| switch (err) {
        error.FileNotFound => {
            try writeStdout(io, defaults_json ++ "\n");
            return;
        },
        else => return err,
    };
    defer allocator.free(data);
    const normalized = normalizeSettings(allocator, data) catch |err| switch (err) {
        error.InvalidSettingsJson, error.UnsupportedSettingsVersion => {
            try writeStdout(io, defaults_json ++ "\n");
            return;
        },
        else => return err,
    };
    defer allocator.free(normalized);

    try writeStdout(io, normalized);
    try writeStdout(io, "\n");
}

fn writeSettings(allocator: std.mem.Allocator, io: std.Io, environ_map: *const std.process.Environ.Map, payload: []const u8) !void {
    const normalized = try normalizeSettings(allocator, payload);
    defer allocator.free(normalized);

    const path = try settingsPath(allocator, environ_map);
    defer allocator.free(path);
    ensureSettingsDir(allocator, io, path);

    var file = try std.Io.Dir.cwd().createFile(io, path, .{ .truncate = true });
    defer file.close(io);
    try file.writeStreamingAll(io, normalized);
    try file.writeStreamingAll(io, "\n");
    try writeStdout(io, normalized);
    try writeStdout(io, "\n");
}

fn normalizeSettings(allocator: std.mem.Allocator, payload: []const u8) ![]u8 {
    var parsed = try std.json.parseFromSlice(std.json.Value, allocator, payload, .{});
    defer parsed.deinit();

    var settings = Settings{};
    const root = parsed.value;
    if (root != .object)
        return error.InvalidSettingsJson;

    const version = integerField(root, "version") orelse current_settings_version;
    if (version > current_settings_version)
        return error.UnsupportedSettingsVersion;

    if (objectField(root, "visual")) |visual| {
        settings.scanlines_enabled = boolField(visual, "scanlinesEnabled") orelse settings.scanlines_enabled;
        settings.intensity = clampFloat(numberField(visual, "intensity") orelse settings.intensity, 0.5, 1.5);
        settings.font_scale = clampFloat(numberField(visual, "fontScale") orelse settings.font_scale, 0.85, 1.25);
        settings.panel_opacity = clampFloat(numberField(visual, "panelOpacity") orelse settings.panel_opacity, 0.55, 0.95);
        settings.scanline_strength = clampFloat(numberField(visual, "scanlineStrength") orelse settings.scanline_strength, 0.25, 1.75);
        settings.border_opacity = clampFloat(numberField(visual, "borderOpacity") orelse settings.border_opacity, 0.35, 1.0);
        settings.dim_text_opacity = clampFloat(numberField(visual, "dimTextOpacity") orelse settings.dim_text_opacity, 0.45, 1.0);
        settings.line_contrast = clampFloat(numberField(visual, "lineContrast") orelse settings.line_contrast, 0.65, 1.35);
        settings.density = densityField(visual, "density") orelse settings.density;
        settings.profile = themeProfileField(visual, "profile") orelse settings.profile;
        settings.accent_color = accentColorField(visual, "accentColor") orelse settings.accent_color;
        settings.background_mode = backgroundModeField(visual, "backgroundMode") orelse settings.background_mode;
    }

    if (objectField(root, "data")) |data| {
        settings.live_data_enabled = boolField(data, "liveDataEnabled") orelse settings.live_data_enabled;
        settings.network_geolocation_enabled = boolField(data, "networkGeolocationEnabled") orelse settings.network_geolocation_enabled;
        settings.update_interval_ms = clampInt(integerField(data, "updateIntervalMs") orelse settings.update_interval_ms, 1000, 30000);
    }

    if (objectField(root, "panels")) |panels| {
        settings.left_visible = boolField(panels, "leftVisible") orelse settings.left_visible;
        settings.center_visible = boolField(panels, "centerVisible") orelse settings.center_visible;
        settings.right_visible = boolField(panels, "rightVisible") orelse settings.right_visible;
    }

    return std.fmt.allocPrint(allocator,
        \\{{
        \\  "version": {},
        \\  "visual": {{
        \\    "scanlinesEnabled": {},
        \\    "intensity": {d:.1},
        \\    "fontScale": {d:.2},
        \\    "panelOpacity": {d:.2},
        \\    "scanlineStrength": {d:.2},
        \\    "borderOpacity": {d:.2},
        \\    "dimTextOpacity": {d:.2},
        \\    "lineContrast": {d:.2},
        \\    "density": "{s}",
        \\    "profile": "{s}",
        \\    "accentColor": "{s}",
        \\    "backgroundMode": "{s}"
        \\  }},
        \\  "data": {{
        \\    "liveDataEnabled": {},
        \\    "networkGeolocationEnabled": {},
        \\    "updateIntervalMs": {}
        \\  }},
        \\  "panels": {{
        \\    "leftVisible": {},
        \\    "centerVisible": {},
        \\    "rightVisible": {}
        \\  }}
        \\}}
    , .{
        current_settings_version,
        settings.scanlines_enabled,
        settings.intensity,
        settings.font_scale,
        settings.panel_opacity,
        settings.scanline_strength,
        settings.border_opacity,
        settings.dim_text_opacity,
        settings.line_contrast,
        settings.density,
        settings.profile,
        settings.accent_color,
        settings.background_mode,
        settings.live_data_enabled,
        settings.network_geolocation_enabled,
        settings.update_interval_ms,
        settings.left_visible,
        settings.center_visible,
        settings.right_visible,
    });
}

fn objectField(value: std.json.Value, key: []const u8) ?std.json.Value {
    if (value != .object)
        return null;
    return value.object.get(key);
}

fn boolField(value: std.json.Value, key: []const u8) ?bool {
    const field = objectField(value, key) orelse return null;
    if (field != .bool)
        return null;
    return field.bool;
}

fn themeProfileField(value: std.json.Value, key: []const u8) ?[]const u8 {
    const field = objectField(value, key) orelse return null;
    if (field != .string)
        return null;
    const profile = field.string;
    if (std.mem.eql(u8, profile, "amber") or std.mem.eql(u8, profile, "green") or std.mem.eql(u8, profile, "blue") or std.mem.eql(u8, profile, "red"))
        return profile;
    return null;
}

fn backgroundModeField(value: std.json.Value, key: []const u8) ?[]const u8 {
    const field = objectField(value, key) orelse return null;
    if (field != .string)
        return null;
    const mode = field.string;
    if (std.mem.eql(u8, mode, "void") or std.mem.eql(u8, mode, "grid") or std.mem.eql(u8, mode, "radar"))
        return mode;
    return null;
}

fn densityField(value: std.json.Value, key: []const u8) ?[]const u8 {
    const field = objectField(value, key) orelse return null;
    if (field != .string)
        return null;
    const density = field.string;
    if (std.mem.eql(u8, density, "compact") or std.mem.eql(u8, density, "normal") or std.mem.eql(u8, density, "dense"))
        return density;
    return null;
}

fn accentColorField(value: std.json.Value, key: []const u8) ?[]const u8 {
    const field = objectField(value, key) orelse return null;
    if (field != .string)
        return null;
    const color = field.string;
    if (color.len != 7 or color[0] != '#')
        return null;
    for (color[1..]) |char| {
        if (!std.ascii.isHex(char))
            return null;
    }
    return color;
}

fn numberField(value: std.json.Value, key: []const u8) ?f64 {
    const field = objectField(value, key) orelse return null;
    return switch (field) {
        .float => |inner| inner,
        .integer => |inner| @floatFromInt(inner),
        .number_string => |inner| std.fmt.parseFloat(f64, inner) catch null,
        else => null,
    };
}

fn integerField(value: std.json.Value, key: []const u8) ?i64 {
    const field = objectField(value, key) orelse return null;
    return switch (field) {
        .integer => |inner| inner,
        .float => |inner| @intFromFloat(inner),
        .number_string => |inner| std.fmt.parseInt(i64, inner, 10) catch null,
        else => null,
    };
}

fn clampFloat(value: f64, min: f64, max: f64) f64 {
    return @max(min, @min(max, value));
}

fn clampInt(value: i64, min: i64, max: i64) i64 {
    return @max(min, @min(max, value));
}

fn writeStdout(io: std.Io, bytes: []const u8) !void {
    try std.Io.File.stdout().writeStreamingAll(io, bytes);
}

fn writeStderr(io: std.Io, bytes: []const u8) !void {
    try std.Io.File.stderr().writeStreamingAll(io, bytes);
}

fn writeStderrAlloc(allocator: std.mem.Allocator, io: std.Io, comptime fmt: []const u8, args: anytype) !void {
    const message = try std.fmt.allocPrint(allocator, fmt, args);
    defer allocator.free(message);
    try writeStderr(io, message);
}

fn expectContains(haystack: []const u8, needle: []const u8) !void {
    try std.testing.expect(std.mem.indexOf(u8, haystack, needle) != null);
}

test "normalizeSettings clamps visual and data ranges" {
    const payload =
        \\{
        \\  "visual": {
        \\    "intensity": 9.0,
        \\    "fontScale": 0.1,
        \\    "panelOpacity": 0.1,
        \\    "scanlineStrength": 9.0,
        \\    "borderOpacity": 0.1,
        \\    "dimTextOpacity": 0.1,
        \\    "lineContrast": 9.0
        \\  },
        \\  "data": { "updateIntervalMs": 5 }
        \\}
    ;

    const normalized = try normalizeSettings(std.testing.allocator, payload);
    defer std.testing.allocator.free(normalized);

    try expectContains(normalized, "\"intensity\": 1.5");
    try expectContains(normalized, "\"fontScale\": 0.85");
    try expectContains(normalized, "\"panelOpacity\": 0.55");
    try expectContains(normalized, "\"scanlineStrength\": 1.75");
    try expectContains(normalized, "\"borderOpacity\": 0.35");
    try expectContains(normalized, "\"dimTextOpacity\": 0.45");
    try expectContains(normalized, "\"lineContrast\": 1.35");
    try expectContains(normalized, "\"updateIntervalMs\": 1000");
}

test "normalizeSettings keeps valid enum and color values" {
    const payload =
        \\{
        \\  "visual": {
        \\    "density": "dense",
        \\    "profile": "blue",
        \\    "accentColor": "#12ABef",
        \\    "backgroundMode": "radar"
        \\  },
        \\  "data": { "liveDataEnabled": false, "networkGeolocationEnabled": true },
        \\  "panels": { "leftVisible": false, "centerVisible": true, "rightVisible": false }
        \\}
    ;

    const normalized = try normalizeSettings(std.testing.allocator, payload);
    defer std.testing.allocator.free(normalized);

    try expectContains(normalized, "\"density\": \"dense\"");
    try expectContains(normalized, "\"profile\": \"blue\"");
    try expectContains(normalized, "\"accentColor\": \"#12ABef\"");
    try expectContains(normalized, "\"backgroundMode\": \"radar\"");
    try expectContains(normalized, "\"liveDataEnabled\": false");
    try expectContains(normalized, "\"networkGeolocationEnabled\": true");
    try expectContains(normalized, "\"leftVisible\": false");
    try expectContains(normalized, "\"centerVisible\": true");
    try expectContains(normalized, "\"rightVisible\": false");
}

test "normalizeSettings falls back for invalid enum and color values" {
    const payload =
        \\{
        \\  "visual": {
        \\    "density": "huge",
        \\    "profile": "purple",
        \\    "accentColor": "#BADHEX",
        \\    "backgroundMode": "noise"
        \\  },
        \\  "data": { "updateIntervalMs": 999999 }
        \\}
    ;

    const normalized = try normalizeSettings(std.testing.allocator, payload);
    defer std.testing.allocator.free(normalized);

    try expectContains(normalized, "\"density\": \"normal\"");
    try expectContains(normalized, "\"profile\": \"amber\"");
    try expectContains(normalized, "\"accentColor\": \"#F2C94C\"");
    try expectContains(normalized, "\"backgroundMode\": \"void\"");
    try expectContains(normalized, "\"updateIntervalMs\": 30000");
}

test "normalizeSettings rejects non-object root" {
    try std.testing.expectError(error.InvalidSettingsJson, normalizeSettings(std.testing.allocator, "[]"));
}

test "normalizeSettings migrates missing and old versions to current version" {
    const missing_version = try normalizeSettings(std.testing.allocator, "{}");
    defer std.testing.allocator.free(missing_version);
    try expectContains(missing_version, "\"version\": 1");

    const old_version = try normalizeSettings(std.testing.allocator, "{\"version\":0}");
    defer std.testing.allocator.free(old_version);
    try expectContains(old_version, "\"version\": 1");
}

test "normalizeSettings rejects future versions" {
    try std.testing.expectError(error.UnsupportedSettingsVersion, normalizeSettings(std.testing.allocator, "{\"version\":999}"));
}
