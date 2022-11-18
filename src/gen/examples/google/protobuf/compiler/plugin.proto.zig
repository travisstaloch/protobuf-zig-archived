const std = @import("std");
const Allocator = std.mem.Allocator;
const decoding = @import("decoding");
pub const Error = decoding.Error;
const google_protobuf_descriptor = @import("../descriptor.proto.zig");
const exclude_fields: []const []const u8 = &.{"__fields_present"};
pub const Version = struct {
  major: i32 = 0,// 1
  minor: i32 = 0,// 2
  patch: i32 = 0,// 3
  suffix: []const u8 = "",// 4
__fields_present: std.StaticBitSet(4)  = std.StaticBitSet(4).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3, 4 };
pub const Version_field_ranges = decoding.fieldRanges(Version, exclude_fields);
pub const Version_field_ranges_lut = decoding.rangeLookupTable(Version, exclude_fields);
const Version_field_names_map = VersionFieldNameMap.init(.{
.major = "major", .minor = "minor", .patch = "patch", .suffix = "suffix", });
pub const VersionFieldEnum = decoding.FieldEnum(Version, exclude_fields);
pub const VersionFieldNameMap = std.enums.EnumMap(VersionFieldEnum, []const u8);
pub fn set(self: *Version, comptime field: VersionFieldEnum, value: anytype) void {
    const field_name = comptime Version_field_names_map.get(field) orelse unreachable;
    const names = comptime blk: {
        var result: []const []const u8 = &.{};
        var iter = std.mem.split(u8, field_name, ".");
        while (iter.next()) |n| result = result ++ [1][]const u8{n};
        break :blk result;
    };
    if (names.len == 1) {
        @field(self, names[0]) = value;
    } else {
        std.debug.assert(names.len == 2);
        var u = @field(self, names[0]);
        const U = @TypeOf(u);
        self.clear(field);
        @field(self, names[0]) = @unionInit(U, names[1], value);
    }
    self.setPresent(field);
}
pub fn setPresent(self: *Version, comptime field: VersionFieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: Version, comptime field: VersionFieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *Version, comptime field: VersionFieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = Version_field_ranges_lut[idx];
    const range = Version_field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *Version, allocator: Allocator, reader: anytype) Error!void {
const Context = @TypeOf(reader.context);
const context_info = @typeInfo(Context);
const ContextChild = switch(context_info) {
  .Pointer => context_info.Pointer.child,
  else => Context,
};
if (!@hasField(ContextChild, "bytes_left")) {
  var limreader = std.io.limitedReader(reader, std.math.maxInt(usize));
  return self.deserialize(allocator, limreader.reader());
}
while (true) {
  const key = decoding.readFieldKey(reader) catch |e| switch(e) {
    error.EndOfStream => break,
    else => {
      return e;
    },
  };
  //std.debug.print("key {}\n", .{key});
  if(key.wire_type == .start_group or key.wire_type == .end_group) return error.UnsupportedGroupStartOrEnd;
        switch (key.field_num) {
1 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.major = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.major);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.minor = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.minor);
},
3 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.patch = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.patch);
},
4 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.suffix = out.toOwnedSlice();
}
self.setPresent(.suffix);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: Version, writer: anytype) Error!void {
if(self.has(.major)) {
try decoding.writeFieldKey(1, .varint, writer);
try decoding.writeVarint128(i32, self.major, writer, .int);
}
if(self.has(.minor)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeVarint128(i32, self.minor, writer, .int);
}
if(self.has(.patch)) {
try decoding.writeFieldKey(3, .varint, writer);
try decoding.writeVarint128(i32, self.patch, writer, .int);
}
if(self.has(.suffix)) {
try decoding.writeFieldKey(4, .length_delimited, writer);
try decoding.writeString(self.suffix, writer);
}
}
};
pub const CodeGeneratorRequest = struct {
  file_to_generate: std.ArrayListUnmanaged([]const u8) = .{},// 1
  parameter: []const u8 = "",// 2
  proto_file: std.ArrayListUnmanaged(google_protobuf_descriptor.FileDescriptorProto) = .{},// 15
  compiler_version: ?*Version = null,// 3
__fields_present: std.StaticBitSet(4)  = std.StaticBitSet(4).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3, 15 };
pub const CodeGeneratorRequest_field_ranges = decoding.fieldRanges(CodeGeneratorRequest, exclude_fields);
pub const CodeGeneratorRequest_field_ranges_lut = decoding.rangeLookupTable(CodeGeneratorRequest, exclude_fields);
const CodeGeneratorRequest_field_names_map = CodeGeneratorRequestFieldNameMap.init(.{
.file_to_generate = "file_to_generate", .parameter = "parameter", .compiler_version = "compiler_version", .proto_file = "proto_file", });
pub const CodeGeneratorRequestFieldEnum = decoding.FieldEnum(CodeGeneratorRequest, exclude_fields);
pub const CodeGeneratorRequestFieldNameMap = std.enums.EnumMap(CodeGeneratorRequestFieldEnum, []const u8);
pub fn set(self: *CodeGeneratorRequest, comptime field: CodeGeneratorRequestFieldEnum, value: anytype) void {
    const field_name = comptime CodeGeneratorRequest_field_names_map.get(field) orelse unreachable;
    const names = comptime blk: {
        var result: []const []const u8 = &.{};
        var iter = std.mem.split(u8, field_name, ".");
        while (iter.next()) |n| result = result ++ [1][]const u8{n};
        break :blk result;
    };
    if (names.len == 1) {
        @field(self, names[0]) = value;
    } else {
        std.debug.assert(names.len == 2);
        var u = @field(self, names[0]);
        const U = @TypeOf(u);
        self.clear(field);
        @field(self, names[0]) = @unionInit(U, names[1], value);
    }
    self.setPresent(field);
}
pub fn setPresent(self: *CodeGeneratorRequest, comptime field: CodeGeneratorRequestFieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: CodeGeneratorRequest, comptime field: CodeGeneratorRequestFieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *CodeGeneratorRequest, comptime field: CodeGeneratorRequestFieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = CodeGeneratorRequest_field_ranges_lut[idx];
    const range = CodeGeneratorRequest_field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *CodeGeneratorRequest, allocator: Allocator, reader: anytype) Error!void {
const Context = @TypeOf(reader.context);
const context_info = @typeInfo(Context);
const ContextChild = switch(context_info) {
  .Pointer => context_info.Pointer.child,
  else => Context,
};
if (!@hasField(ContextChild, "bytes_left")) {
  var limreader = std.io.limitedReader(reader, std.math.maxInt(usize));
  return self.deserialize(allocator, limreader.reader());
}
while (true) {
  const key = decoding.readFieldKey(reader) catch |e| switch(e) {
    error.EndOfStream => break,
    else => {
      return e;
    },
  };
  //std.debug.print("key {}\n", .{key});
  if(key.wire_type == .start_group or key.wire_type == .end_group) return error.UnsupportedGroupStartOrEnd;
        switch (key.field_num) {
1 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
try self.file_to_generate.append(allocator, out.toOwnedSlice());
}
self.setPresent(.file_to_generate);
},
2 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.parameter = out.toOwnedSlice();
}
self.setPresent(.parameter);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//Version isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.compiler_version == null) {
    self.compiler_version = try allocator.create(Version);
    self.compiler_version.?.* = .{};
  }
  try self.compiler_version.?.deserialize(allocator, reader);
} else try self.compiler_version.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.compiler_version);
},
15 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//google_protobuf_descriptor.FileDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: google_protobuf_descriptor.FileDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(google_protobuf_descriptor.FileDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.proto_file.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.proto_file);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: CodeGeneratorRequest, writer: anytype) Error!void {
if(self.has(.file_to_generate)) {
for (self.file_to_generate.items) |it| {
  try decoding.writeFieldKey(1, .length_delimited, writer);
  try decoding.writeString(it, writer);
}}
if(self.has(.parameter)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
try decoding.writeString(self.parameter, writer);
}
if(self.has(.compiler_version)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.compiler_version.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.compiler_version.?.serialize(writer);
}
if(self.has(.proto_file)) {
for (self.proto_file.items) |it| {
  try decoding.writeFieldKey(15, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
};
pub const CodeGeneratorResponse = struct {
  error_: []const u8 = "",// 1
  supported_features: u64 = 0,// 2
  file: std.ArrayListUnmanaged(File) = .{},// 15
__fields_present: std.StaticBitSet(3)  = std.StaticBitSet(3).initEmpty(),
  pub const Feature = enum(u1) {
    FEATURE_NONE = 0,
    FEATURE_PROTO3_OPTIONAL = 1,
  };
  pub const File = struct {
    name: []const u8 = "",// 1
    insertion_point: []const u8 = "",// 2
    content: []const u8 = "",// 15
    generated_code_info: ?*google_protobuf_descriptor.GeneratedCodeInfo = null,// 16
__fields_present: std.StaticBitSet(4)  = std.StaticBitSet(4).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 15, 16 };
pub const File_field_ranges = decoding.fieldRanges(File, exclude_fields);
pub const File_field_ranges_lut = decoding.rangeLookupTable(File, exclude_fields);
const File_field_names_map = FileFieldNameMap.init(.{
.name = "name", .insertion_point = "insertion_point", .content = "content", .generated_code_info = "generated_code_info", });
pub const FileFieldEnum = decoding.FieldEnum(File, exclude_fields);
pub const FileFieldNameMap = std.enums.EnumMap(FileFieldEnum, []const u8);
pub fn set(self: *File, comptime field: FileFieldEnum, value: anytype) void {
    const field_name = comptime File_field_names_map.get(field) orelse unreachable;
    const names = comptime blk: {
        var result: []const []const u8 = &.{};
        var iter = std.mem.split(u8, field_name, ".");
        while (iter.next()) |n| result = result ++ [1][]const u8{n};
        break :blk result;
    };
    if (names.len == 1) {
        @field(self, names[0]) = value;
    } else {
        std.debug.assert(names.len == 2);
        var u = @field(self, names[0]);
        const U = @TypeOf(u);
        self.clear(field);
        @field(self, names[0]) = @unionInit(U, names[1], value);
    }
    self.setPresent(field);
}
pub fn setPresent(self: *File, comptime field: FileFieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: File, comptime field: FileFieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *File, comptime field: FileFieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = File_field_ranges_lut[idx];
    const range = File_field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *File, allocator: Allocator, reader: anytype) Error!void {
const Context = @TypeOf(reader.context);
const context_info = @typeInfo(Context);
const ContextChild = switch(context_info) {
  .Pointer => context_info.Pointer.child,
  else => Context,
};
if (!@hasField(ContextChild, "bytes_left")) {
  var limreader = std.io.limitedReader(reader, std.math.maxInt(usize));
  return self.deserialize(allocator, limreader.reader());
}
while (true) {
  const key = decoding.readFieldKey(reader) catch |e| switch(e) {
    error.EndOfStream => break,
    else => {
      return e;
    },
  };
  //std.debug.print("key {}\n", .{key});
  if(key.wire_type == .start_group or key.wire_type == .end_group) return error.UnsupportedGroupStartOrEnd;
        switch (key.field_num) {
1 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.name = out.toOwnedSlice();
}
self.setPresent(.name);
},
2 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.insertion_point = out.toOwnedSlice();
}
self.setPresent(.insertion_point);
},
15 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.content = out.toOwnedSlice();
}
self.setPresent(.content);
},
16 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//google_protobuf_descriptor.GeneratedCodeInfo isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.generated_code_info == null) {
    self.generated_code_info = try allocator.create(google_protobuf_descriptor.GeneratedCodeInfo);
    self.generated_code_info.?.* = .{};
  }
  try self.generated_code_info.?.deserialize(allocator, reader);
} else try self.generated_code_info.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.generated_code_info);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: File, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.insertion_point)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
try decoding.writeString(self.insertion_point, writer);
}
if(self.has(.content)) {
try decoding.writeFieldKey(15, .length_delimited, writer);
try decoding.writeString(self.content, writer);
}
if(self.has(.generated_code_info)) {
try decoding.writeFieldKey(16, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.generated_code_info.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.generated_code_info.?.serialize(writer);
}
}
  };
