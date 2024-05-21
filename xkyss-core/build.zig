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
    // try depentc(lib, b);
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
    // try depentc(exe, b);
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
    // try depentc(lib_unit_tests, b);
    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // try depentc(exe_unit_tests, b);
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
    test_step.dependOn(&run_exe_unit_tests.step);

    // single test
    const single_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/single.zig"),
        .target = target,
        .optimize = optimize,
    });
    // try depentc(lib_unit_tests, b);
    const run_single_unit_tests = b.addRunArtifact(single_unit_tests);

    const single_step = b.step("single-test", "Run unit tests");
    single_step.dependOn(&run_single_unit_tests.step);
}

fn depentc(c: *std.Build.Step.Compile, b: *std.Build) !void {
    const c_include_path = .{ .path = "cxx/include/" };
    const c_source_files = .{ .root = b.path("cxx/src/"), .files = &.{"base/time.c"}, .flags = &.{} };

    c.addIncludePath(c_include_path);
    c.addCSourceFiles(c_source_files);
    c.linkLibC();
}
