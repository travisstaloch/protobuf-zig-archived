const std = @import("std");
const io = std.io;
const fs = std.fs;
const fmt = std.fmt;
const mem = std.mem;
const Allocator = mem.Allocator;
const clap = @import("deps/zig-clap/clap.zig");
const protozig = @import("lib.zig");
const util = @import("util.zig");
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
        \\--decode <str>            Read a binary message of the given type from
        \\                          standard input and write it in text format
        \\                          to standard output.  The message type must
        \\                          be defined in proto-file-path or their imports.
        \\<str>...                  Proto files
        \\
    );
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
    }) catch |err| {
        diag.report(stderr, err) catch {};
        return err;
    };
    defer res.deinit();

    if (res.args.help)
        return try printHelp(res, stdout, &params, "");

    if (res.positionals.len == 0)
        return try printHelp(res, stderr, &params, "error: missing proto-file-path positional argument.\n\n");

    const protopath = res.positionals[0];
    const proto_file = fs.cwd().openFile(protopath, .{}) catch |e| switch (e) {
        error.FileNotFound => fatal(allr, "couldn't open file {s}\n", .{protopath}),
        else => return e,
    };
    var buf = [1]u8{0} ** std.fs.MAX_PATH_BYTES;
    _ = try fs.cwd().realpath(protopath, &buf);
    const real_protopath = std.mem.sliceTo(&buf, 0);
    defer proto_file.close();
    const raw_contents = try proto_file.readToEndAllocOptions(allr, std.math.maxInt(u32), null, 1, 0);

    // assumes null terminated strings from clap as these come from process.ArgIterator.next()
    // which returns ?[:0]const u8
    if (res.args.decode) |proto_type| {
        var out = std.ArrayList(u8).init(allr);
        defer out.deinit();
        _ = proto_type;
        std.log.err("TODO decode\n", .{});
        return error.Todo;
        // const decoderes = try protozig.decodeToWriter(
        //     allr,
        //     raw_contents,
        //     @ptrCast([*:0]const u8, proto_type.ptr),
        //     @ptrCast([*:0]const u8, real_protopath.ptr),
        //     @ptrCast([]const [:0]const u8, res.args.@"proto-path"),
        //     out.writer(),
        //     stderr,
        // );
        // if (decoderes == .err) std.os.exit(1);
        // _ = try stdout.write(out.items);
    } else {
        const req = try protozig.parseToCodeGenReq(
            allr,
            raw_contents,
            @ptrCast([*:0]const u8, real_protopath.ptr),
            @ptrCast([]const [:0]const u8, res.args.@"proto-path"),
            stdout,
            stderr,
        );

        try req.serialize(stdout);
    }
}
