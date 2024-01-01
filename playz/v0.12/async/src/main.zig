const std = @import("std");

const print = @import("std").debug.print;

pub fn main() void {
    // Additional Hint: you can assign things to '_' when you
    // don't intend to do anything with them.
    _ = async foo();
}

fn foo() void {
    print("foo() A\n", .{});
    suspend {}
    print("foo() B\n", .{});
}
