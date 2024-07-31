const std = @import("std");
const Instant = std.time.Instant;

const Self = @This();

// 状态
pub const Status = enum {
    stop,
    running,
    pause,
};

// 成员变量
status: Status = Status.stop,
start_time: Instant,
end_time: ?Instant,
current_time: Instant,
loop_count: u64 = 0,

/// 构造
pub fn init() Self {
    const current = Instant.now() catch unreachable;
    return .{
        .status = Status.stop,
        .start_time = current,
        .end_time = null,
        .current_time = current,
        .loop_count = 0,
    };
}

/// 析构
pub fn deinit(self: *Self) void {
    std.debug.print("deinit: 0x{X}\n", .{@intFromPtr(self)});
}

/// 运行循环
pub fn run(self: *Self) !i32 {
    self.status = .running;
    std.debug.print("   run: 0x{X}\n", .{@intFromPtr(self)});

    self.end_time = Instant.now() catch unreachable;
    return 0;
}

test "loop" {
    std.debug.print("loop\n", .{});

    var loop = init();
    std.debug.print("  loop: 0x{X}\n", .{@intFromPtr(&loop)});
    defer loop.deinit();

    _ = try loop.run();
}
