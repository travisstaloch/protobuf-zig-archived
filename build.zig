const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();

    const protocgen_echo = b.addExecutable("protoc-gen-zig", "src/protoc-gen-echo.zig");
    protocgen_echo.setTarget(target);
    protocgen_echo.setBuildMode(mode);
    protocgen_echo.install();
    const decoding_pkg = std.build.Pkg{
        .name = "decoding",
        .source = .{ .path = "src/decoding.zig" },
    };
    protocgen_echo.addPackage(decoding_pkg);

    const protoc_zig = b.addExecutable("protoc-zig", "src/main.zig");
    protoc_zig.setTarget(target);
    protoc_zig.setBuildMode(mode);
    protoc_zig.install();
    protoc_zig.addPackage(decoding_pkg);

    const run_cmd = protoc_zig.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const parsing_test = b.addExecutable("parsing-test", "src/test-parser.zig");
    parsing_test.setTarget(target);
    parsing_test.setBuildMode(mode);
    parsing_test.install();
    parsing_test.addPackage(decoding_pkg);

    const parsing_test_step = b.step("parsing-test", "Run a parsing test");
    const parsing_test_run_cmd = parsing_test.run();
    parsing_test_run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| parsing_test_run_cmd.addArgs(args);
    parsing_test_step.dependOn(&parsing_test_run_cmd.step);

    // const exe_tests = b.addTest("src/protoc-gen.zig");
    // exe_tests.setTarget(target);
    // exe_tests.setBuildMode(mode);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&exe_tests.step);
}
