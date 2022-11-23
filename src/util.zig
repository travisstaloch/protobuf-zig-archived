const std = @import("std");

pub const log_level: std.log.Level = .err;

pub fn todo(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.panic("TODO: " ++ fmt ++ "\n", args);
}
