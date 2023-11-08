//! A modified version of https://github.com/Hejsil/zig-bench/tree/60c49fc.

const std = @import("std");

const Decl = std.builtin.Type.Declaration;
const time = std.time;

pub fn run(comptime B: type) !void {
    // Set up configuration options
    const ally = if (@hasDecl(B, "allocator")) B.allocator else @compileError("missing `allocator` declaration");
    const tests = if (@hasDecl(B, "tests")) B.tests else @compileError("missing `tests` declaration");
    const target_types = if (@hasDecl(B, "target_types")) B.target_types else @compileError("missing `target_types` declaration");
    const min_n = if (@hasDecl(B, "min_n")) B.min_n else @compileError("missing `min_n` declaration");
    const max_n = if (@hasDecl(B, "max_n")) B.max_n else @compileError("missing `max_n` declaration");
    const max_time = if (@hasDecl(B, "max_time")) B.max_time else 500 * time.ns_per_ms;

    const funcs = comptime getBenchmarkFuncs(B);
    const min_widths = getMinWidths(&tests, funcs);

    // Print results header.
    var stderr_buffered_writer = std.io.bufferedWriter(std.io.getStdErr().writer());
    const writer = stderr_buffered_writer.writer();

    // The leading ' ' character is required in order to avoid the newlines
    // being eaten up.
    try writer.writeAll(" \n\n");

    _ = try printBenchmarkGeneral(
        writer,
        min_widths,
        "name",
        formatter("{s}", ""),
        formatter("{s}", "n"),
        formatter("{s}", "min time"),
        formatter("{s}", "mean time"),
        formatter("{s}", "max time"),
    );

    try writer.writeAll("\n");

    try writer.context.flush();

    // Run benchmarks
    var timer = try time.Timer.start();

    inline for (tests, 0..) |t, i| {
        inline for (funcs) |f| {
            var runtimes: [max_n]u64 = undefined;
            var min: u64 = std.math.maxInt(u64);
            var max: u64 = 0;
            var runtime_sum: u128 = 0;

            var n: usize = 0;
            while (n < min_n or (n < max_n and runtime_sum < max_time)) : (n += 1) {
                // Run benchmark and store runtime (in nanoseconds).
                timer.reset();
                const res = @field(B, f.name)(ally, target_types[i], t.data);
                runtimes[n] = timer.read();

                // Add runtime to sum.
                runtime_sum += runtimes[n];

                // Set mininum and maximum runtimes.
                if (runtimes[n] < min) {
                    min = if (res == error.Skipped) 0 else runtimes[n];
                }
                if (runtimes[n] > max) {
                    max = if (res == error.Skipped) 0 else runtimes[n];
                }

                // Avoid return value optimizations.
                switch (@TypeOf(res)) {
                    void => {},
                    else => std.mem.doNotOptimizeAway(&res),
                }
            }

            const test_name = formatter("{s}", tests[i].name);

            if (min == 0 and max == 0) {
                _ = try printSkippedBenchmark(writer, min_widths, f.name, test_name);
            } else {
                const mean: u64 = @intCast(runtime_sum / n);

                _ = try printBenchmark(
                    writer,
                    min_widths,
                    f.name,
                    test_name,
                    n,
                    min,
                    mean,
                    max,
                );
            }

            try writer.writeAll("\n");
            try writer.context.flush();
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
// Configuration
////////////////////////////////////////////////////////////////////////////////

pub const TestCase = struct {
    // The name of the test case.
    name: []const u8,

    // The data of the test case.
    //
    // Typically, this will be provided via @embedFile.
    data: []const u8,
};

fn getBenchmarkFuncs(comptime B: type) []const Decl {
    comptime {
        var funcs: []const Decl = &[_]Decl{};

        for (std.meta.declarations(B)) |decl| {
            const d = @field(B, decl.name);
            const D = @TypeOf(d);
            const decl_is_fn = @typeInfo(D) == .Fn;

            if (decl_is_fn) {
                funcs = funcs ++ [_]Decl{decl};
            }
        }

        if (funcs.len == 0) {
            @compileError("no benchmarks to run");
        }

        return funcs;
    }
}

fn getMinWidths(tests: []const TestCase, comptime funcs: []const Decl) [5]u64 {
    const writer = std.io.null_writer;
    var min_widths = [_]u64{ 0, 0, 0, 0, 0 };

    // Header names
    min_widths = printBenchmarkGeneral(
        writer,
        min_widths,
        "name",
        formatter("{s}", ""),
        formatter("{s}", "n"),
        formatter("{s}", "min time"),
        formatter("{s}", "mean time"),
        formatter("{s}", "max time"),
    ) catch unreachable; // UNREACHABLE: std.io.null_writer cannot fail

    // Tests and results
    inline for (funcs) |f| {
        for (0..tests.len) |i| {
            const max = std.math.maxInt(u32);

            min_widths = printBenchmarkGeneral(
                writer,
                min_widths,
                f.name,
                formatter("{s}", tests[i].name),
                max,
                max,
                max,
                max,
            ) catch unreachable; // UNREACHABLE: std.io.null_writer cannot fail
        }
    }

    return min_widths;
}

////////////////////////////////////////////////////////////////////////////////
// Output
////////////////////////////////////////////////////////////////////////////////

fn printBenchmarkGeneral(
    writer: anytype,
    min_widths: [5]u64,
    func_name: []const u8,
    test_name: anytype,
    n: anytype,
    min_runtime: anytype,
    mean_runtime: anytype,
    max_runtime: anytype,
) ![5]u64 {
    const test_len = std.fmt.count("{}", .{test_name});
    const name_len = try alignedPrint(writer, .left, min_widths[0], "{s}{s}{}", .{
        func_name,
        "/"[0..@intFromBool(test_len != 0)],
        test_name,
    });
    try writer.writeAll("  ");
    const n_len = try alignedPrint(writer, .right, min_widths[1], "{d}", .{n});
    try writer.writeAll("  ");
    const min_runtime_len = try alignedPrint(writer, .right, min_widths[2], "{}", .{min_runtime});
    try writer.writeAll("  ");
    const mean_runtime_len = try alignedPrint(writer, .right, min_widths[3], "{}", .{mean_runtime});
    try writer.writeAll("  ");
    const max_runtime_len = try alignedPrint(writer, .right, min_widths[4], "{}", .{max_runtime});

    return [_]u64{
        name_len,
        n_len,
        min_runtime_len,
        mean_runtime_len,
        max_runtime_len,
    };
}

fn printBenchmark(
    writer: anytype,
    min_widths: [5]u64,
    func_name: []const u8,
    test_name: anytype,
    n: u64,
    min_runtime: u64,
    mean_runtime: u64,
    max_runtime: u64,
) ![5]u64 {
    const test_len = std.fmt.count("{}", .{test_name});
    const name_len = try alignedPrint(writer, .left, min_widths[0], "{s}{s}{}", .{
        func_name,
        "/"[0..@intFromBool(test_len != 0)],
        test_name,
    });

    try writer.writeAll("  ");
    const n_len = try alignedPrint(writer, .right, min_widths[1], "{d}", .{n});
    try writer.writeAll("  ");
    const min_runtime_len = try formatTime(writer, min_widths[2], min_runtime);
    try writer.writeAll("  ");
    const mean_runtime_len = try formatTime(writer, min_widths[3], mean_runtime);
    try writer.writeAll("  ");
    const max_runtime_len = try formatTime(writer, min_widths[4], max_runtime);

    return [_]u64{
        name_len,
        n_len,
        min_runtime_len,
        mean_runtime_len,
        max_runtime_len,
    };
}

fn printSkippedBenchmark(
    writer: anytype,
    min_widths: [5]u64,
    func_name: []const u8,
    test_name: anytype,
) ![5]u64 {
    const name_len = try alignedPrint(
        writer,
        .left,
        min_widths[0],
        "{s}{s}{}",
        .{
            func_name,
            "/"[0..@intFromBool(std.fmt.count("{}", .{test_name}) != 0)],
            test_name,
        },
    );

    try writer.writeAll("  ");
    const n_len = try alignedPrint(writer, .right, min_widths[1], "SKIP", .{}); // n
    try writer.writeAll("  ");
    const min_runtime_len = try alignedPrint(writer, .right, min_widths[2], "SKIP", .{}); // min
    try writer.writeAll("  ");
    const mean_runtime_len = try alignedPrint(writer, .right, min_widths[3], "SKIP", .{}); // mean
    try writer.writeAll("  ");
    const max_runtime_len = try alignedPrint(writer, .right, min_widths[4], "SKIP", .{}); // max

    return [_]u64{
        name_len,
        n_len,
        min_runtime_len,
        mean_runtime_len,
        max_runtime_len,
    };
}

fn formatTime(writer: anytype, min_width: u64, ns: u64) !u64 {
    const ns_float: f64 = @floatFromInt(ns);

    if (ns_float >= time.ns_per_hour) {
        return try alignedPrint(writer, .right, min_width, "{d:.2}hr", .{ns_float / @as(f64, @floatFromInt(time.ns_per_hour))});
    } else if (ns_float >= time.ns_per_min) {
        return try alignedPrint(writer, .right, min_width, "{d:.2}min", .{ns_float / @as(f64, @floatFromInt(time.ns_per_min))});
    } else if (ns_float >= time.ns_per_s) {
        return try alignedPrint(writer, .right, min_width, "{d:.2}sec", .{ns_float / @as(f64, @floatFromInt(time.ns_per_s))});
    } else if (ns_float >= time.ns_per_ms) {
        return try alignedPrint(writer, .right, min_width, "{d:.2}ms", .{ns_float / @as(f64, @floatFromInt(time.ns_per_ms))});
    } else if (ns_float >= 1000) {
        return try alignedPrint(writer, .right, min_width, "{d:.2}us", .{ns_float / @as(f64, @floatFromInt(time.ns_per_us))});
    }

    return try alignedPrint(writer, .right, min_width, "{d:.2}ns", .{ns_float});
}

fn alignedPrint(
    writer: anytype,
    dir: enum { left, right },
    width: u64,
    comptime fmt: []const u8,
    args: anytype,
) !u64 {
    const value_len = std.fmt.count(fmt, args);

    var cow = std.io.countingWriter(writer);
    if (dir == .right)
        try cow.writer().writeByteNTimes(' ', std.math.sub(u64, width, value_len) catch 0);
    try cow.writer().print(fmt, args);
    if (dir == .left)
        try cow.writer().writeByteNTimes(' ', std.math.sub(u64, width, value_len) catch 0);
    return cow.bytes_written;
}

fn Formatter(comptime fmt_str: []const u8, comptime T: type) type {
    return struct {
        value: T,

        pub fn format(
            self: @This(),
            comptime _: []const u8,
            _: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            try std.fmt.format(writer, fmt_str, .{self.value});
        }
    };
}

fn formatter(comptime fmt_str: []const u8, value: anytype) Formatter(fmt_str, @TypeOf(value)) {
    return .{ .value = value };
}
