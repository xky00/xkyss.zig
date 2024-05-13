const std = @import("std");
const Loop = @import("Loop.zig");

const Self = @This();
const CallBack = fn (idle: *Self, userdata: ?*anyopaque) void;

// 成员变量
loop: *Loop = undefined,
id: u32 = 0,
repeat: u32 = 0,
cb: CallBack = undefined,
// private:
destroy: u1 = 1,
disable: u1 = 1,
