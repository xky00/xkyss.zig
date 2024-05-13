const std = @import("std");
const ks = @import("xkyss-core");
const sleep = ks.time.sleep;

pub fn main() !void {
    var loop = ks.Loop{};
    std.debug.print("{}\n", .{loop});

    _ = try std.Thread.spawn(.{}, runner, .{&loop});
    // 等待循环开始
    sleep(100);

    _ = loop.pause();
    _ = loop.unpause();
    _ = loop.stop();
}

fn runner(loop: *ks.Loop) void {
    std.debug.print("runner {}\n", .{loop});
    _ = loop.run();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
