const std = @import("std");
const ks = @import("xkyss-core");

pub fn main() !void {
    var loop = ks.Loop{};
    std.debug.print("{}\n", .{loop});

    _ = try std.Thread.spawn(.{}, runner, .{&loop});
    _ = loop.run();
}

fn runner(loop: *ks.Loop) void {
    std.debug.print("runner {}\n", .{loop});
    ks.Time.sleep(5000);
    _ = loop.stop();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
