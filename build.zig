const std = @import("std");

const package_name = "json-benchmark";
const package_path = "src/lib.zig";

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = .ReleaseFast,
    });

    // Dependencies.
    const dep_opts = .{ .target = target, .optimize = optimize };

    const json_module = b.dependency("json", dep_opts).module("json");

    // Tests
    const bench = b.addTest(.{
        .name = "benchmark",
        .root_source_file = .{ .path = package_path },
        .target = target,
        .optimize = optimize,
    });
    bench.root_module.addImport("json", json_module);

    const bench_step = b.step("bench", "Run benchmarks");
    const run_bench = b.addRunArtifact(bench);
    bench_step.dependOn(&run_bench.step);
}
