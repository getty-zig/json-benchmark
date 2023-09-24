const std = @import("std");
const json = @import("json");

const benchmark = @import("bench.zig").benchmark;
const Canada = @import("data.zig").Canada;

const c_ally = std.heap.c_allocator;
const test_ally = std.testing.allocator;

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

test "deserialize" {
    try benchmark(struct {
        pub const types = [_]type{
            Pastries,
            Canada,
        };
        pub const args = [_][]const u8{
            pastries,
            @embedFile("testdata/canada_geometry.json"),
        };
        pub const names = [_][]const u8{
            "Pastries",
            "Canada Geometry",
        };

        pub const min_iterations = 10;
        pub const max_iterations = 10;

        pub fn gettyParse(comptime T: type, input: []const u8) !void {
            for (0..100_000) |_| {
                const result = try json.fromSlice(c_ally, T, input);
                defer result.deinit();
            }
        }

        pub fn stdParse(comptime T: type, input: []const u8) !void {
            for (0..100_000) |_| {
                const output = try std.json.parseFromSlice(T, c_ally, input, .{ .allocate = .alloc_always });
                defer output.deinit();
            }
        }
    });
}
