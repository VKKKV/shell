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

    const settings_tests = b.addTest(.{
        .root_module = settings_module,
    });
    const run_settings_tests = b.addRunArtifact(settings_tests);

    const test_step = b.step("test", "Run Zig tests");
    test_step.dependOn(&run_settings_tests.step);
}
