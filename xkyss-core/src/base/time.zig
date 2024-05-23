const std = @import("std");
const os = std.os;
const Instant = std.time.Instant;

pub fn gethrtime() u64 {
    const current = Instant.now() catch return 0;
    return current.timestamp;
}

pub fn now() Instant {
    return Instant.now() catch unreachable;
}

pub fn ms_future(ms: u64) Instant {
    const t = now().timestamp + ms * std.time.ns_per_ms;
    return .{ .timestamp = t };
}

pub fn sleep(ms: u64) void {
    std.time.sleep(ms * std.time.ns_per_ms);
    // std.debug.print("{}\n", .{ms * std.time.ns_per_ms});
}

// test "gethrtime" {
//     const c = @cImport({
//         @cInclude("base/time.h");
//     });
// for (0..20) |_| {
//     const zt = ks.time.gethrtime();
//     const ct = c.gethrtime();
//     const it = (try std.time.Instant.now()).timestamp;
//     std.debug.print("z: {}\n", .{zt});
//     std.debug.print("c: {}\n", .{ct});
//     std.debug.print("i: {}\n", .{it});
// }
// }

// test "sleep" {
//     for (0..10) |i| {
//         sleep(1000);
//         std.debug.print("{}\n", .{i});
//     }
// }

// test "QueryPerformanceFrequency" {
//     const freq = os.windows.QueryPerformanceFrequency();
//     std.debug.print("freq: {}\n", .{freq});
// }

test ms_future {
    const t1 = now();
    const t2 = ms_future(5);
    const t3 = std.time.nanoTimestamp();
    std.debug.print("\n", .{});
    std.debug.print("   now: {}\n", .{t1});
    std.debug.print("future: {}\n", .{t2});
    std.debug.print("  nono: {}\n", .{t3});
    std.debug.print(" delta: {}\n", .{Instant.since(t2, t1)});
}
