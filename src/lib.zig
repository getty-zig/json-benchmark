const json = @import("json");
const std = @import("std");

const bench = @import("bench.zig");
const data = @import("data.zig");

test "deserialize" {
    const deserializations: comptime_int = 1;
    const iterations: comptime_int = 24;

    try bench.run(struct {
        pub const allocator = std.heap.c_allocator;

        pub const tests = [_]bench.TestCase{
            .{
                .name = "pastries",
                .data = @embedFile("data/pastries.json"),
            },
            .{
                .name = "canada_geometry",
                .data = @embedFile("data/canada_geometry.json"),
            },
            .{
                .name = "citm_catalog",
                .data = @embedFile("data/citm_catalog.json"),
            },
        };

        pub const target_types = [_]type{
            data.Pastries,
            data.Canada,
            data.CITM,
        };

        pub const min_iterations = iterations;
        pub const max_iterations = iterations;

        pub fn @"de/getty"(
            ally: std.mem.Allocator,
            comptime T: type,
            input: []const u8,
        ) !void {
            for (0..deserializations) |_| {
                const result = try json.fromSlice(ally, T, input);
                defer result.deinit();
            }
        }

        // NOTE: Not all test data can be benchmarked using std.json's due to
        // its lack of support for various types within the standard library.
        pub fn @"de/std"(
            ally: std.mem.Allocator,
            comptime T: type,
            input: []const u8,
        ) !void {
            switch (T) {
                data.CITM => return error.Skipped,
                else => {},
            }

            for (0..deserializations) |_| {
                const output = try std.json.parseFromSlice(
                    T,
                    ally,
                    input,
                    .{ .allocate = .alloc_always },
                );
                defer output.deinit();
            }
        }
    });
}
