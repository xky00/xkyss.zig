const std = @import("std");
const Foo = struct {
    allocator: std.mem.Allocator,
    a: u32,

    const Self = @This();

    pub fn new(allocator: std.mem.Allocator) !*Self {
        var foo = try allocator.create(Foo);
        foo.allocator = allocator;
        foo.a = 100;
        return foo;
    }

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{ .allocator = allocator, .a = 100 };
    }
};

test "foo stack init" {
    const foo = Foo.init(std.testing.allocator);

    std.debug.print("foo: {}\n", .{foo});
}

test "foo heap init" {
    const foo = try std.testing.allocator.create(Foo);
    defer std.testing.allocator.destroy(foo);
    foo.allocator = std.testing.allocator;
    foo.a = 100;
    std.debug.print("foo: {}\n", .{foo});
}

test "foo new" {
    const foo = try Foo.new(std.testing.allocator);
    defer std.testing.allocator.destroy(foo);
    std.debug.print("foo: {}\n", .{foo});
}
