//! A modified version of https://github.com/Hejsil/zig-bench/tree/60c49fc.

const std = @import("std");

const debug = std.debug;
const io = std.io;
const math = std.math;
const mem = std.mem;
const meta = std.meta;
const testing = std.testing;
const time = std.time;

const Decl = std.builtin.Type.Declaration;

pub fn run(comptime B: type) !void {
    // Set up prerequisites/options.
    const ally = if (@hasDecl(B, "allocator")) B.allocator else @compileError("missing `allocator` declaration");
    const tests = if (@hasDecl(B, "tests")) B.tests else @compileError("missing `tests` declaration");
    const target_types = if (@hasDecl(B, "target_types")) B.target_types else @compileError("missing `target_types` declaration");
    const min_iterations = if (@hasDecl(B, "min_iterations")) B.min_iterations else @compileError("missing `min_iterations` declaration");
    const max_iterations = if (@hasDecl(B, "max_iterations")) B.max_iterations else @compileError("missing `max_iterations` declaration");
    const max_time = 500 * time.ns_per_ms;

    // Get functions to benchmark.
    const functions = comptime functions: {
        var functions: []const Decl = &[_]Decl{};
        for (meta.declarations(B)) |decl| {
            if (@typeInfo(@TypeOf(@field(B, decl.name))) != .Fn)
                continue;
            functions = functions ++ [_]Decl{decl};
        }

        break :functions functions;
    };
    if (functions.len == 0)
        @compileError("No benchmarks to run.");

    const min_width = blk: {
        const writer = io.null_writer;
        var res = [_]u64{ 0, 0, 0, 0, 0 };
        res = try printBenchmark(
            writer,
            res,
            "name",
            formatter("{s}", ""),
            formatter("{s}", "n"),
            formatter("{s}", "min time"),
            formatter("{s}", "max time"),
            formatter("{s}", "mean time"),
        );
        inline for (functions) |f| {
            var i: usize = 0;
            while (i < tests.len) : (i += 1) {
                const max = math.maxInt(u32);
                res = if (i < tests.len) blk2: {
                    const arg_name = formatter("{s}", tests[i].name);
                    break :blk2 try printBenchmark(writer, res, f.name, arg_name, max, max, max, max);
                } else blk2: {
                    break :blk2 try printBenchmark(writer, res, f.name, i, max, max, max, max);
                };
            }
        }
        break :blk res;
    };

    // Print results header.
    var _stderr = std.io.bufferedWriter(std.io.getStdErr().writer());
    const stderr = _stderr.writer();
    try stderr.writeAll(" \n");
    _ = try printBenchmark(
        stderr,
        min_width,
        "name",
        formatter("{s}", ""),
        formatter("{s}", "iterations"),
        formatter("{s}", "min time"),
        formatter("{s}", "max time"),
        formatter("{s}", "mean time"),
    );
    try stderr.writeAll("\n");
    try stderr.context.flush();

    var timer = try time.Timer.start();

    inline for (tests, 0..) |t, index| outer: {
        inline for (functions) |def| {
            var runtimes: [max_iterations]u64 = undefined;
            var min: u64 = math.maxInt(u64);
            var max: u64 = 0;
            var runtime_sum: u128 = 0;

            var i: usize = 0;
            while (i < min_iterations or (i < max_iterations and runtime_sum < max_time)) : (i += 1) {
                // Run benchmark and store runtime (in nanoseconds).
                timer.reset();
                const res = @field(B, def.name)(ally, target_types[index], t.data);
                runtimes[i] = timer.read();

                // Add runtime to sum.
                runtime_sum += runtimes[i];

                // Set mininum and maximum runtimes.
                if (runtimes[i] < min) {
                    min = if (res == error.Skipped) 0 else runtimes[i];
                }
                if (runtimes[i] > max) {
                    max = if (res == error.Skipped) 0 else runtimes[i];
                }

                // Early break for skipped tests.
                if (res == error.Skipped) {
                    break :outer;
                }

                // Avoid return value optimizations.
                switch (@TypeOf(res)) {
                    void => {},
                    else => std.mem.doNotOptimizeAway(&res),
                }
            }

            // Compute mean.
            const runtime_mean: u64 = @intCast(runtime_sum / i);

            if (index < tests.len) {
                const arg_name = formatter("{s}", tests[index].name);

                if (min == 0 and max == 0) {
                    _ = try printBenchmark(
                        stderr,
                        min_width,
                        def.name,
                        arg_name,
                        formatter("{s}", "N/A"),
                        formatter("{s}", "N/A"),
                        formatter("{s}", "N/A"),
                        formatter("{s}", "N/A"),
                    );
                } else {
                    _ = try printBenchmark(
                        stderr,
                        min_width,
                        def.name,
                        arg_name,
                        i,
                        formatter("{d}ms", min / time.ns_per_ms),
                        formatter("{d}ms", max / time.ns_per_ms),
                        formatter("{d}ms", runtime_mean / time.ns_per_ms),
                    );
                }
            } else if (min == 0 and max == 0) {
                _ = try printBenchmark(
                    stderr,
                    min_width,
                    def.name,
                    index,
                    formatter("{s}", "N/A"),
                    formatter("{s}", "N/A"),
                    formatter("{s}", "N/A"),
                    formatter("{s}", "N/A"),
                );
            } else {
                _ = try printBenchmark(
                    stderr,
                    min_width,
                    def.name,
                    index,
                    i,
                    formatter("{d}ms", min / time.ns_per_ms),
                    formatter("{d}ms", max / time.ns_per_ms),
                    formatter("{d}ms", runtime_mean / time.ns_per_ms),
                );
            }
            try stderr.writeAll("\n");
            try stderr.context.flush();
        }
    }
}

