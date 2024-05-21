const std = @import("std");
const os = std.os;

var s_freq: f64 = 0;

pub fn gethrtime() u64 {
    if (s_freq == 0) {
        const freq = os.windows.QueryPerformanceFrequency();
        s_freq = @as(f64, @floatFromInt(freq)) / 10_000_000;
    }
    if (s_freq != 0) {
        const count = os.windows.QueryPerformanceCounter();
        const r: f64 = @as(f64, @floatFromInt(count)) / s_freq;
        return @intFromFloat(r);
    }
    return 0;
}

pub fn sleep(ms: u64) void {
    std.time.sleep(ms * std.time.ns_per_ms);
}

// test "gethrtime" {
//     const c = @cImport({
//         @cInclude("base/time.h");
//     });

//     const t1: u64 = @intCast(c.gethrtime());
//     const t2 = gethrtime();
//     try std.testing.expect(t2 - t1 < 100);
// }
