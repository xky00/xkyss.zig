const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    //
    // 导出module
    //
    const module_xkyss_core = b.addModule("xkyss-core", .{ .root_source_file = b.path("src/root.zig") });

    //
    // xkyss-core.lib
    //

    const lib = b.addStaticLibrary(.{
        .name = "xkyss-core",
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib.addIncludePath(.{ .path = "c_src" });
    lib.linkLibC();

    b.installArtifact(lib);

    //
    // xkyss-core.exe
    //

    const exe = b.addExecutable(.{
        .name = "xkyss-core",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    exe.root_module.addImport("xkyss-core", module_xkyss_core);
    b.installArtifact(exe);

    //
    // run main
    //

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    //
    // uni_ttest
    //

    const lib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    lib_unit_tests.addIncludePath(.{ .path = "c_src" });
    lib_unit_tests.linkLibC();

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);
}
