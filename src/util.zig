const std = @import("std");

const log_level_str = @import("build_options").log_level;
pub const log_level: std.log.Level = std.meta.stringToEnum(std.log.Level, log_level_str) orelse
    @compileError("invalid log-level '" ++ log_level_str ++ "'");

pub fn todo(comptime fmt: []const u8, args: anytype) noreturn {
    std.debug.panic("TODO: " ++ fmt ++ "\n", args);
}
