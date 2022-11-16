const std = @import("std");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub const LocalError = error{
    InvalidKey,
    InvalidKeyWireType,
    NotEnoughBytesRead,
    TooManyBytesRead,
    NotEnoughBytesWritten,
    Overflow,
    DecodingError,
    EncodingError,
    MissingField,
    UnsupportedGroupStartOrEnd,
};
pub const Error = std.mem.Allocator.Error ||
    std.fs.File.WriteFileError ||
    LocalError;

pub const WireType = enum(u3) {
    varint = 0,
    fixed64 = 1,
    length_delimited = 2,
    start_group = 3,
    end_group = 4,
    fixed32 = 5,
};

pub const BinaryType = enum {
    int32,
    int64,
    uint32,
    uint64,
    sint32,
    sint64,
    bool,
    @"enum",
    fixed64,
    sfixed64,
    double,
    string,
    bytes,
    embedded_message,
    packed_repeated_fields,
    fixed32,
    sfixed32,
    float,

    pub fn isScalarNumeric(bin_type: BinaryType) bool {
        return switch (bin_type) {
            .int32,
            .int64,
            .uint32,
            .uint64,
            .sint32,
            .sint64,
            .bool,
            .@"enum",
            .fixed64,
            .sfixed64,
            .fixed32,
            .sfixed32,
            .float,
            .double,
            => true,
            else => false,
        };
    }
    pub fn toString(bin_type: BinaryType) []const u8 {
        return switch (bin_type) {
            .@"enum" =>
            \\@"enum"
            ,
            else => @tagName(bin_type),
        };
    }
};

pub const FieldLabel = enum {
    optional,
    repeated,
    required,
    none,
};

pub fn wireType(binary_type: BinaryType) WireType {
    return switch (binary_type) {
        .int32, .int64, .uint32, .uint64, .sint32, .sint64, .bool, .@"enum" => .varint,
        .fixed64, .sfixed64, .double => .fixed64,
        .string, .bytes, .packed_repeated_fields, .embedded_message => .length_delimited,
        .fixed32, .sfixed32, .float => .fixed32,
    };
}

pub fn intMode(binary_type: BinaryType) IntMode {
    return switch (binary_type) {
        .sint32, .sint64, .sfixed64, .sfixed32 => .sint,
        else => .int,
    };
}

const IntMode = enum { sint, int };

// Reads a varint from the reader and returns the value, eos (end of steam) pair.
// `mode = .sint` should used for sint32 and sint64 decoding when expecting lots of negative numbers as it
// uses zig zag encoding to reduce the size of negative values. negatives encoded otherwise (with `mode = .int`)
// will require extra size (10 bytes each) and are inefficient.
pub fn readVarint128(comptime T: type, reader: anytype, mode: IntMode) !T {
    const U = std.meta.Int(.unsigned, @bitSizeOf(T));
    var value = @bitCast(T, try std.leb.readULEB128(U, reader));

    if (mode == .sint) {
        const S = std.meta.Int(.signed, @bitSizeOf(T));
        const svalue = @bitCast(S, value);
        value = @bitCast(T, (svalue >> 1) ^ (-(svalue & 1)));
    }
    return value;
}

pub fn readEnum(comptime E: type, reader: anytype) !E {
    const value = try readVarint128(i64, reader, .int);
    return @intToEnum(E, if (@hasDecl(E, "is_aliased") and E.is_aliased)
        // TODO this doesn't seem entirely correct as the value can represent multiple tags.
        //      not enirely sure what to do here.
        E.values[@bitCast(u64, value)]
    else
        value);
}

pub fn readBool(reader: anytype) !bool {
    const byte = try readVarint128(u8, reader, .int);
    return byte != 0;
}

pub const Key = struct {
    wire_type: WireType,
    field_num: usize,
    pub inline fn encode(key: Key) usize {
        return (key.field_num << 3) | @enumToInt(key.wire_type);
    }
    pub fn init(wire_type: WireType, field_num: usize) Key {
        return .{
            .wire_type = wire_type,
            .field_num = field_num,
        };
    }
};
pub fn readFieldKey(reader: anytype) !Key {
    const key = try readVarint128(usize, reader, .int);

    return Key{
        .wire_type = std.meta.intToEnum(WireType, key & 0b111) catch {
            std.debug.print("error: readFieldKey() invalid wire_type {}. key {}:0x{x}:0b{b:0>8} field_num {}\n", .{ @truncate(u3, key), key, key, key, key >> 3 });
            return error.InvalidKey;
        },
        .field_num = key >> 3,
    };
}

