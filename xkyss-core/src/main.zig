const std = @import("std");
const ks = @import("xkyss-core");

const c = @cImport({
    @cInclude("base/time.h");
});

pub fn main() !void {
    for (0..20) |_| {
        const zt = ks.time.gethrtime();
        const ct = c.gethrtime();
        const it = (try std.time.Instant.now()).timestamp;
        std.debug.print("z: {}\n", .{zt});
        std.debug.print("c: {}\n", .{ct});
        std.debug.print("i: {}\n", .{it});
    }
}
