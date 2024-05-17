// https://ziggit.dev/t/void-c-and-anyopaque-zig/376/3
// https://ziggit.dev/t/casting-aligning-anyopaque-to-zig-string-done-incorrectly-results-in-corrupted-data/2168

const std = @import("std");

test "u32 with anyopaque" {
    var x: u32 = 111;
    const p: *const anyopaque = @ptrCast(&x);
    const r: *const u32 = @ptrCast(@alignCast(p));

    std.debug.print("\n\n", .{});
    std.debug.print("x: {}\n", .{x});
    std.debug.print("p: {x}\n", .{p});
    std.debug.print("r: {}\n", .{r});
    std.debug.print("v: {}\n", .{r.*});

    try std.testing.expectEqual(x, r.*);
}

test "*string with anyopaque" {
    const s = "hello";
    const p: *const anyopaque = @ptrCast(&s);
    const r: *const *const [5:0]u8 = @ptrCast(@alignCast(p));
    const x: *const [*:0]u8 = @ptrCast(@alignCast(p)); // 无法获取长度

    std.debug.print("\n\n", .{});
    std.debug.print("s: {s}, len: {d}, type: {}\n", .{ s, s.len, @TypeOf(s) });
    std.debug.print("ps: {}\n", .{&s});
    std.debug.print("p: {}\n", .{p});
    std.debug.print("r: {s} {*} {d}\n", .{ r.*, r, r.*.len });
    std.debug.print("x: {s} {*}\n", .{ x.*, x });
}

test "string with anyopaque 2" {
    const s = "hello";
    const p: *const anyopaque = @ptrCast(s);
    const r: *const [5:0]u8 = @ptrCast(@alignCast(p));
    const x: *const [*:0]u8 = @ptrCast(@alignCast(&p)); // 无法获取长度

    std.debug.print("\n\n", .{});
    std.debug.print("s: {s}, len: {d}, type: {}\n", .{ s, s.len, @TypeOf(s) });
    std.debug.print("ps: {}\n", .{&s});
    std.debug.print("p: {}\n", .{p});
    std.debug.print("r: {s} {*} {d}\n", .{ r.*, r, r.*.len });
    std.debug.print("x: {s}\n", .{x.*});
}

test "u32 with void" {
    std.debug.print("ignore\n", .{});
    var x: u32 = 111;
    const p: *void = @ptrCast(&x);
    const r: *u32 = @ptrCast(@alignCast(p));

    std.debug.print("\n\n", .{});
    std.debug.print("x: {}\n", .{x});
    std.debug.print("p: {x}\n", .{p});
    std.debug.print("r: {}\n", .{r});
    std.debug.print("v: {}\n", .{r.*});

    try std.testing.expectEqual(x, r.*);
}
