const std = @import("std");
const Event = @import("./Event.zig");
const Instant = std.time.Instant;
const Allocator = std.mem.Allocator;
const AtomicU64 = std.atomic.Value(u64);

const Self = @This();

const Node = struct {
    id: u64 = 0,
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
node_count: AtomicU64 = AtomicU64{ .raw = 0 },
head: ?*Node = null,
tail: ?*Node = null,
current: ?*Node = null,
node_mutex: std.Thread.Mutex,

/// 构造
pub fn init(allocator: Allocator) Self {
    const current = Instant.now() catch unreachable;
    return .{
        .allocator = allocator,
        .status = Status.stop,
        .start_time = current,
        .current_time = current,
        .loop_count = 0,
        .node_mutex = std.Thread.Mutex{},
    };
}

/// 析构
pub fn deinit(self: *Self) void {
    std.debug.print("deinit: 0x{X}\n", .{@intFromPtr(self)});
    var current_node = self.head;
    while (current_node) |node| {
        std.debug.print("\tnode: 0x{X}, id: {}\n", .{ @intFromPtr(node), node.id });
        current_node = node.next;
        self.allocator.destroy(node);
    }
}

/// 运行循环
pub fn run(self: *Self) !i32 {
    self.status = .running;
    std.debug.print("run: 0x{X}\n", .{@intFromPtr(self)});

    self.end_time = Instant.now() catch unreachable;
    return 0;
}

/// 运行一次 (无检查)
fn run_once_danger(self: *Self) void {
    std.debug.print("run_once: 0x{X}\n", .{@intFromPtr(self)});

    if (self.current) |node| {
        // TODO: 执行事件
        node.event.status = .running;
        std.debug.print("\t   node: 0x{X}\n", .{@intFromPtr(node)});
        node.event.status = .done;
        // 指向下一个
        self.current = node.*.next;
    }
    std.debug.print("\tcurrent: 0x{X}\n", .{@intFromPtr(self.current)});
}

/// 插入事件
pub fn add_event(self: *Self, event: *Event) !void {
    std.debug.print("add_event: 0x{X}\n", .{@intFromPtr(self)});
    // 更新[node_count]
    _ = self.node_count.fetchAdd(1, .monotonic);
    // std.debug.print("node_count: {}\n", .{self.node_count});

    const node = try self.allocator.create(Node);
    node.*.event = event;
    node.*.next = null;
    node.*.id = self.node_count.load(.seq_cst);
    std.debug.print("\tnode: 0x{X}, id: {}\n", .{ @intFromPtr(node), node.id });

    // 插入到队列前加锁
    self.node_mutex.lock();
    defer self.node_mutex.unlock();

    if (self.tail != null) {
        self.tail.?.*.next = node;
    }
    self.tail = node;

    if (self.head == null) {
        self.head = node;
    }

    if (self.current == null) {
        self.current = node;
    }
}

/// 清理一次已执行的事件
pub fn clear_once(self: *Self) void {
    std.debug.print("clear_event: 0x{X}\n", .{@intFromPtr(self)});
    if (self.head) |node| {
        if (node.event.status == .done) {
            std.debug.print("\tnode(to be clear): 0x{X}, id: {}\n", .{ @intFromPtr(node), node.id });
            // head 指向下一个
            self.head = node.next;
            // 当前这个清理掉
            self.allocator.destroy(node);
            std.debug.print("\thead(after clear): 0x{X}, id: {}\n", .{ @intFromPtr(self.head), self.head.?.id });
        }
    }
}

/// 展示事件列表
pub fn show_event(self: *Self) void {
    std.debug.print("show_event: 0x{X}\n", .{@intFromPtr(self)});
    var current_node = self.head;
    while (current_node) |node| {
        std.debug.print("\tnode: 0x{X}, id: {}\n", .{ @intFromPtr(node), node.id });
        current_node = node.next;
    }
}

test "loop" {
    std.debug.print("\n[Loop]: run\n", .{});

    var loop = init(std.testing.allocator);
    std.debug.print("  loop: 0x{X}\n", .{@intFromPtr(&loop)});
    defer loop.deinit();

    _ = try loop.run();
}

test "add_event" {
    std.debug.print("\n[Loop]: add_event\n", .{});
    var loop = init(std.testing.allocator);
    defer loop.deinit();
    for (0..10) |_| {
        var event = .{ .emitTime = Instant.now() catch unreachable };
        try loop.add_event(&event);
    }
    loop.show_event();
}

test "run_once" {
    std.debug.print("\n[Loop]: run_once\n", .{});
    var loop = init(std.testing.allocator);
    defer loop.deinit();

    for (0..2) |_| {
        var event = .{ .emitTime = Instant.now() catch unreachable };
        try loop.add_event(&event);
    }
    loop.show_event();

    loop.run_once_danger();
    loop.run_once_danger();
}

test "clear_once" {
    std.debug.print("\n[Loop]: clear_once\n", .{});
    var loop = init(std.testing.allocator);
    defer loop.deinit();

    for (0..2) |_| {
        var event = .{ .emitTime = Instant.now() catch unreachable };
        try loop.add_event(&event);
    }
    loop.show_event();

    loop.run_once_danger();
    loop.clear_once();
}
