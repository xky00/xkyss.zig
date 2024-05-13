const std = @import("std");
// const os = std.os;

const c_time = @cImport({
    @cInclude("base/time.h");
});

pub fn gethrtime_c() u64 {
    const t = c_time.gethrtime();
    const r: u64 = @intCast(t);
    return r;
}

pub fn gethrtime() u64 {
    // const freq = os.windows.QueryPerformanceFrequency();
    // const count = os.windows.QueryPerformanceCounter();
    return 0;
}

test "gethrtime" {
    const t1 = c_time.x();
    std.debug.print("t1: {}\n", .{t1});

    const t2 = gethrtime();
    std.debug.print("t2: {}\n", .{t2});
    try std.testing.expectEqual(0, gethrtime());
}
