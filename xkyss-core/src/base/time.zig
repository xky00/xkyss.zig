const std = @import("std");
const os = std.os;

var s_freq: f64 = 0;

pub fn gethrtime() u64 {
    if (s_freq == 0) {
        s_freq = @floatFromInt(os.windows.QueryPerformanceFrequency());
        // std.debug.print("s_freq: {}\n", .{s_freq});
    }
    if (s_freq != 0) {
        const f_count: f64 = @floatFromInt(os.windows.QueryPerformanceCounter());
        // std.debug.print("f_count: {}\n", .{f_count});
        return @intFromFloat(f_count / s_freq * 10_000_000);
    }
    return 0;
}

pub fn sleep(ms: u64) void {
    std.time.sleep(ms * std.time.ns_per_ms);
    // std.debug.print("{}\n", .{ms * std.time.ns_per_ms});
}

// test "gethrtime" {
//     const c = @cImport({
//         @cInclude("base/time.h");
//     });

//     for (0..20) |_| {
//         const zt = gethrtime();
//         const ct = c.gethrtime();
//         std.debug.print("z: {}\n", .{zt});
//         std.debug.print("c: {}\n", .{ct});
//         try std.testing.expect(ct - zt < 100);
//     }
// }

// test "sleep" {
//     for (0..10) |i| {
//         sleep(1000);
//         std.debug.print("{}\n", .{i});
//     }
// }

test "QueryPerformanceFrequency" {
    const freq = os.windows.QueryPerformanceFrequency();
    std.debug.print("freq: {}\n", .{freq});
}
