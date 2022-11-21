const std = @import("std");

pub const log_level: std.log.Level = .debug;

pub fn todo(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.panic("TODO: " ++ fmt ++ "\n", args);
}