fn printBenchmark(
    writer: anytype,
    min_widths: [5]u64,
    func_name: []const u8,
    arg_name: anytype,
    iterations: anytype,
    min_runtime: anytype,
    max_runtime: anytype,
    mean_runtime: anytype,
) ![5]u64 {
    const arg_len = std.fmt.count("{}", .{arg_name});
    const name_len = try alignedPrint(writer, .left, min_widths[0], "{s}{s}{}", .{
        func_name,
        "/"[0..@intFromBool(arg_len != 0)],
        arg_name,
    });
    try writer.writeAll(" ");
    const it_len = try alignedPrint(writer, .right, min_widths[1], "{}", .{iterations});
    try writer.writeAll(" ");
    const min_runtime_len = try alignedPrint(writer, .right, min_widths[2], "{}", .{min_runtime});
    try writer.writeAll(" ");
    const max_runtime_len = try alignedPrint(writer, .right, min_widths[3], "{}", .{max_runtime});
    try writer.writeAll(" ");
    const mean_runtime_len = try alignedPrint(writer, .right, min_widths[4], "{}", .{mean_runtime});

    return [_]u64{
        name_len,
        it_len,
        min_runtime_len,
        max_runtime_len,
        mean_runtime_len,
    };
}

fn formatter(comptime fmt_str: []const u8, value: anytype) Formatter(fmt_str, @TypeOf(value)) {
    return .{ .value = value };
}

fn Formatter(comptime fmt_str: []const u8, comptime T: type) type {
    return struct {
        value: T,

        pub fn format(
            self: @This(),
            comptime fmt: []const u8,
            options: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            _ = fmt;
            _ = options;
            try std.fmt.format(writer, fmt_str, .{self.value});
        }
    };
}

fn alignedPrint(
    writer: anytype,
    dir: enum { left, right },
    width: u64,
    comptime fmt: []const u8,
    args: anytype,
) !u64 {
    const value_len = std.fmt.count(fmt, args);

    var cow = io.countingWriter(writer);
    if (dir == .right)
        try cow.writer().writeByteNTimes(' ', math.sub(u64, width, value_len) catch 0);
    try cow.writer().print(fmt, args);
    if (dir == .left)
        try cow.writer().writeByteNTimes(' ', math.sub(u64, width, value_len) catch 0);
    return cow.bytes_written;
}
