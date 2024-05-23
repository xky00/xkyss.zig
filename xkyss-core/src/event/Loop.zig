//! 基础轮询
//!
const std = @import("std");
const Instant = std.time.Instant;
const Time = @import("../base/time.zig");
const Idle = @import("Idle.zig");
const Timer = @import("Timer.zig");

const Self = @This();
const IdleMap = std.AutoHashMap(u32, *Idle);
const TimerMap = std.AutoHashMap(u32, *Timer);

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
start_time: Instant,
end_time: Instant,
current_time: Instant,
loop_count: u64 = 0,

// for idle
idle_count: u32 = 0,
idles: IdleMap = undefined,

// for timer
timer_count: u32 = 0,
min_timer_timeout: u32 = 0,
timers: TimerMap = undefined,

pub fn init(allocator: std.mem.Allocator) Self {
    const loop: Self = .{
        .allocator = allocator,
        .idles = IdleMap.init(allocator),
        .timers = TimerMap.init(allocator),
        .start_time = Time.now(),
        .end_time = Time.now(),
        .current_time = Time.now(),
    };
    return loop;
}

pub fn deinit(self: *Self) void {
    std.debug.print("\ndeinit\n", .{});
    // deinit idles
    {
        var it = self.idles.valueIterator();
        while (it.next()) |pidle| {
            self.allocator.destroy(pidle.*);
        }
        self.idles.deinit();
    }
    // deinit timers
    {
        var it = self.timers.valueIterator();
        while (it.next()) |ptimer| {
            self.allocator.destroy(ptimer.*);
        }
        self.timers.deinit();
    }
}

pub fn run(self: *Self) !i32 {
    std.debug.print("run: {}\n", .{self});

    // 轮询前
    self.status = Status.running;
    self.loop_count = 0;
    self.start_time = Time.now();
    // 轮询
    // for (0..10) |i| {
    while (self.status != Status.stop) {
        const delta = Instant.since(Time.now(), self.current_time);
        self.current_time = Time.now();
        // std.debug.print("loop {} at {}\n", .{ i, self.current_time });
        std.debug.print("pause_sleep_time: {}, delta: {}\n", .{ pause_sleep_time, delta });
        std.debug.print("loop {} at {}\n", .{ self.loop_count, self.current_time });

        if (self.status == Status.pause) {
            Time.sleep(pause_sleep_time);
            continue;
        }
        self.loop_count += 1;
        // // timers -> events -> idles
        // ntimer = nevent = nidle = 0;
        var nidle: u32 = 0;
        var ntimer: u32 = 0;
        // event_timeout = INFINITE;
        // if (loop->timers.size() != 0) {
        //     ntimer = hloop_handle_timers(loop);
        //     event_timeout = MAX(MIN_EVENT_TIMEOUT, loop->min_timer_timeout/10);
        // }
        if (self.timers.count() != 0) {
            ntimer = try self.handle_timers();
        }
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
        if (ntimer == 0 and self.idles.count() != 0) {
            nidle = try self.handle_idles();
        }
        // std.debug.print("\tnidle: {}, ntimer: {}\n", .{ nidle, ntimer });
        // }
    }

    // 轮询后
    self.status = Status.stop;
    self.end_time = Time.now();

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
    std.debug.print("\tcallback: {}, userdata: {}, repeat: {}", .{ callback, userdata, repeat });
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
    std.debug.print("\ndel_idle", .{});

    const removed = self.idles.fetchRemove(idle_id);
    if (removed) |kv| {
        kv.value.destroy = true;
        std.debug.print("\tremove Success. idle_id: {}\n", .{idle_id});
        self.allocator.destroy(kv.value);
        // std.debug.print("\t.......{}\n", .{self.idles.count()});
        return true;
    } else {
        std.debug.print("\tremove Failed.  idle_id: {}\n", .{idle_id});
        return false;
    }
}

