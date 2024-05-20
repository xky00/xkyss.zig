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
    var loop: Self = .{};
    loop.allocator = allocator;
    loop.idles = IdleMap.init(allocator);
    return loop;
}

pub fn deinit() !void {}

pub fn run(self: *Self) i32 {
    std.debug.print("run: {}\n", .{self});

    // 轮询前
    self.status = Status.running;
    self.loop_count = 0;
    self.start_time = Time.gethrtime();

    // 轮询
    while (self.status != Status.stop) {
        self.current_time = Time.gethrtime();
        // std.debug.print("run {}\n", .{self.current_time});

        if (self.status == Status.pause) {
            Time.sleep(pause_sleep_time);
            continue;
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
        std.time.sleep(pause_sleep_time);
        // }
        // if (ntimer == 0 && nevent == 0 && loop->idles.size() != 0) {
        //     nidle = hloop_handle_idles(loop);
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

pub fn add_idle(self: *Self, callback: *const fn () void, userdata: *void, repeat: u32) !*Idle {
    std.debug.print("add_idle", .{});
    std.debug.print("\tcallback: {}", .{callback});
    std.debug.print("\tuserdata: {}", .{userdata});
    std.debug.print("\trepeat: {}", .{repeat});
    std.debug.print("\n", .{});

    var idle = try std.heap.page_allocator.create(Idle);
    idle.loop = self;
    self.idle_count += 1;
    idle.id = self.idle_count;
    idle.callback = callback;
    idle.userdata = userdata;
    idle.repeat = repeat;
    try self.idles.put(idle.id, idle);
    return idle;
}

pub fn del_idle(self: *Self, idle_id: u32) void {
    _ = self;
    std.debug.print("del_idle", .{});
    std.debug.print("\t idle_id: {}", .{idle_id});
}

fn cleanup(self: *Self) void {
    std.debug.print("cleanup: {}\n", .{self});
}

test "run" {
    std.debug.print("ignore\n", .{});
    // var loop = Self{};
    // _ = run(&loop);
}

test "stop" {
    var loop2 = Self{};
    _ = stop(&loop2);
}

test "pause" {
    var loop3 = Self{};
    _ = pause(&loop3);
}

test "resume" {
    var loop4 = Self{};
    _ = unpause(&loop4);
}

fn test_cb() void {
    std.debug.print("test_cb: idle: , ud: ", .{});
}

test "add_idle" {
    var loop5 = Self{};
    var x: u32 = 99;
    const ud: *void = @ptrCast(&x);
    const idle = try loop5.add_idle(&test_cb, ud, 5);
    std.debug.print("\nidle: {}\n", .{idle});
}
