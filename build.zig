const std = @import("std");

const package_name = "json-benchmark";
const package_path = "src/lib.zig";

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast });

    // Dependencies.
    const dep_opts = .{ .target = target, .optimize = optimize };

    const json_module = b.dependency("json", dep_opts).module("json");

    // Tests.
    const tests = b.addTest(.{
        .root_source_file = .{ .path = package_path },
        .target = target,
        .optimize = optimize,
    });
    tests.addModule("json", json_module);

    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run benchmarks");
    test_step.dependOn(&run_tests.step);
}
