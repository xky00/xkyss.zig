// https://ziggit.dev/t/void-c-and-anyopaque-zig/376/3
// https://ziggit.dev/t/casting-aligning-anyopaque-to-zig-string-done-incorrectly-results-in-corrupted-data/2168

const std = @import("std");

test "to anyopaque" {
    var x: u32 = 111;
    const p: *const anyopaque = @ptrCast(&x);
    const r: *const u32 = @ptrCast(@alignCast(p));

    std.debug.print("\n", .{});
    std.debug.print("x: {}\n", .{x});
    std.debug.print("p: {}\n", .{p});
    std.debug.print("r: {}\n", .{r});
    std.debug.print("v: {}\n", .{r.*});

    try std.testing.expectEqual(x, r.*);
}
