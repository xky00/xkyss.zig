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

pub fn deinit(self: Self) void {
    std.debug.print("deinit: {}\n", .{&self});
}

pub fn run(self: *Self) !i32 {
    self.status = .running;
    std.debug.print("run: {}\n", .{self});
}

test "loop" {
    std.debug.print("loop\n", .{});

    const loop = init();
    std.debug.print("loop: {}\n", .{loop});
    defer loop.deinit();
}
