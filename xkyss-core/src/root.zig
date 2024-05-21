const std = @import("std");

pub const Loop = @import("event/Loop.zig");
pub const time = @import("base/Time.zig");

test "root" {
    std.debug.print("root\n", .{});
}

test {
    std.testing.refAllDecls(@This());
}
