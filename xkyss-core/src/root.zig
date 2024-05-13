const std = @import("std");

pub const Loop = @import("event/Loop.zig");
pub const time = @import("base/Time.zig");

comptime {
    _ = @import("event/Loop.zig");
}

test "root" {
    std.debug.print("root\n", .{});
}
