const std = @import("std");
const t = @import("base/time.zig");

pub fn main() !void {
    const t1 = t.gethrtime();
    const t2 = t.gethrtime_c();
    std.log.debug("{}", .{t1});
    std.log.debug("{}", .{t2});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
