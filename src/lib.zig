const std = @import("std");
const json = @import("json");

const benchmark = @import("bench.zig").benchmark;

const Pastries = []struct {
    id: []const u8,
    type: []const u8,
    name: []const u8,
    ppu: f64,
    batters: struct {
        batter: []struct {
            id: []const u8,
            type: []const u8,
        },
    },
    topping: []struct {
        id: []const u8,
        type: []const u8,
    },
};

const pastries =
    \\[
    \\    {
    \\        "id": "0001",
    \\        "type": "donut",
    \\        "name": "Cake",
    \\        "ppu": 0.55,
    \\        "batters": {
    \\            "batter": [
    \\                {
    \\                    "id": "1001",
    \\                    "type": "Regular"
    \\                },
    \\                {
    \\                    "id": "1002",
    \\                    "type": "Chocolate"
    \\                },
    \\                {
    \\                    "id": "1003",
    \\                    "type": "Blueberry"
    \\                },
    \\                {
    \\                    "id": "1004",
    \\                    "type": "Devil's Food"
    \\                }
    \\            ]
    \\        },
    \\        "topping": [
    \\            {
    \\                "id": "5001",
    \\                "type": "None"
    \\            },
    \\            {
    \\                "id": "5002",
    \\                "type": "Glazed"
    \\            },
    \\            {
    \\                "id": "5005",
    \\                "type": "Sugar"
    \\            },
    \\            {
    \\                "id": "5007",
    \\                "type": "Powdered Sugar"
    \\            },
    \\            {
    \\                "id": "5006",
    \\                "type": "Chocolate with Sprinkles"
    \\            },
    \\            {
    \\                "id": "5003",
    \\                "type": "Chocolate"
    \\            },
    \\            {
    \\                "id": "5004",
    \\                "type": "Maple"
    \\            }
    \\        ]
    \\    },
    \\    {
    \\        "id": "0002",
    \\        "type": "donut",
    \\        "name": "Raised",
    \\        "ppu": 0.55,
    \\        "batters": {
    \\            "batter": [
    \\                {
    \\                    "id": "1001",
    \\                    "type": "Regular"
    \\                }
    \\            ]
    \\        },
    \\        "topping": [
    \\            {
    \\                "id": "5001",
    \\                "type": "None"
    \\            },
    \\            {
    \\                "id": "5002",
    \\                "type": "Glazed"
    \\            },
    \\            {
    \\                "id": "5005",
    \\                "type": "Sugar"
    \\            },
    \\            {
    \\                "id": "5003",
    \\                "type": "Chocolate"
    \\            },
    \\            {
    \\                "id": "5004",
    \\                "type": "Maple"
    \\            }
    \\        ]
    \\    },
    \\    {
    \\        "id": "0003",
    \\        "type": "donut",
    \\        "name": "Old Fashioned",
    \\        "ppu": 0.55,
    \\        "batters": {
    \\            "batter": [
    \\                {
    \\                    "id": "1001",
    \\                    "type": "Regular"
    \\                },
    \\                {
    \\                    "id": "1002",
    \\                    "type": "Chocolate"
    \\                }
    \\            ]
    \\        },
    \\        "topping": [
    \\            {
    \\                "id": "5001",
    \\                "type": "None"
    \\            },
    \\            {
    \\                "id": "5002",
    \\                "type": "Glazed"
    \\            },
    \\            {
    \\                "id": "5003",
    \\                "type": "Chocolate"
    \\            },
    \\            {
    \\                "id": "5004",
    \\                "type": "Maple"
    \\            }
    \\        ]
    \\    }
    \\]
;

test "benchmark" {
    const Args = struct { type, []const u8 };

    try benchmark(struct {
        // The functions will be benchmarked with the following inputs.
        // If not present, then it is assumed that the functions
        // take no input.
        pub const args = [_]Args{
            .{
                Pastries,
                pastries,
            },
        };

        // You can specify `arg_names` to give the inputs more meaningful
        // names. If the index of the input exceeds the available string
        // names, the index is used as a backup.
        pub const arg_names = [_][]const u8{
            "Pastries",
        };

        // How many iterations to run each benchmark.
        // If not present then a default will be used.
        pub const min_iterations = 5;
        pub const max_iterations = 5;

        pub fn gettyParse(comptime data: Args) !void {
            for (0..100_000) |_| {
                const result = try json.fromSlice(std.heap.c_allocator, data[0], data[1]);
                defer result.deinit();
            }
        }

        pub fn stdParse(comptime data: Args) !void {
            for (0..100_000) |_| {
                const output = try std.json.parseFromSlice(data[0], std.heap.c_allocator, data[1], .{ .allocate = .alloc_always });
                defer output.deinit();
            }
        }
    });
}
