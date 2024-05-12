const std = @import("std");
const Loop = @import("xkyss-core").Loop;

pub fn main() !void {
    var loop: Loop = .{ .a = 222 };
    _ = loop.init();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
