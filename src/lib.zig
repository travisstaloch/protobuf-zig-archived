const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const Allocator = mem.Allocator;
const File = fs.File;
const tokenizer = @import("tokenizer.zig");
const parser = @import("parser.zig");
const types = @import("types.zig");
const plugin = types.plugin;
const CodeGeneratorRequest = plugin.CodeGeneratorRequest;
// const Result = types.Result(CodeGeneratorRequest);

pub fn writeErr(err_msg: types.ErrorMsg, writer: anytype) !void {

    // TODO restore the immediate parent scope for error handling

    // find the line and column of error
    var line: usize = 1;
    var col: usize = 1;
    var line_start: usize = 0;
    for (err_msg.file.source.?[0..err_msg.token.loc.start]) |c, i| {
        if (c == '\n') {
            line_start = i + 1;
            line += 1;
            col = 1;
        } else col += 1;
    }
    // find the end of the line
    var line_end = line_start;
    while (true) {
        const c = err_msg.file.source.?[line_end];
        if (c == 0 or c == '\n') break;
        line_end += 1;
    }

    try writer.print("{s}:{}:{}: error: \n{s}\n", .{
        err_msg.file.path,
        line,
        col,
        err_msg.file.source.?[line_start..line_end],
    });
    try writer.writeByteNTimes(' ', col - 1);
    _ = try writer.write("^\n");
    try writer.writeAll(err_msg.msg);
}

pub fn parseToPlugin(
    arena: Allocator,
    source: [*:0]const u8,
    protopath: [*:0]const u8,
    include_paths: []const [:0]const u8,
    writer: anytype,
    errwriter: anytype,
) !CodeGeneratorRequest {
    const proto_file = std.fs.cwd().openFile(std.mem.span(protopath), .{}) catch |e| switch (e) {
        error.FileNotFound => {
            std.debug.print("file '{s}' not found\n", .{protopath});
            return e;
        },
        else => return e,
    };
    defer proto_file.close();

    // var file = File.init(source, .{ .path = protopath });
    // _ = file;
    // _ = source;
    // _ = arena;
    _ = include_paths;
    _ = writer;
    // _ = errwriter;
    // std.debug.print("TODO tokenize, parse\n", .{});
    // var t: tokenizer.Tokenizer = .{ .source = source, .index = 0 };
    // _ = t;
    var pparser = parser.init(arena, protopath, source, errwriter);
    return pparser.parse();

    // return error.Todo;
    // try parser.tokenize(arena, source, &file);
    // var pparser = parser.init(arena, &file, include_paths, errwriter);
    // try pparser.deps_map.put(arena, std.mem.span(protopath), file);
    // switch (try pparser.parse()) {
    //     .ok => {},
    //     .err => return .err,
    // }

    // var ggenerator = generator.generator(arena, pparser.root_file, errwriter);
    // return try ggenerator.generate(writer);
}
