//! 基础轮询
//!
const std = @import("std");
const Time = @import("../base/time.zig");
const Idle = @import("Idle.zig");

const Self = @This();
const IdleMap = std.AutoHashMap(u32, *Idle);
// const IdleCallback = fn (*Idle, *void) void;

// 状态
pub const Status = enum {
    stop,
    running,
    pause,
};

const pause_sleep_time: u64 = 10; // ms
const min_event_timeout: u64 = 1; // ms
const max_event_timeout: u64 = 1000; // ms

// 成员变量
allocator: std.mem.Allocator,
status: Status = Status.stop,
start_time: u64 = 0,
end_time: u64 = 0,
current_time: u64 = 0,
loop_count: u64 = 0,
idle_count: u32 = 0,
idles: IdleMap = undefined,

pub fn init(allocator: std.mem.Allocator) Self {
    const loop: Self = .{
        .allocator = allocator,
        .idles = IdleMap.init(allocator),
    };
    return loop;
}

pub fn deinit(self: *Self) void {
    self.idles.deinit();
}

pub fn run(self: *Self) !i32 {
    std.debug.print("run: {}\n", .{self});

    // 轮询前
    self.status = Status.running;
    self.loop_count = 0;
    self.start_time = Time.gethrtime();
    // 轮询
    // for (0..10) |i| {
    while (self.status != Status.stop) {
        self.current_time = Time.gethrtime();
        // std.debug.print("loop {} at {}\n", .{ i, self.current_time });
        std.debug.print("loop {} at {}\n", .{ self.loop_count, self.current_time });

        if (self.status == Status.pause) {
            Time.sleep(pause_sleep_time);
            // continue;
        }
        self.loop_count += 1;
        // // timers -> events -> idles
        // ntimer = nevent = nidle = 0;
        // event_timeout = INFINITE;
        // if (loop->timers.size() != 0) {
        //     ntimer = hloop_handle_timers(loop);
        //     event_timeout = MAX(MIN_EVENT_TIMEOUT, loop->min_timer_timeout/10);
        // }
        // if (loop->events.size() == 0 || loop->idles.size() != 0) {
        //     event_timeout = MIN(event_timeout, MAX_EVENT_TIMEOUT);
        // }
        // if (loop->events.size() != 0) {
        //     nevent = hloop_handle_events(loop, event_timeout);
        // }
        // else {
        //     msleep(event_timeout);
        Time.sleep(pause_sleep_time);
        // }
        // if (ntimer == 0 && nevent == 0 && loop->idles.size() != 0) {
        const nidle = try self.handle_idles();
        std.debug.print("\tnidle: {}\n", .{nidle});
        // }
    }

    // 轮询后
    self.status = Status.stop;
    self.end_time = Time.gethrtime();
    self.cleanup();

    return 0;
}

pub fn stop(self: *Self) i32 {
    std.debug.print("stop: {}\n", .{self});
    std.debug.print("\tstatus {}", .{self.status});
    self.status = Status.stop;
    std.debug.print(" => {}\n", .{self.status});
    std.debug.print("bye.\n", .{});
    return 0;
}

pub fn pause(self: *Self) i32 {
    std.debug.print("pause", .{});
    std.debug.print("\tstatus {}", .{self.status});
    if (self.status == Status.running) {
        self.status = Status.pause;
    }
    std.debug.print(" => {}\n", .{self.status});
    return 0;
}

pub fn unpause(self: *Self) i32 {
    std.debug.print("resume", .{});
    std.debug.print("\tstatus {}", .{self.status});
    if (self.status == Status.pause) {
        self.status = Status.running;
    }
    std.debug.print(" => {}\n", .{self.status});
    return 0;
}

pub fn add_idle(self: *Self, callback: *const fn (*Idle, *void) void, userdata: *void, repeat: u32) !*Idle {
    std.debug.print("add_idle", .{});
    std.debug.print("\tcallback: {}", .{callback});
    std.debug.print("\tuserdata: {}", .{userdata});
    std.debug.print("\trepeat: {}", .{repeat});
    std.debug.print("\n", .{});

    var idle = try self.allocator.create(Idle);
    idle.loop = self;
    self.idle_count += 1;
    idle.id = self.idle_count;
    idle.callback = callback;
    idle.userdata = userdata;
    idle.repeat = repeat;
    try self.idles.put(idle.id, idle);
    return idle;
}

pub fn del_idle(self: *Self, idle_id: u32) bool {
    std.debug.print("del_idle", .{});

    const removed = self.idles.fetchRemove(idle_id);
    if (removed) |kv| {
        kv.value.destroy = true;
        std.debug.print("\tremove Success. {}\n", .{kv.value});
        return true;
    } else {
        std.debug.print("\tremove Failed. idle_id: {}\n", .{idle_id});
        return false;
    }
}

pub fn handle_idles(self: *Self) !u32 {
    std.debug.print("handle_idles\n", .{});

    var nidle: u32 = 0;
    var it = self.idles.valueIterator();
    while (it.next()) |pidle| {
        const idle = pidle.*;
        if (idle.destroy or idle.repeat == 0) {
            _ = self.idles.remove(idle.id);
            self.allocator.destroy(idle);
            continue;
        }
        if (idle.disable) {
            continue;
        }
        idle.callback(idle, idle.userdata);
        std.debug.print("\n\trepeat: {}\n", .{idle.repeat});
        if (idle.repeat != 0xFFFFFFFF) {
            idle.repeat -= 1;
        }
        nidle += 1;
    }

    return nidle;
}

fn cleanup(self: *Self) void {
    std.debug.print("cleanup: {}\n", .{self});
}

fn stop_async(self: *Self) !void {
    _ = try std.Thread.spawn(.{}, (struct {
        fn runner(loop: *Self) void {
            std.debug.print("runner", .{});
            Time.sleep(1000);
            _ = loop.stop();
        }
    }).runner, .{self});
}

test "init & deinit" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var loop = Self.init(allocator);
    defer loop.deinit();
}

test "run" {
    std.debug.print("ignore\n", .{});
    // var loop = Self{};
    // _ = run(&loop);
}

test "stop" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var loop = Self.init(allocator);
    defer loop.deinit();
    _ = stop(&loop);
}

test "pause" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var loop = Self.init(allocator);
    defer loop.deinit();
    _ = pause(&loop);
}

test "resume" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var loop = Self.init(allocator);
    defer loop.deinit();
    _ = unpause(&loop);
}

fn test_cb(idle: *Idle, ud: *void) void {
    std.debug.print("test_cb: idle: {}, ud: {}", .{ idle, ud });
}

test "add_idle" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var loop = Self.init(allocator);
    defer loop.deinit();
    var x: u32 = 99;
    const ud: *void = @ptrCast(&x);
    const idle = try loop.add_idle(&test_cb, ud, 5);
    std.debug.print("\nidle: {}\n", .{idle});
}

test "del_idle" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var loop = Self.init(allocator);
    defer loop.deinit();
    var x: u32 = 99;
    const ud: *void = @ptrCast(&x);
    const idle = try loop.add_idle(&test_cb, ud, 5);
    std.debug.print("\n idle: {}\n", .{idle});

    _ = loop.del_idle(idle.id);
    _ = loop.del_idle(idle.id);
}

test "run with idles" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var loop = Self.init(allocator);
    defer loop.deinit();
    var x: u32 = 99;
    const ud: *void = @ptrCast(&x);
    _ = try loop.add_idle(&test_cb, ud, 5);
    // std.debug.print("\nidle: {}\n", .{idle});

    try loop.stop_async();
    _ = try loop.run();
}
