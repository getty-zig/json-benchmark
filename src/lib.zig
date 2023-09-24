const std = @import("std");
const json = @import("json");

const benchmark = @import("bench.zig").benchmark;
const data = @import("data.zig");

const c_ally = std.heap.c_allocator;

test "deserialize" {
    try benchmark(struct {
        pub const types = [_]type{
            data.Pastries,
            data.Canada,
        };
        pub const args = [_][]const u8{
            @embedFile("data/pastries.json"),
            @embedFile("data/canada_geometry.json"),
        };
        pub const names = [_][]const u8{
            "Pastries",
            "Canada Geometry",
        };

        pub const min_iterations = 10;
        pub const max_iterations = 10;

        pub fn benchGetty(comptime T: type, input: []const u8) !void {
            for (0..100_000) |_| {
                const result = try json.fromSlice(c_ally, T, input);
                defer result.deinit();
            }
        }

        pub fn benchStd(comptime T: type, input: []const u8) !void {
            for (0..100_000) |_| {
                const output = try std.json.parseFromSlice(T, c_ally, input, .{ .allocate = .alloc_always });
                defer output.deinit();
            }
        }
    });
}
