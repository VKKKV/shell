const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const settings_module = b.createModule(.{
        .root_source_file = b.path("src/settings/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const settings = b.addExecutable(.{
        .name = "void-shell-settings",
        .root_module = settings_module,
    });

    b.installArtifact(settings);
}
