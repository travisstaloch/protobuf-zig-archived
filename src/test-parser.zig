// $ zig build && zig run src/test-parser.zig --pkg-begin decoding src/decoding.zig --pkg-end -- examples examples/pkg_enum.proto
// $ zig build parsing-test -- examples examples/only_enum.proto

const std = @import("std");
const parser = @import("parser.zig");
const decoding = @import("decoding.zig");
const types = @import("types.zig");
const gen_json = @import("gen-json.zig");
const plugin = types.plugin;
const CodeGeneratorRequest = plugin.CodeGeneratorRequest;

fn usage(basename: []const u8) void {
    std.debug.print("Usage: {s} <?include-path> <proto-path>\n", .{basename});
    std.debug.print("       include-path - default 'examples'\n", .{});
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allr = arena.allocator();
    var env_map = try std.process.getEnvMap(allr);
    const env_path = env_map.get("PATH") orelse "";
    const path = try std.fmt.allocPrintZ(allr, "{s}:{s}", .{ "zig-out/bin", env_path });
    try env_map.put("PATH", path);
    const args = try std.process.argsAlloc(allr);

    const protoc_payload = blk: {
        const protoc_path = "protoc";
        const argv: []const []const u8 = switch (args.len) {
            2 => &.{ protoc_path, "--zig_out=gen", "-Iexamples", args[1] },
            3 => &.{ protoc_path, "--zig_out=gen", "-I", args[1], args[2] },
            else => {
                usage(std.fs.path.basename(args[0]));
                return error.Args;
            },
        };
        const res = try std.ChildProcess.exec(.{
            .argv = argv,
            .allocator = allr,
            .env_map = &env_map,
        });
        break :blk res.stderr;
    };
    const zig_protoc_payload = blk: {
        const zig_protoc_path = "zig-out/bin/protoc-zig";
        const argv: []const []const u8 = switch (args.len) {
            2 => &.{ zig_protoc_path, "-Iexamples", args[1] },
            3 => &.{ zig_protoc_path, "-I", args[1], args[2] },
            else => {
                usage(std.fs.path.basename(args[0]));
                return error.Args;
            },
        };
        const res = try std.ChildProcess.exec(.{
            .argv = argv,
            .allocator = allr,
            .env_map = &env_map,
        });
        std.debug.print("protoc-zig stderr {s}\n", .{res.stderr});
        std.debug.print("protoc-zig stdout {s}\n", .{std.fmt.fmtSliceHexLower(res.stdout)});
        break :blk res.stdout;
    };

    const protoc_req = blk: {
        var req: CodeGeneratorRequest = .{};
        var fbs = std.io.fixedBufferStream(protoc_payload);
        try req.deserialize(allr, fbs.reader());
        break :blk req;
    };

    const zig_protoc_req = blk: {
        var req: CodeGeneratorRequest = .{};
        var fbs = std.io.fixedBufferStream(zig_protoc_payload);
        try req.deserialize(allr, fbs.reader());
        break :blk req;
    };

    var err = std.ArrayList(u8).init(allr);
    const stdout = std.io.getStdOut().writer();
    try gen_json.writeJson(protoc_req, stdout);
    _ = try stdout.write("\n\n");
    try gen_json.writeJson(zig_protoc_req, stdout);
    _ = try stdout.write("\n\n");
    var buf: [256]u8 = undefined;
    try compare(protoc_req, zig_protoc_req, err.writer(), 0, "", &buf);
    if (err.items.len > 0) {
        std.debug.print("ERROR:\n{s}\n", .{err.items});
        return error.DifferingCodeGenRequests;
    }
}

const CmpErr = error{ Diff, OutOfMemory, AccessDenied, BrokenPipe, ConnectionResetByPeer, DiskQuota, FileTooBig, InputOutput, LockViolation, NoSpaceLeft, NotOpenForWriting, OperationAborted, SystemResources, Unexpected, WouldBlock };

fn Fmt(comptime T: type) type {
    return struct {
        t: T,
        const Self = @This();
        pub fn format(self: Self, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            const info = @typeInfo(T);
            switch (info) {
                .Struct => if (comptime decoding.isArrayList(T)) {
                    for (self.t.items) |it, i| {
                        if (i != 0) _ = try writer.write(", ");
                        try writer.print("{}", .{fmt(it)});
                    }
                } else inline for (std.meta.fields(T)) |f, i| {
                    if (i != 0) _ = try writer.write(", ");
                    var cw = std.io.countingWriter(std.io.null_writer);
                    const cwriter = cw.writer();
                    try cwriter.print("{}", .{fmt(@field(self.t, f.name))});
                    if (cw.bytes_written != 0)
                        try writer.print("{s}:{}", .{ f.name, fmt(@field(self.t, f.name)) });
                },
                .Pointer => if (comptime std.meta.trait.isZigString(T)) {
                    if (self.t.len > 0)
                        try writer.print("\"{s}\"", .{self.t});
                } else switch (info.Pointer.size) {
                    .One => try writer.print("{}", .{fmt(self.t.*)}),
                    else => try writer.print("TODO Fmt display {s}.size.{s}", .{ @tagName(info), @tagName(info.Pointer.size) }),
                },
                .Int, .Bool => try writer.print("{}", .{self.t}),
                .Optional => if (self.t) |t| try writer.print("{}", .{fmt(t)}),
                .Enum => try writer.print(".{s}", .{@tagName(self.t)}),
                else => try writer.print("TODO Fmt display {s}", .{@tagName(info)}),
            }
        }
    };
}

