const json = @import("json");
const std = @import("std");

const bench = @import("bench.zig");
const data = @import("data.zig");

const heap = std.heap;
const mem = std.mem;

test "deserialize" {
    const deserializations: comptime_int = 100_000;
    const iterations: comptime_int = 10;

    // Getty JSON
    try bench.run(struct {
        pub const allocator = heap.c_allocator;
        pub const types = [_]type{
            data.Pastries,
            data.Canada,
            data.CITM,
        };
        pub const args = [_][]const u8{
            @embedFile("data/pastries.json"),
            @embedFile("data/canada_geometry.json"),
            @embedFile("data/citm_catalog.json"),
        };
        pub const names = [_][]const u8{
            "Pastries",
            "Canada Geometry",
            "CITM Catalog",
        };

        pub const min_iterations = iterations;
        pub const max_iterations = iterations;

        pub fn benchGetty(
            ally: mem.Allocator,
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
        pub fn benchStd(
            ally: mem.Allocator,
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