pub fn handle_idles(self: *Self) !u32 {
    std.debug.print("handle_idles\n", .{});

    var nidle: u32 = 0;
    // 记录需要删除的键
    var ids_to_remove = std.ArrayList(u32).init(self.allocator);
    defer ids_to_remove.deinit();

    var it = self.idles.valueIterator();
    while (it.next()) |pidle| {
        const idle = pidle.*;
        if (idle.destroy or idle.repeat == 0) {
            try ids_to_remove.append(idle.id);
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

    // 删除记录的键
    for (ids_to_remove.items) |id| {
        _ = self.del_idle(id);
    }

    return nidle;
}

pub fn add_timer(self: *Self, callback: *const fn (*Timer, *void) void, userdata: *void, timeout: u32, repeat: u32) !*Timer {
    std.debug.print("add_timer", .{});
    std.debug.print("\tcallback: {}, userdata: {}, timeout: {}, repeat: {}", .{ callback, userdata, timeout, repeat });
    std.debug.print("\n", .{});

    var timer = try self.allocator.create(Timer);
    timer.loop = self;
    self.timer_count += 1;
    timer.id = self.timer_count;
    timer.callback = callback;
    timer.userdata = userdata;
    timer.timeout = timeout;
    timer.repeat = repeat;
    timer.previous = Instant{ .timestamp = 0 };
    try self.timers.put(timer.id, timer);
    return timer;
}

pub fn del_timer(self: *Self, timer_id: u32) bool {
    std.debug.print("del_timer", .{});
    const removed = self.timers.fetchRemove(timer_id);
    if (removed) |kv| {
        kv.value.destroy = true;
        std.debug.print("\tremove Success. timer_id: {}\n", .{timer_id});
        self.allocator.destroy(kv.value);
        // std.debug.print("\t.......{}\n", .{self.timers.count()});
        return true;
    } else {
        std.debug.print("\tremove Failed. timer_id: {}\n", .{timer_id});
        return false;
    }
}

pub fn handle_timers(self: *Self) !u32 {
    std.debug.print("handle_timers\n", .{});

    var ntimer: u32 = 0;
    // 记录需要删除的键
    var ids_to_remove = std.ArrayList(u32).init(self.allocator);
    defer ids_to_remove.deinit();

    var it = self.timers.valueIterator();
    while (it.next()) |ptimer| {
        const timer = ptimer.*;
        if (timer.destroy or timer.repeat == 0) {
            try ids_to_remove.append(timer.id);
            continue;
        }
        if (timer.disable) {
            continue;
        }

        // 已经过去多久 (ms)
        const t = Instant.since(self.current_time, timer.previous) / std.time.ns_per_ms;
        std.debug.print("t: {}, timeout: {}, previous: {}, current: {}\n", .{ t, timer.timeout, timer.previous.timestamp, self.current_time.timestamp });
        if (t > timer.timeout) {
            // std.debug.print("-----lt\n", .{});
            ntimer += 1;
            timer.callback(timer, timer.userdata);
            timer.previous = Time.now();
            if (timer.repeat != 0xFFFFFFFF) {
                timer.repeat -= 1;
            }
        }
    }

    // 删除记录的键
    for (ids_to_remove.items) |id| {
        _ = self.del_timer(id);
    }

    return ntimer;
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

// test "init & deinit" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
// }

// test "run" {
//     std.debug.print("ignore\n", .{});
//     // var loop = Self{};
//     // _ = run(&loop);
// }

// test "stop" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     _ = stop(&loop);
// }

// test "pause" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     _ = pause(&loop);
// }

// test "resume" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     _ = unpause(&loop);
// }

// fn test_idle_cb(idle: *Idle, ud: *void) void {
//     std.debug.print("test_cb: idle: {}, ud: {}", .{ idle, ud });
// }

// test "add_idle" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     var x: u32 = 99;
//     const ud: *void = @ptrCast(&x);
//     const idle = try loop.add_idle(&test_idle_cb, ud, 5);
//     std.debug.print("\nidle: {}\n", .{idle});
// }

// test "del_idle" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     var x: u32 = 99;
//     const ud: *void = @ptrCast(&x);
//     const idle = try loop.add_idle(&test_idle_cb, ud, 5);
//     const idle_id = idle.id;
//     std.debug.print("\n idle: {}\n", .{idle});

//     _ = loop.del_idle(idle_id);
//     _ = loop.del_idle(idle_id);
// }

// test "run with idles" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     var x: u32 = 99;
//     const ud: *void = @ptrCast(&x);
//     _ = try loop.add_idle(&test_idle_cb, ud, 5);
//     // std.debug.print("\nidle: {}\n", .{idle});

//     try loop.stop_async();
//     _ = try loop.run();
// }

fn test_timer_cb(timer: *Timer, ud: *void) void {
    std.debug.print("test_timer_cb: timer: {}, ud: {}\n", .{ timer.id, ud });
}

// test "add_timer" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     var x: u32 = 99;
//     const ud: *void = @ptrCast(&x);
//     const idle = try loop.add_timer(&test_timer_cb, ud, 5, 5);
//     std.debug.print("\ntimer: {}\n", .{idle});
// }

// test "del_timer" {
//     var loop = Self.init(std.testing.allocator);
//     defer loop.deinit();
//     var x: u32 = 99;
//     const ud: *void = @ptrCast(&x);
//     const timer = try loop.add_timer(&test_timer_cb, ud, 5, 5);
//     const timer_id = timer.id;
//     std.debug.print("\n timer: {}\n", .{timer});

//     _ = loop.del_timer(timer_id);
//     _ = loop.del_timer(timer_id);
// }

test "run with timers" {
    var loop = Self.init(std.testing.allocator);
    defer loop.deinit();
    var x: u32 = 99;
    const ud: *void = @ptrCast(&x);
    _ = try loop.add_timer(&test_timer_cb, ud, 100, 5);
    // std.debug.print("\ntimer: {}\n", .{timer});

    try loop.stop_async();
    _ = try loop.run();
}
