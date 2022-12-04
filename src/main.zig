const std = @import("std");
const io = std.io;
const fs = std.fs;
const fmt = std.fmt;
const mem = std.mem;
const Allocator = mem.Allocator;
const clap = @import("deps/zig-clap/clap.zig");
const protozig = @import("lib.zig");
const util = @import("util.zig");
const parser = @import("parser.zig");
pub const log_level = util.log_level;

fn fatal(allocator: Allocator, comptime format: []const u8, args: anytype) noreturn {
    exit: {
        const msg = fmt.allocPrint(allocator, "fatal: " ++ format, args) catch break :exit;
        defer allocator.free(msg);
        io.getStdErr().writeAll(msg) catch {};
    }
    std.process.exit(1);
}

fn printHelp(res: anytype, writer: anytype, params: anytype, comptime errfmt: []const u8) !void {
    const header =
        \\usage: {s} ?options proto-file-path
        \\
        \\  options may be in any order, and come before or after positional arguments.
        \\
        \\options:
        \\
    ;

    const exe = if (res.exe_arg) |ea| std.fs.path.basename(ea) else "protozig";
    try writer.print(errfmt ++ header, .{exe});
    return clap.help(writer, clap.Help, params, .{});
}

pub fn main() !void {
    const stderr = std.io.getStdErr().writer();
    const stdout = std.io.getStdOut().writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allr = arena.allocator();
    // const args = try std.process.argsAlloc(allr);
    // try stdout.print("args {s}\n", .{args});

    const params = comptime clap.parseParamsComptime(
        \\-h, --help                Display this help and exit.
        \\-I, --proto-path <str>... Include paths for resolving imports.
        \\--encode <str>     TODO - Read a text-format message of the given type
        \\                          from standard input and write it in binary
        \\                          to standard output.  The message type must
        \\                          be defined in proto-files or their imports.
        \\--decode <str>     TODO - Read a binary message of the given type from
        \\                          standard input and write it in text format
        \\                          to standard output.  The message type must
        \\                          be defined in proto-files or their imports.
        \\<str>...                  Proto files
        \\
    );
    var diag = clap.Diagnostic{};
    var clap_result = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        diag.report(stderr, err) catch {};
        return err;
    };
    defer clap_result.deinit();

    if (clap_result.args.help)
        return try printHelp(clap_result, stdout, &params, "");

    if (clap_result.positionals.len == 0)
        return try printHelp(clap_result, stderr, &params, "error: missing proto-file-path positional argument.\n\n");

    const protopath = clap_result.positionals[0];
    const proto_file = fs.cwd().openFile(protopath, .{}) catch |e| switch (e) {
        error.FileNotFound => fatal(allr, "couldn't open file {s}\n", .{protopath}),
        else => return e,
    };
    var buf = [1]u8{0} ** std.fs.MAX_PATH_BYTES;
    _ = try fs.cwd().realpath(protopath, &buf);
    const real_protopath = std.mem.sliceTo(&buf, 0);
    defer proto_file.close();
    const raw_contents = try proto_file.readToEndAllocOptions(allr, std.math.maxInt(u32), null, 1, 0);
    const include_paths = @ptrCast([]const [:0]const u8, clap_result.args.@"proto-path");
    const protopathz = @ptrCast([*:0]const u8, real_protopath.ptr);

    // assumes null terminated strings from clap as these come from process.ArgIterator.next()
    // which returns ?[:0]const u8
    if (clap_result.args.decode) |proto_type| {
        util.todo(
            \\ decode
            \\ Read a binary message of the given type from
            \\ standard input and write it in text format
            \\ to standard output
        , .{});
        var out = std.ArrayList(u8).init(allr);
        defer out.deinit();
        const prototypez = @ptrCast([*:0]const u8, proto_type.ptr);

        var pparser = parser.init(allr, protopathz, raw_contents, include_paths, stdout);
        const req = try pparser.parse();
        _ = req;
        _ = prototypez;
    } else if (clap_result.args.encode) |proto_type| {
        _ = proto_type;
        util.todo(
            \\ encode
            \\ Read a text-format message of the given type
            \\ from standard input and write it in binary
            \\ to standard output.
        , .{});
    } else {
        const req = try protozig.parseToCodeGenReq(
            allr,
            raw_contents,
            protopathz,
            include_paths,
            stderr,
        );

        try req.serialize(stdout);
    }
}
