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
    update_interval_ms: i64 = 5000,
    left_visible: bool = true,
    center_visible: bool = true,
    right_visible: bool = true,
};

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
    \\    "updateIntervalMs": 5000
    \\  },
    \\  "panels": {
    \\    "leftVisible": true,
    \\    "centerVisible": true,
    \\    "rightVisible": true
    \\  }
    \\}
;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var args = try std.process.argsWithAllocator(allocator);
    defer args.deinit();

    _ = args.next();
    const command = args.next() orelse "defaults";

    if (std.mem.eql(u8, command, "defaults")) {
        try writeStdout(defaults_json ++ "\n");
    } else if (std.mem.eql(u8, command, "read")) {
        try readSettings(allocator);
    } else if (std.mem.eql(u8, command, "write")) {
        const payload = args.next() orelse return error.MissingJsonPayload;
        try writeSettings(allocator, payload);
    } else {
        try writeStderr("usage: void-shell-settings [defaults|read|write '<json>']\n");
        return error.UnknownCommand;
    }
}

fn settingsPath(allocator: std.mem.Allocator) ![]u8 {
    if (std.process.getEnvVarOwned(allocator, "XDG_CONFIG_HOME")) |config_home| {
        defer allocator.free(config_home);
        return std.fs.path.join(allocator, &.{ config_home, "void-shell", "settings.json" });
    } else |_| {
        const home = try std.process.getEnvVarOwned(allocator, "HOME");
        defer allocator.free(home);
        return std.fs.path.join(allocator, &.{ home, ".config", "void-shell", "settings.json" });
    }
}

fn ensureSettingsDir(allocator: std.mem.Allocator, path: []const u8) !void {
    const dir_path = std.fs.path.dirname(path) orelse return;
    std.fs.cwd().makePath(dir_path) catch |err| {
        try writeStderrAlloc(allocator, "warning: failed to create settings directory: {s}\n", .{@errorName(err)});
        return err;
    };
}

fn readSettings(allocator: std.mem.Allocator) !void {
    const path = try settingsPath(allocator);
    defer allocator.free(path);

    const file = std.fs.cwd().openFile(path, .{}) catch |err| switch (err) {
        error.FileNotFound => {
            try writeStdout(defaults_json ++ "\n");
            return;
        },
        else => return err,
    };
    defer file.close();

    const data = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(data);
    try writeStdout(data);
    if (data.len == 0 or data[data.len - 1] != '\n')
        try writeStdout("\n");
}

fn writeSettings(allocator: std.mem.Allocator, payload: []const u8) !void {
    const normalized = try normalizeSettings(allocator, payload);
    defer allocator.free(normalized);

    const path = try settingsPath(allocator);
    defer allocator.free(path);
    try ensureSettingsDir(allocator, path);

    const file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(normalized);
    try file.writeAll("\n");
    try writeStdout(normalized);
    try writeStdout("\n");
}

fn normalizeSettings(allocator: std.mem.Allocator, payload: []const u8) ![]u8 {
    var parsed = try std.json.parseFromSlice(std.json.Value, allocator, payload, .{});
    defer parsed.deinit();

    var settings = Settings{};
    const root = parsed.value;
    if (root != .object)
        return error.InvalidSettingsJson;

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
        settings.update_interval_ms = clampInt(integerField(data, "updateIntervalMs") orelse settings.update_interval_ms, 1000, 30000);
    }

    if (objectField(root, "panels")) |panels| {
        settings.left_visible = boolField(panels, "leftVisible") orelse settings.left_visible;
        settings.center_visible = boolField(panels, "centerVisible") orelse settings.center_visible;
        settings.right_visible = boolField(panels, "rightVisible") orelse settings.right_visible;
    }

    return std.fmt.allocPrint(allocator,
        \\{{
        \\  "version": 1,
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
        \\    "updateIntervalMs": {}
        \\  }},
        \\  "panels": {{
        \\    "leftVisible": {},
        \\    "centerVisible": {},
        \\    "rightVisible": {}
        \\  }}
        \\}}
    , .{
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

fn writeStdout(bytes: []const u8) !void {
    try std.fs.File.stdout().writeAll(bytes);
}

fn writeStderr(bytes: []const u8) !void {
    try std.fs.File.stderr().writeAll(bytes);
}

fn writeStderrAlloc(allocator: std.mem.Allocator, comptime fmt: []const u8, args: anytype) !void {
    const message = try std.fmt.allocPrint(allocator, fmt, args);
    defer allocator.free(message);
    try writeStderr(message);
}