pub const __field_nums = [_]usize{ 1, 2, 15 };
pub const CodeGeneratorResponse_field_ranges = decoding.fieldRanges(CodeGeneratorResponse, exclude_fields);
pub const CodeGeneratorResponse_field_ranges_lut = decoding.rangeLookupTable(CodeGeneratorResponse, exclude_fields);
const CodeGeneratorResponse_field_names_map = CodeGeneratorResponseFieldNameMap.init(.{
.error_ = "error_", .supported_features = "supported_features", .file = "file", });
pub const CodeGeneratorResponseFieldEnum = decoding.FieldEnum(CodeGeneratorResponse, exclude_fields);
pub const CodeGeneratorResponseFieldNameMap = std.enums.EnumMap(CodeGeneratorResponseFieldEnum, []const u8);
pub fn set(self: *CodeGeneratorResponse, comptime field: CodeGeneratorResponseFieldEnum, value: anytype) void {
    const field_name = comptime CodeGeneratorResponse_field_names_map.get(field) orelse unreachable;
    const names = comptime blk: {
        var result: []const []const u8 = &.{};
        var iter = std.mem.split(u8, field_name, ".");
        while (iter.next()) |n| result = result ++ [1][]const u8{n};
        break :blk result;
    };
    if (names.len == 1) {
        @field(self, names[0]) = value;
    } else {
        std.debug.assert(names.len == 2);
        var u = @field(self, names[0]);
        const U = @TypeOf(u);
        self.clear(field);
        @field(self, names[0]) = @unionInit(U, names[1], value);
    }
    self.setPresent(field);
}
pub fn setPresent(self: *CodeGeneratorResponse, comptime field: CodeGeneratorResponseFieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: CodeGeneratorResponse, comptime field: CodeGeneratorResponseFieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *CodeGeneratorResponse, comptime field: CodeGeneratorResponseFieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = CodeGeneratorResponse_field_ranges_lut[idx];
    const range = CodeGeneratorResponse_field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *CodeGeneratorResponse, allocator: Allocator, reader: anytype) Error!void {
const Context = @TypeOf(reader.context);
const context_info = @typeInfo(Context);
const ContextChild = switch(context_info) {
  .Pointer => context_info.Pointer.child,
  else => Context,
};
if (!@hasField(ContextChild, "bytes_left")) {
  var limreader = std.io.limitedReader(reader, std.math.maxInt(usize));
  return self.deserialize(allocator, limreader.reader());
}
while (true) {
  const key = decoding.readFieldKey(reader) catch |e| switch(e) {
    error.EndOfStream => break,
    else => {
      return e;
    },
  };
  //std.debug.print("key {}\n", .{key});
  if(key.wire_type == .start_group or key.wire_type == .end_group) return error.UnsupportedGroupStartOrEnd;
        switch (key.field_num) {
1 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.error_ = out.toOwnedSlice();
}
self.setPresent(.error_);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.supported_features = @bitCast(u64, try decoding.readVarint128(u64, reader, .int));
self.setPresent(.supported_features);
},
15 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//File isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: File = undefined;
if(false) { // isrecursive
  it = try allocator.create(File);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.file.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.file);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: CodeGeneratorResponse, writer: anytype) Error!void {
if(self.has(.error_)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.error_, writer);
}
if(self.has(.supported_features)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeVarint128(u64, self.supported_features, writer, .int);
}
if(self.has(.file)) {
for (self.file.items) |it| {
  try decoding.writeFieldKey(15, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
};
test {
    _ = std.testing.refAllDecls(@This());
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allr = arena.allocator();
{
    var x: Version = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: CodeGeneratorRequest = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: CodeGeneratorResponse = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
}
