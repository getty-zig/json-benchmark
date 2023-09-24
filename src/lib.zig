const json = @import("json");
const std = @import("std");

const bench = @import("bench.zig");
const data = @import("data.zig");

const heap = std.heap;
const mem = std.mem;

test "deserialize" {
    const n_deserializations: comptime_int = 2;

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

        pub const min_iterations = 1;
        pub const max_iterations = 1;

        pub fn benchStd(ally: mem.Allocator, comptime T: type, input: []const u8) !void {
            for (0..n_deserializations) |_| {
                const output = try std.json.parseFromSlice(
                    T,
                    ally,
                    input,
                    .{ .allocate = .alloc_always },
                );
                defer output.deinit();
            }
        }

        pub fn benchGetty(ally: mem.Allocator, comptime T: type, input: []const u8) !void {
            for (0..n_deserializations) |_| {
                const result = try json.fromSlice(ally, T, input);
                defer result.deinit();
            }
        }
    });
}
