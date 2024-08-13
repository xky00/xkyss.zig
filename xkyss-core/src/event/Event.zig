const std = @import("std");
const Instant = std.time.Instant;

const Self = @This();

// 状态
pub const Status = enum {
    // 普通
    normal,
    // 运行
    running,
    // 已运行
    done,
};

// 成员变量

// 当前状态
status: Status = Status.normal,
// 提交时间
emitTime: Instant,
// 开始执行时间
startTime: ?Instant = null,
// 结束执行时间
endTime: ?Instant = null,

pub fn execute(self: Self) !void {
    std.debug.print("  execute: {}\n", .{self});
}

test "execute" {
    var event = Self{
        .emitTime = Instant.now() catch unreachable,
    };
    try event.execute();
}