pub fn readString(reader: anytype, writer: anytype) !void {
    const len = try readVarint128(u32, reader, .int);
    var buf: [std.mem.page_size]u8 = undefined;
    var readlen: usize = 0;
    var limreader = std.io.limitedReader(reader, len);
    const lreader = limreader.reader();
    while (true) {
        const amt = try lreader.read(&buf);
        if (amt == 0) break;
        readlen += amt;
        const write_amt = try writer.write(buf[0..amt]);
        if (amt != write_amt) return error.NotEnoughBytesWritten;
    }
    if (readlen != len) return error.NotEnoughBytesRead;
}

pub fn readInt64(comptime T: type, reader: anytype) !T {
    return @bitCast(T, try reader.readIntLittle(u64));
}
pub fn readInt32(comptime T: type, reader: anytype) !T {
    return @bitCast(T, try reader.readIntLittle(u32));
}

//----------
//----------
//----------

fn testDecode(bytes: []const u8, expected: anytype, comptime mode: IntMode) !void {
    var fbs = std.io.fixedBufferStream(bytes);
    const T = @TypeOf(expected);
    const res = try readVarint128(T, fbs.reader(), mode);
    try std.testing.expectEqual(expected, res);
}

test "readVarint128" {
    // const n = @as(u32, 0b10011000011101100101); // 123456
    try testDecode(&[_]u8{ 0xE5, 0x8E, 0x26 }, @as(u32, 624485), .int);
    try testDecode(&[_]u8{0x2a}, @as(u32, 42), .int);
    try testDecode(&[_]u8{ 0xa9, 0x46 }, @as(u32, 9001), .int);
}

const allr = std.testing.allocator;

test "readString" {
    const bytes = [_]u8{ 0x12, 0x07, 0x74, 0x65, 0x73, 0x74, 0x69, 0x6e, 0x67 };
    var fbs = std.io.fixedBufferStream(&bytes);
    const reader = fbs.reader();
    const k = try readFieldKey(reader);
    try std.testing.expectEqual(@as(usize, 2), k.field_num);
    try std.testing.expectEqual(WireType.length_delimited, k.wire_type);
    var out = std.ArrayList(u8).init(allr);
    defer out.deinit();
    try readString(reader, out.writer());
    try std.testing.expectEqualStrings("testing", out.items);
}

pub fn writeVarint128(comptime T: type, _value: T, writer: anytype, comptime mode: IntMode) !void {
    var value = _value;

    if (mode == .sint) {
        value = (value >> (@bitSizeOf(T) - 1)) ^ (value << 1);
    }
    const U = std.meta.Int(.unsigned, @bitSizeOf(T));
    try std.leb.writeULEB128(writer, @bitCast(U, value));
}
pub fn writeEnum(comptime E: type, value: E, writer: anytype) !void {
    if (@hasDecl(E, "is_aliased") and E.is_aliased) {
        try writeVarint128(i64, E.values[@enumToInt(value)], writer, .int);
    } else try writeVarint128(i64, @enumToInt(value), writer, .int);
}
pub fn writeBool(value: bool, writer: anytype) !void {
    try writeVarint128(u1, @boolToInt(value), writer, .int);
}
pub fn writeString(value: []const u8, writer: anytype) !void {
    try writeVarint128(usize, value.len, writer, .int);
    _ = try writer.write(value);
}
pub fn writeInt32(value: u32, writer: anytype) !void {
    try writer.writeIntLittle(u32, value);
}
pub fn writeInt64(value: u64, writer: anytype) !void {
    try writer.writeIntLittle(u64, value);
}

pub fn writeFieldKey(field_num: usize, wire_type: WireType, writer: anytype) !void {
    const key = Key{ .field_num = field_num, .wire_type = wire_type };
    try writeVarint128(usize, key.encode(), writer, .int);
}

pub fn isArrayList(comptime T: type) bool {
    return @typeInfo(T) == .Struct and
        @hasField(T, "items") and
        @hasField(T, "capacity") and
        comptime std.mem.indexOf(u8, @typeName(T), "ArrayList") != null;
}

pub fn isHashMap(comptime T: type) bool {
    return @typeInfo(T) == .Struct and
        @hasDecl(T, "get") and
        @hasDecl(T, "put") and
        @hasDecl(T, "getOrPut") and
        comptime std.mem.indexOf(u8, @typeName(T), "HashMap") != null;
}

const LogLevel = std.log.Level;
pub const Label = enum { nolabel, optional, required, repeated };

