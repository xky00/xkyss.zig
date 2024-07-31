const std = @import("std");
const Loop = @import("Loop.zig");

const Self = @This();
pub const CallBack = fn (*Self, *void) void;

// 成员变量
loop: *Loop = undefined,
id: u32 = undefined,
timeout: u32 = 0, // ms
repeat: u32 = undefined,
callback: *const CallBack = undefined,
userdata: *void = undefined,
previous: std.time.Instant,

// private:
destroy: bool = true,
disable: bool = true,
