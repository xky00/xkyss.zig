const std = @import("std");
const Event = @import("./Event.zig");
const Instant = std.time.Instant;
const Allocator = std.mem.Allocator;

const Self = @This();

const Node = struct {
    // 节点对应的事件
    event: *Event,
    // 下一个事件
    next: ?*Node,
};

// 状态
pub const Status = enum {
    stop,
    running,
    pause,
};

// 成员变量
allocator: Allocator,
status: Status = Status.stop,
start_time: Instant,
end_time: ?Instant = null,
current_time: Instant,
loop_count: u64 = 0,
head: ?*Node = null,
tail: ?*Node = null,
current: ?*Node = null,

/// 构造
pub fn init(allocator: Allocator) Self {
    const current = Instant.now() catch unreachable;
    return .{
        .allocator = allocator,
        .status = Status.stop,
        .start_time = current,
        .current_time = current,
        .loop_count = 0,
    };
}

/// 析构
pub fn deinit(self: *Self) void {
    std.debug.print("deinit: 0x{X}\n", .{@intFromPtr(self)});
    const node = self.tail.?;
    while (node != null) {
        self.allocator.destroy(node);
        // node = node.*.next.?;
    }
}

/// 运行循环
pub fn run(self: *Self) !i32 {
    self.status = .running;
    std.debug.print("   run: 0x{X}\n", .{@intFromPtr(self)});

    self.end_time = Instant.now() catch unreachable;
    return 0;
}

/// 插入事件
pub fn add_event(self: *Self, event: *Event) !void {
    const node = try self.allocator.create(Node);
    node.*.event = event;
    if (self.tail == null) {
        self.tail = node;
    } else {
        self.tail.?.*.next = node;
    }
    std.debug.print("   add_event: 0x{X}\n", .{@intFromPtr(self)});
}

test "loop" {
    std.debug.print("loop\n", .{});

    var loop = init(std.testing.allocator);
    std.debug.print("  loop: 0x{X}\n", .{@intFromPtr(&loop)});
    defer loop.deinit();

    _ = try loop.run();
}

test "add_event" {
    std.debug.print("add_event\n", .{});
    var loop = init(std.testing.allocator);
    defer loop.deinit();
    var event = .{ .emitTime = Instant.now() catch unreachable };
    try loop.add_event(&event);
}
