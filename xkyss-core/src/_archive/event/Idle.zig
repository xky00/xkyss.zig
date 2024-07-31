const std = @import("std");
const Loop = @import("Loop.zig");

const Self = @This();
pub const CallBack = fn (*Self, *void) void;

// 成员变量
loop: *Loop = undefined,
id: u32 = 0,
repeat: u32 = 0,
callback: *const CallBack = undefined,
userdata: *void = undefined,
// private:
destroy: bool = true,
disable: bool = true,