fn failDecoding(comptime fmt: []const u8, args: anytype) Error {
    std.debug.print(fmt, args);
    return error.DecodingError;
}
fn failEncoding(comptime fmt: []const u8, args: anytype) Error {
    std.debug.print(fmt, args);
    return error.EncodingError;
}

pub const WireBinary = struct {
    wire: WireType,
    bin: BinaryType,
};

pub const SerdeInfo = struct {
    field_name: []const u8,
    field_type_name: []const u8, // zig type name
    field_num: usize,
    field_idx: usize,
    wire_bin: WireBinary,
    int_mode: IntMode,
    label: Label,
    is_packed: bool,
    log_level: LogLevel,
    child_wire_bin_kv: [2]?WireBinary = .{ null, null },

    pub fn init(
        field_name: []const u8,
        field_type_name: []const u8,
        field_num: usize,
        field_idx: usize,
        wire_bin: WireBinary,
        int_mode: IntMode,
        label: Label,
        is_packed: bool,
        log_level: LogLevel,
        child_wire_bin_kv: [2]?WireBinary,
    ) @This() {
        return .{
            .field_name = field_name,
            .field_type_name = field_type_name,
            .field_num = field_num,
            .field_idx = field_idx,
            .wire_bin = wire_bin,
            .int_mode = int_mode,
            .label = label,
            .is_packed = is_packed,
            .log_level = log_level,
            .child_wire_bin_kv = child_wire_bin_kv,
        };
    }

    pub fn copyTo(self: @This()) SerdeInfo {
        return SerdeInfo{
            .field_name = self.field_name,
            .field_num = self.field_num,
            .field_idx = self.field_idx,
            .wire_bin = self.wire_bin,
            .int_mode = self.int_mode,
            .label = self.label,
            .is_packed = self.is_packed,
            .log_level = self.log_level,
            .child_wire_bin_kv = self.child_wire_bin_kv,
        };
    }
};

pub fn serialize(
    comptime T: type,
    info: SerdeInfo,
    field: T,
    writer: anytype,
) !void {
    const field_name = info.field_name;
    const field_num = info.field_num;
    const wire_bin = info.wire_bin;
    const label = info.label;
    const is_packed = info.is_packed;
    const log_level = info.log_level;
    const wire_type = wire_bin.wire;
    const binary_type = wire_bin.bin;

    if (log_level == .debug) {
        const packedmsg = if (is_packed) "packed" else "notpacked";
        std.debug.print("serialize {} {s}: {s} - {s}/{s} .{s} {s}\n", .{ field_num, field_name, @typeName(T), @tagName(wire_type), @tagName(binary_type), @tagName(label), packedmsg });
    }
    _ = field;
    _ = writer;
    return failEncoding("TODO {s} {s} {s}\n", .{ @tagName(wire_type), @tagName(binary_type), @typeName(T) });
}

fn isStringIn(str: []const u8, strs: []const []const u8) bool {
    for (strs) |s| {
        if (std.mem.eql(u8, str, s)) return true;
    }
    return false;
}

/// copy of std.meta.FieldEnum which also includes the field names of any
/// union fields in T.  This is non-recursive and only for immediate children.
///   given struct{a: u8, b: union{c, d}}
///   returns enum{a, c, d};
pub fn FieldEnum(comptime T: type, comptime exclude_fields: []const []const u8) type {
    const EnumField = std.builtin.Type.EnumField;
    var fields: []const EnumField = &.{};
    inline for (std.meta.fields(T)) |field| {
        const fieldinfo = @typeInfo(field.field_type);
        if (isStringIn(field.name, exclude_fields)) continue;
        switch (fieldinfo) {
            .Union => inline for (fieldinfo.Union.fields) |ufield| {
                fields = fields ++ [1]EnumField{.{
                    .name = field.name ++ "_" ++ ufield.name,
                    .value = fields.len,
                }};
            },
            else => fields = fields ++ [1]EnumField{.{
                .name = field.name,
                .value = fields.len,
            }},
        }
    }
    return @Type(.{ .Enum = .{
        .layout = .Auto,
        .tag_type = std.math.IntFittingRange(0, fields.len -| 1),
        .fields = fields,
        .decls = &.{},
        .is_exhaustive = true,
    } });
}

