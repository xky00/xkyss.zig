const std = @import("std");
const Loop = @import("Loop.zig");

const Self = @This();
pub const CallBack = fn (*Self, *void) void;

// 成员变量
loop: *Loop = undefined,
id: u32 = undefined,
timeout: u32 = 0,
repeat: u32 = undefined,
callback: *const CallBack = undefined,
userdata: *void = undefined,
next_timeout: u64 = undefined,

// private:
destroy: bool = true,
disable: bool = true,
