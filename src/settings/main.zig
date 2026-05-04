const std = @import("std");

const defaults_json =
    \\{
    \\  "version": 1,
    \\  "visual": {
    \\    "scanlinesEnabled": true,
    \\    "intensity": 1.0
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
    const path = try settingsPath(allocator);
    defer allocator.free(path);
    try ensureSettingsDir(allocator, path);

    const file = try std.fs.cwd().createFile(path, .{ .truncate = true });
    defer file.close();
    try file.writeAll(payload);
    try file.writeAll("\n");
    try writeStdout("{\"ok\":true}\n");
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