fn fmt(it: anytype) Fmt(@TypeOf(it)) {
    return .{ .t = it };
}

fn compareprint(comptime fmtt: []const u8, args: anytype, errwriter: anytype, depth: usize) !void {
    try errwriter.writeByteNTimes(' ', depth * 2);
    try errwriter.print(fmtt, args);
}

fn compare(expected: anytype, actual: anytype, errwriter: anytype, depth: usize, field_name: []const u8, buf: []u8) CmpErr!void {
    // TODO compare and report differences
    const E = @TypeOf(expected);
    const einfo = @typeInfo(E);
    for ([_][]const u8{ "__fields_present", "source_code_info", "compiler_version" }) |ignore_field|
        if (std.mem.endsWith(u8, field_name, ignore_field)) return;
    switch (einfo) {
        .Struct => if (comptime decoding.isArrayList(E)) {
            if (expected.items.len != actual.items.len) {
                try compareprint("{s}: items.len differ expected {} got {}\n", .{ field_name, expected.items.len, actual.items.len }, errwriter, depth);
            }
            const maxlen = @max(expected.items.len, actual.items.len);
            var i: usize = 0;
            while (i < maxlen) : (i += 1) {
                if (i < expected.items.len and i < actual.items.len) {
                    const actit = actual.items[i];
                    const exit = expected.items[i];
                    compare(exit, actit, errwriter, depth + 1, field_name, buf) catch {
                        try compareprint("{s}: items[{}] differ\n", .{ field_name, i }, errwriter, depth);
                    };
                } else if (i < expected.items.len) {
                    const exit = expected.items[i];
                    try compareprint("{s}: items[{}] differ expected {} actual <missing>\n", .{ field_name, i, fmt(exit) }, errwriter, depth);
                } else if (i < actual.items.len) {
                    const actit = actual.items[i];
                    try compareprint("{s}: items[{}] differ expected <missing> actual {}\n", .{ field_name, i, fmt(actit) }, errwriter, depth);
                }
            }
        } else {
            inline for (std.meta.fields(E)) |f| {
                if (comptime std.mem.startsWith(u8, f.name, "__")) continue;
                const ex = @field(expected, f.name);
                const act = @field(actual, f.name);
                const fname = if (field_name.len == 0) f.name else try std.fmt.bufPrint(buf, "{s}.{s}", .{ field_name, f.name });
                try compare(ex, act, errwriter, depth + 1, fname, buf);
            }
        },
        .Optional => if (expected != null and actual != null)
            return compare(expected.?, actual.?, errwriter, depth, field_name, buf)
        else if (expected == null and actual == null) {} else {
            try compareprint("{s}: optionals differ expected {} actual {}\n", .{ field_name, fmt(expected), fmt(actual) }, errwriter, depth);
        },
        .Int, .Bool => if (expected != actual)
            try compareprint("{s}: {s}s differ expected {} actual {}\n", .{ field_name, @tagName(einfo), expected, actual }, errwriter, depth),
        .Enum => if (expected != actual)
            try compareprint("{s}: {s}s differ expected .{s} actual .{s}\n", .{ field_name, @tagName(einfo), @tagName(expected), @tagName(actual) }, errwriter, depth),
        .Pointer => if (comptime std.meta.trait.isZigString(E)) {
            if (!std.mem.eql(u8, expected, actual))
                try compareprint("{s}: strings differ expected '{s}' actual '{s}'\n", .{ field_name, expected, actual }, errwriter, depth);
        } else switch (einfo.Pointer.size) {
            .One => try compare(expected.*, actual.*, errwriter, depth, field_name, buf),
            else => try compareprint("{s}: TODO {s} {s}\n", .{ field_name, @tagName(einfo), @typeName(E) }, errwriter, depth),
        },
        else => {
            try compareprint("{s}: TODO {s} {s}\n", .{ field_name, @tagName(einfo), @typeName(E) }, errwriter, depth);
        },
    }
}
