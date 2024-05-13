//! 基础轮询

const std = @import("std");
const os = @import("os");
const Self = @This();

// 状态
pub const Status = enum {
    stop,
    running,
    pause,
};

// 成员变量
status: Status = Status.stop,
start_time: u64 = 0,
end_time: u64 = 0,
current_time: u64 = 0,
loop_count: u64 = 0,

pub fn run(self: *Self) i32 {
    std.debug.print("run: {}\n", .{self});

    // 轮询前
    self.status = Status.running;
    self.loop_count = 5;
    self.start_time = 1;

    // 轮询
    // while (self.status != Status.stop) {
    // hloop_update_time(loop);
    // if (loop->status == HLOOP_STATUS_PAUSE) {
    //     msleep(PAUSE_SLEEP_TIME);
    //     continue;
    // }
    // self.loop_count += 1;
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
    // }
    // if (ntimer == 0 && nevent == 0 && loop->idles.size() != 0) {
    //     nidle = hloop_handle_idles(loop);
    // }
    // }

    // 轮询后
    self.status = Status.stop;
    self.end_time = 1222;
    self.cleanup();

    return 0;
}

pub fn stop(self: *Self) i32 {
    std.debug.print("stop: {}\n", .{self});
    return 0;
}

pub fn pause(self: *Self) i32 {
    std.debug.print("pause: {}\n", .{self});
    return 0;
}

pub fn @"resume"(self: *Self) i32 {
    std.debug.print("resume: {}\n", .{self});
    return 0;
}

fn cleanup(self: *Self) void {
    std.debug.print("cleanup: {}\n", .{self});
}

test "run" {
    var loop = Self{};
    _ = run(&loop);
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
    _ = @"resume"(&loop4);
}
