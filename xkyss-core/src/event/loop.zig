//! 基础轮询

const std = @import("std");
const Self = @This();

a: u32 = 0,

pub fn init(self: *Self) i32 {
    std.debug.print("init loop: {}\n", .{ self });
    return 0;
}

pub fn run(self: *Self) i32 {
    std.debug.print("init run: {}\n", .{ self });
    return 0;
}

pub fn stop(self: *Self) i32 {
    std.debug.print("init stop: {}\n", .{ self });
    return 0;
}

pub fn pause(self: *Self) i32 {
    std.debug.print("init pause: {}\n", .{ self });
    return 0;
}

pub fn @"resume"(self: *Self) i32 {
    std.debug.print("init resume: {}\n", .{ self });
    return 0;
}



test "init" {
    var loop = .{ .a = 111 };
    _ = init(&loop);
}

test "run" {
    var loop = .{ .a = 111 };
    _ = run(&loop);
}

test "stop" {
    var loop = .{ .a = 111 };
    _ = stop(&loop);
}

test "pause" {
    var loop = .{ .a = 111 };
    _ = pause(&loop);
}

test "resume" {
    var loop = .{ .a = 111 };
    _ = @"resume"(&loop);
}