pub fn fieldsLen(comptime T: type, comptime exclude_fields: []const []const u8, comptime include_union_fields: enum { include, exclude }) u16 {
    var len: u16 = 0;
    inline for (std.meta.fields(T)) |field| {
        const fieldinfo = @typeInfo(field.field_type);
        if (isStringIn(field.name, exclude_fields)) continue;
        switch (fieldinfo) {
            .Union => len += if (include_union_fields == .include)
                fieldinfo.Union.fields.len
            else
                1,
            else => len += 1,
        }
    }
    return len;
}

pub fn RangeSet(comptime T: type, comptime exclude_fields: []const []const u8) type {
    const len = fieldsLen(T, exclude_fields, .exclude);
    return [len]std.bit_set.Range;
}

pub fn fieldRanges(comptime T: type, comptime exclude_fields: []const []const u8) RangeSet(T, exclude_fields) {
    const R = RangeSet(T, exclude_fields);
    var result: R = undefined;
    var field_idx: usize = 0;
    var range_idx: usize = 0;
    inline for (std.meta.fields(T)) |field| {
        const fieldinfo = @typeInfo(field.field_type);
        if (comptime isStringIn(field.name, exclude_fields)) continue;
        switch (fieldinfo) {
            .Union => {
                result[range_idx] = .{ .start = field_idx, .end = field_idx + fieldinfo.Union.fields.len };
                field_idx += fieldinfo.Union.fields.len;
                range_idx += 1;
            },
            else => {
                result[range_idx] = .{ .start = field_idx, .end = field_idx + 1 };
                field_idx += 1;
                range_idx += 1;
            },
        }
    }
    return result;
}

pub fn rangeLookupTable(
    comptime T: type,
    comptime exclude_fields: []const []const u8,
) [fieldsLen(T, exclude_fields, .include)]u16 {
    comptime {
        const Fe = FieldEnum(T, exclude_fields);
        const fenames = std.meta.fieldNames(Fe);
        @setEvalBranchQuota(fenames.len * 12);

        var lut: [fenames.len]u16 = undefined;
        var luti: u16 = 0;
        var tnames: []const []const u8 = std.meta.fieldNames(T);
        for (lut) |_, i| {
            lut[i] = luti;
            const nextfename: []const u8 = if (i + 1 < lut.len) fenames[i + 1] else break;
            const advance = @boolToInt(!std.mem.startsWith(u8, nextfename, tnames[0] ++ "_"));
            tnames = tnames[advance..];
            luti += advance;
        }
        return lut;
    }
}

test "FieldEnum" {
    const S = struct {
        f0: u8 = 0,
        f1: union(enum) { uf0, uf1 } = undefined,
        f4: u8,
        f5: union(enum) { uf0, uf1 } = undefined,
        f8: u8,
    };
    const Fe = FieldEnum(S, &.{});
    const fes = comptime blk: {
        const fields = std.meta.fields(Fe);
        var res: [fields.len]Fe = undefined;
        inline for (fields) |field, i| res[i] = @intToEnum(Fe, field.value);
        break :blk res;
    };
    const fe_names = comptime blk: {
        var res: []const []const u8 = &.{};
        for (fes) |fe| res = res ++ [1][]const u8{@tagName(fe)};
        break :blk res;
    };
    inline for (fe_names) |fname, i| {
        const fe = comptime std.meta.stringToEnum(Fe, fname) orelse unreachable;
        try std.testing.expectEqual(fes[i], fe);
        const fi = @enumToInt(fe);
        try std.testing.expectEqual(i, fi);
    }

    const ranges = fieldRanges(S, &.{});
    const lut = rangeLookupTable(S, &.{});

    try std.testing.expectEqual(ranges[lut[0]], .{ .start = 0, .end = 1 });
    try std.testing.expectEqual(ranges[lut[1]], .{ .start = 1, .end = 3 });
    try std.testing.expectEqual(ranges[lut[2]], .{ .start = 1, .end = 3 });
    try std.testing.expectEqual(ranges[lut[3]], .{ .start = 3, .end = 4 });
    try std.testing.expectEqual(ranges[lut[4]], .{ .start = 4, .end = 6 });
    try std.testing.expectEqual(ranges[lut[5]], .{ .start = 4, .end = 6 });
    try std.testing.expectEqual(ranges[lut[6]], .{ .start = 6, .end = 7 });
}

pub fn debugFieldsPresent(__fields_present: anytype) void {
    if (comptime @hasField(@TypeOf(__fields_present), "masks")) {
        for (__fields_present.masks) |mask| {
            std.debug.print("{b:0>64}-", .{mask});
        }
        std.debug.print("\n", .{});
    } else {
        std.debug.print("{b:0>64}\n", .{__fields_present.mask});
    }
}
