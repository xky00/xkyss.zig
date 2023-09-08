const std = @import("std");

pub fn main() !void {
    const dllpath =
        // 绝对路径
        // \\E:\xk\Code\xkyss\xkyss.zig\playground\v0.12\dll\main.dll
        // 相对路径
        \\../dll/main.dll
    ;
    std.debug.print("Dll Path: {s}\n", .{dllpath});

    // 加载dll
    _ = try std.DynLib.open(dllpath);
}
