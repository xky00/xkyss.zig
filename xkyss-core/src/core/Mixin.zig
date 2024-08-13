const std = @import("std");

const Alice = struct {
    a: u32,

    pub fn getA(this: *Cindy) u32 {
        return this.c;
    }
};

const Bob = struct {
    b: u32,

    pub fn getB(this: *Cindy) u32 {
        return this.c;
    }
};

const Cindy = struct {
    pub usingnamespace Alice;
    pub usingnamespace Bob;

    c: u32,

    pub fn getC(self: *Cindy) u32 {
        return self.c;
    }
};

test "cindy" {
    std.debug.print("cindy\n", .{});
    var x = Cindy{ .c = 100 };

    std.debug.print("x: {}, x.c: {}, x.b: {}, x.a: {}\n", .{ x, x.getC(), x.getB(), x.getA() });
}
