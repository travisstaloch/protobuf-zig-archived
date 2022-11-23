const std = @import("std");
const decoding = @import("decoding.zig");

fn ErrOf(comptime T: type, comptime decl_name: []const u8) type {
    if (!@hasDecl(T, decl_name)) @compileError("missing '" ++ decl_name ++ "' decl");
    const writeinfo = @typeInfo(@TypeOf(T.write));
    const rettyinfo = @typeInfo(writeinfo.Fn.return_type.?);
    return rettyinfo.ErrorUnion.error_set;
}

pub fn writeJson(value: anytype, writer: anytype) ErrOf(@TypeOf(writer), "write")!void {
    const T = comptime @TypeOf(value);
    const ti = comptime @typeInfo(T);
    switch (ti) {
        .Int => try writer.print("{}", .{value}),
        .Float => try writer.print("{d}", .{value}),
        .Enum => try writer.print("{}", .{@enumToInt(value)}),
        .Bool => try writer.print("{}", .{value}),
        .Struct => if (comptime decoding.isArrayList(T)) {
            try writeJson(value.items, writer);
        } else if (comptime decoding.isSegmentedList(T)) {
            var iter = value.constIterator(0);
            while (iter.next()) |it|
                try writeJson(it, writer);
        } else if (comptime decoding.isHashMap(T)) {
            var iter = value.iterator();
            _ = try writer.write("[");
            var i: usize = 0;
            while (iter.next()) |it| : (i += 1) {
                if (i != 0) _ = try writer.write(",");
                _ = try writer.write(
                    \\{"key":
                );
                try writeJson(it.key_ptr.*, writer);
                _ = try writer.write(
                    \\,"value":
                );
                try writeJson(it.value_ptr.*, writer);
                _ = try writer.write("}");
            }
            _ = try writer.write("]");
        } else {
            if (!@hasField(T, "__fields_present"))
                @compileError("type " ++ @typeName(T) ++ " is missing field '__fields_present'.");
            const fields = comptime std.meta.fields(T);
            _ = try writer.write("{");
            var i: usize = 0;
            inline for (fields) |f, fieldi| {
                if (!comptime std.mem.eql(u8, f.name, "__fields_present")) {
                    const finfo = @typeInfo(f.field_type);
                    const field_value = @field(value, f.name);
                    const field_idx = if (finfo == .Union) @enumToInt(field_value) else fieldi;
                    const is_present = value.__fields_present.isSet(field_idx);
                    if (is_present) {
                        if (i != 0) _ = try writer.write(",");
                        try writer.print(
                            \\"{s}":
                        , .{f.name});
                        try writeJson(field_value, writer);
                        i += 1;
                    }
                }
            }
            _ = try writer.write("}");
        },
        .Pointer => if (comptime std.meta.trait.isZigString(T)) {
            _ = try writer.write("\"");
            if (value.len > 0)
                _ = try writer.write(value);
            _ = try writer.write("\"");
        } else switch (ti.Pointer.size) {
            .Slice => {
                _ = try writer.write("[");
                for (value) |it, i| {
                    if (i != 0) _ = try writer.write(",");
                    try writeJson(it, writer);
                }
                _ = try writer.write("]");
            },
            .One => try writeJson(value.*, writer),
            else => @compileError("writeJson() type '" ++ @typeName(T) ++ "' not supported."),
        },
        .Union => |unionInfo| {
            if (unionInfo.tag_type) |_| {
                // try each of the union fields until we find one that matches
                _ = try writer.write("{");
                const Tag = std.meta.Tag(T);
                inline for (unionInfo.fields) |u_field| {
                    if (value == @field(Tag, u_field.name)) {
                        try writer.print(
                            \\"{s}":
                        , .{u_field.name});
                        try writeJson(@field(value, u_field.name), writer);
                        break;
                    }
                }
                _ = try writer.write("}");
            } else @compileError("writeJson() type '" ++ @typeName(T) ++ "' not supported. enum without tag.");
        },
        .Optional => if (value != null) try writeJson(value.?, writer),
        else => @compileError("writeJson() type '" ++ @typeName(T) ++ "' not supported."),
    }
}
