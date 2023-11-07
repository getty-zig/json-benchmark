const std = @import("std");

const package_name = "json-benchmark";
const package_path = "src/lib.zig";

pub fn build(b: *std.build.Builder) void {
    const opts = .{
        .target = b.standardTargetOptions(.{}),
        .optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseFast }),
    };

    // Dependencies
    const json_module = b.dependency("json", opts).module("json");

    // Tests
    const bench = b.addTest(.{
        .name = "benchmark",
        .root_source_file = .{ .path = package_path },
        .target = opts.target,
        .optimize = opts.optimize,
    });
    bench.addModule("json", json_module);

    const bench_step = b.step("bench", "Run benchmarks");
    const run_bench = b.addRunArtifact(bench);
    bench_step.dependOn(&run_bench.step);
}
