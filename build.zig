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

    // const exe_tests = b.addTest("src/protoc-gen.zig");
    // exe_tests.setTarget(target);
    // exe_tests.setBuildMode(mode);

    // const test_step = b.step("test", "Run unit tests");
    // test_step.dependOn(&exe_tests.step);
}
