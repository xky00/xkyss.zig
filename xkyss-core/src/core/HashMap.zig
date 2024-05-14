const std = @import("std");

fn save(writer: anytype, bytes: []const u8) void {
    writer.writeAll(bytes);
}

test "hash" {
    const Point = struct { x: i32, y: i32 };
    const Map = std.AutoHashMap(u32, Point);
    var map = Map.init(std.testing.allocator);
    defer map.deinit();

    try map.put(1525, .{ .x = 1, .y = -4 });
    try map.put(1550, .{ .x = 2, .y = -3 });
    try map.put(1575, .{ .x = 3, .y = -2 });
    try map.put(1600, .{ .x = 4, .y = -1 });

    try std.testing.expect(map.count() == 4);
}

test "void*" {
    const Map = std.AutoHashMap(u32, *const anyopaque);
    var map = Map.init(std.testing.allocator);
    defer map.deinit();

    try map.put(1, &3);
    // try map.put(2, &"Hello");
    try map.put(2, &.{555});
    try std.testing.expect(map.count() == 2);
}
