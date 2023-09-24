const std = @import("std");
const json = @import("json");
const bench = @import("bench");

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    _ = json;
    try std.testing.expect(add(3, 7) == 10);
}
