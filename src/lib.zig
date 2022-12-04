const std = @import("std");
const mem = std.mem;
const fs = std.fs;
const Allocator = mem.Allocator;
const File = fs.File;
const tokenizer = @import("tokenizer.zig");
const parser = @import("parser.zig");
const types = @import("types.zig");
const util = @import("util.zig");
const analysis = @import("analysis.zig");
const plugin = types.plugin;
const CodeGeneratorRequest = plugin.CodeGeneratorRequest;
const todo = util.todo;

pub fn writeErr(err_msg: types.ErrorMsg, writer: anytype) !void {
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

pub fn parseToCodeGenReq(
    arena: Allocator,
    source: [*:0]const u8,
    protopath: [*:0]const u8,
    include_paths: []const [:0]const u8,
    errwriter: anytype,
) !CodeGeneratorRequest {
    var pparser = parser.init(arena, protopath, source, include_paths, errwriter);
    const req = try pparser.parse();
    var a = analysis.init(arena, req, pparser.deps_map, errwriter);
    try a.resolveFieldTypes();
    return req;
}

// pub fn serializeCodeGenReq(
//     arena: Allocator,
//     // req: plugin.CodeGeneratorRequest,
//     prototype: [*:0]const u8,
//     pparser: anytype,
//     writer: anytype,
//     errwriter: anytype,
// ) !types.Result(void) {
//     std.log.debug("serializeCodeGenReq prototype {s}", .{prototype});
//     const ttypename: []const u8 = std.mem.span(prototype);
//     if (ttypename.len == 0) return error.InvalidTypename;
//     const typename = if (ttypename[0] == '.') ttypename else try std.fmt.allocPrint(arena, ".{s}", .{ttypename});

//     var a = analysis.init(arena, pparser.req, pparser.deps_map, errwriter);
//     try a.resolveFieldTypes();
//     const mdescty = try a.findTypenameAbsoluteDescriptor(typename);
//     const descty = mdescty orelse return error.InvalidTypename;
//     encoding.serializeMessage(
//         descty.descriptor,
//         writer,
//         errwriter,
//     ) catch return .err;

//     return .ok;
// }
