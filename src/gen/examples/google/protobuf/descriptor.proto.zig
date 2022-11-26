const std = @import("std");
const Allocator = std.mem.Allocator;
const decoding = @import("decoding");
pub const Error = decoding.Error;
const exclude_fields: []const []const u8 = &.{"__fields_present"};
pub const FileDescriptorSet = struct {
  file: std.SegmentedList(FileDescriptorProto, 0) = .{},// 1
__fields_present: std.StaticBitSet(1)  = std.StaticBitSet(1).initEmpty(),
pub const __field_nums = [_]usize{ 1 };
pub const __field_ranges = decoding.fieldRanges(FileDescriptorSet, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(FileDescriptorSet, exclude_fields);
pub const __field_names_map = FileDescriptorSet.FieldNameMap.init(.{
.file = "file", });
pub const FieldEnum = decoding.FieldEnum(FileDescriptorSet, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(FileDescriptorSet.FieldEnum, []const u8);
pub fn set(self: *FileDescriptorSet, comptime field: FileDescriptorSet.FieldEnum, value: anytype) void {
    const field_name = comptime FileDescriptorSet.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *FileDescriptorSet, comptime field: FileDescriptorSet.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: FileDescriptorSet, comptime field: FileDescriptorSet.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *FileDescriptorSet, comptime field: FileDescriptorSet.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = FileDescriptorSet.__field_ranges_lut[idx];
    const range = FileDescriptorSet.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *FileDescriptorSet, allocator: Allocator, reader: anytype) Error!void {
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
//FileDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: FileDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(FileDescriptorProto);
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

pub fn serialize(self: FileDescriptorSet, writer: anytype) Error!void {
if(self.has(.file)) {
{
var iter = decoding.constListIterator(self.file);
while (iter.next()) |it| {
  try decoding.writeFieldKey(1, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const FileDescriptorProto = struct {
  name: []const u8 = "",// 1
  package: []const u8 = "",// 2
  dependency: std.ArrayListUnmanaged([]const u8) = .{},// 3
  public_dependency: std.ArrayListUnmanaged(i32) = .{},// 10
  weak_dependency: std.ArrayListUnmanaged(i32) = .{},// 11
  message_type: std.SegmentedList(DescriptorProto, 0) = .{},// 4
  enum_type: std.SegmentedList(EnumDescriptorProto, 0) = .{},// 5
  service: std.ArrayListUnmanaged(ServiceDescriptorProto) = .{},// 6
  extension: std.ArrayListUnmanaged(FieldDescriptorProto) = .{},// 7
  options: ?*FileOptions = null,// 8
  source_code_info: ?*SourceCodeInfo = null,// 9
  syntax: []const u8 = "",// 12
  edition: []const u8 = "",// 13
__fields_present: std.StaticBitSet(13)  = std.StaticBitSet(13).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 };
pub const __field_ranges = decoding.fieldRanges(FileDescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(FileDescriptorProto, exclude_fields);
pub const __field_names_map = FileDescriptorProto.FieldNameMap.init(.{
.name = "name", .package = "package", .dependency = "dependency", .message_type = "message_type", .enum_type = "enum_type", .service = "service", .extension = "extension", .options = "options", .source_code_info = "source_code_info", .public_dependency = "public_dependency", .weak_dependency = "weak_dependency", .syntax = "syntax", .edition = "edition", });
pub const FieldEnum = decoding.FieldEnum(FileDescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(FileDescriptorProto.FieldEnum, []const u8);
pub fn set(self: *FileDescriptorProto, comptime field: FileDescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime FileDescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *FileDescriptorProto, comptime field: FileDescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: FileDescriptorProto, comptime field: FileDescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *FileDescriptorProto, comptime field: FileDescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = FileDescriptorProto.__field_ranges_lut[idx];
    const range = FileDescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *FileDescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
self.package = out.toOwnedSlice();
}
self.setPresent(.package);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
try self.dependency.append(allocator, out.toOwnedSlice());
}
self.setPresent(.dependency);
},
4 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//DescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: DescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(DescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.message_type.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.message_type);
},
5 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//EnumDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: EnumDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(EnumDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.enum_type.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.enum_type);
},
6 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//ServiceDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: ServiceDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(ServiceDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.service.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.service);
},
7 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//FieldDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: FieldDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(FieldDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.extension.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.extension);
},
8 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//FileOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(FileOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
9 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//SourceCodeInfo isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.source_code_info == null) {
    self.source_code_info = try allocator.create(SourceCodeInfo);
    self.source_code_info.?.* = .{};
  }
  try self.source_code_info.?.deserialize(allocator, reader);
} else try self.source_code_info.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.source_code_info);
},
10 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
const len = try decoding.readVarint128(usize, reader, .int);
var countreader = std.io.countingReader(reader);
const creader = countreader.reader();
while (countreader.bytes_read < len) {
  try self.public_dependency.append(allocator, @bitCast(i32, try decoding.readVarint128(u32, creader, .int)));
}
}
self.setPresent(.public_dependency);
},
11 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
const len = try decoding.readVarint128(usize, reader, .int);
var countreader = std.io.countingReader(reader);
const creader = countreader.reader();
while (countreader.bytes_read < len) {
  try self.weak_dependency.append(allocator, @bitCast(i32, try decoding.readVarint128(u32, creader, .int)));
}
}
self.setPresent(.weak_dependency);
},
12 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.syntax = out.toOwnedSlice();
}
self.setPresent(.syntax);
},
13 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.edition = out.toOwnedSlice();
}
self.setPresent(.edition);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: FileDescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.package)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
try decoding.writeString(self.package, writer);
}
if(self.has(.dependency)) {
{
var iter = decoding.constListIterator(self.dependency);
while (iter.next()) |it| {
  try decoding.writeFieldKey(3, .length_delimited, writer);
  try decoding.writeString(it, writer);
}
}}
if(self.has(.message_type)) {
{
var iter = decoding.constListIterator(self.message_type);
while (iter.next()) |it| {
  try decoding.writeFieldKey(4, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.enum_type)) {
{
var iter = decoding.constListIterator(self.enum_type);
while (iter.next()) |it| {
  try decoding.writeFieldKey(5, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.service)) {
{
var iter = decoding.constListIterator(self.service);
while (iter.next()) |it| {
  try decoding.writeFieldKey(6, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.extension)) {
{
var iter = decoding.constListIterator(self.extension);
while (iter.next()) |it| {
  try decoding.writeFieldKey(7, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.options)) {
try decoding.writeFieldKey(8, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
if(self.has(.source_code_info)) {
try decoding.writeFieldKey(9, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.source_code_info.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.source_code_info.?.serialize(writer);
}
if(self.has(.public_dependency)) {
try decoding.writeFieldKey(10, .length_delimited, writer);
var countwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countwriter.writer();
{
var iter = decoding.constListIterator(self.public_dependency);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, cwriter, .int);
}
}
try decoding.writeVarint128(usize, countwriter.bytes_written, writer, .int);
{
var iter = decoding.constListIterator(self.public_dependency);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, writer, .int);
}
}
}
if(self.has(.weak_dependency)) {
try decoding.writeFieldKey(11, .length_delimited, writer);
var countwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countwriter.writer();
{
var iter = decoding.constListIterator(self.weak_dependency);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, cwriter, .int);
}
}
try decoding.writeVarint128(usize, countwriter.bytes_written, writer, .int);
{
var iter = decoding.constListIterator(self.weak_dependency);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, writer, .int);
}
}
}
if(self.has(.syntax)) {
try decoding.writeFieldKey(12, .length_delimited, writer);
try decoding.writeString(self.syntax, writer);
}
if(self.has(.edition)) {
try decoding.writeFieldKey(13, .length_delimited, writer);
try decoding.writeString(self.edition, writer);
}
}
};
pub const ExtensionRangeOptions = struct {
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(1)  = std.StaticBitSet(1).initEmpty(),
pub const __field_nums = [_]usize{ 999 };
pub const __field_ranges = decoding.fieldRanges(ExtensionRangeOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(ExtensionRangeOptions, exclude_fields);
pub const __field_names_map = ExtensionRangeOptions.FieldNameMap.init(.{
.uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(ExtensionRangeOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(ExtensionRangeOptions.FieldEnum, []const u8);
pub fn set(self: *ExtensionRangeOptions, comptime field: ExtensionRangeOptions.FieldEnum, value: anytype) void {
    const field_name = comptime ExtensionRangeOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *ExtensionRangeOptions, comptime field: ExtensionRangeOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: ExtensionRangeOptions, comptime field: ExtensionRangeOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *ExtensionRangeOptions, comptime field: ExtensionRangeOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = ExtensionRangeOptions.__field_ranges_lut[idx];
    const range = ExtensionRangeOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *ExtensionRangeOptions, allocator: Allocator, reader: anytype) Error!void {
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
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: ExtensionRangeOptions, writer: anytype) Error!void {
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const DescriptorProto = struct {
  name: []const u8 = "",// 1
  field: std.ArrayListUnmanaged(FieldDescriptorProto) = .{},// 2
  extension: std.ArrayListUnmanaged(FieldDescriptorProto) = .{},// 6
  nested_type: std.SegmentedList(DescriptorProto, 0) = .{},// 3
  enum_type: std.SegmentedList(EnumDescriptorProto, 0) = .{},// 4
  extension_range: std.ArrayListUnmanaged(ExtensionRange) = .{},// 5
  oneof_decl: std.ArrayListUnmanaged(OneofDescriptorProto) = .{},// 8
  options: ?*MessageOptions = null,// 7
  reserved_range: std.ArrayListUnmanaged(ReservedRange) = .{},// 9
  reserved_name: std.ArrayListUnmanaged([]const u8) = .{},// 10
__fields_present: std.StaticBitSet(10)  = std.StaticBitSet(10).initEmpty(),
  pub const ExtensionRange = struct {
    start: i32 = 0,// 1
    end: i32 = 0,// 2
    options: ?*ExtensionRangeOptions = null,// 3
__fields_present: std.StaticBitSet(3)  = std.StaticBitSet(3).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3 };
pub const __field_ranges = decoding.fieldRanges(ExtensionRange, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(ExtensionRange, exclude_fields);
pub const __field_names_map = ExtensionRange.FieldNameMap.init(.{
.start = "start", .end = "end", .options = "options", });
pub const FieldEnum = decoding.FieldEnum(ExtensionRange, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(ExtensionRange.FieldEnum, []const u8);
pub fn set(self: *ExtensionRange, comptime field: ExtensionRange.FieldEnum, value: anytype) void {
    const field_name = comptime ExtensionRange.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *ExtensionRange, comptime field: ExtensionRange.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: ExtensionRange, comptime field: ExtensionRange.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *ExtensionRange, comptime field: ExtensionRange.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = ExtensionRange.__field_ranges_lut[idx];
    const range = ExtensionRange.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *ExtensionRange, allocator: Allocator, reader: anytype) Error!void {
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
self.start = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.start);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.end = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.end);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//ExtensionRangeOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(ExtensionRangeOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: ExtensionRange, writer: anytype) Error!void {
if(self.has(.start)) {
try decoding.writeFieldKey(1, .varint, writer);
try decoding.writeVarint128(i32, self.start, writer, .int);
}
if(self.has(.end)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeVarint128(i32, self.end, writer, .int);
}
if(self.has(.options)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
}
  };
  pub const ReservedRange = struct {
    start: i32 = 0,// 1
    end: i32 = 0,// 2
__fields_present: std.StaticBitSet(2)  = std.StaticBitSet(2).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2 };
pub const __field_ranges = decoding.fieldRanges(ReservedRange, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(ReservedRange, exclude_fields);
pub const __field_names_map = ReservedRange.FieldNameMap.init(.{
.start = "start", .end = "end", });
pub const FieldEnum = decoding.FieldEnum(ReservedRange, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(ReservedRange.FieldEnum, []const u8);
pub fn set(self: *ReservedRange, comptime field: ReservedRange.FieldEnum, value: anytype) void {
    const field_name = comptime ReservedRange.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *ReservedRange, comptime field: ReservedRange.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: ReservedRange, comptime field: ReservedRange.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *ReservedRange, comptime field: ReservedRange.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = ReservedRange.__field_ranges_lut[idx];
    const range = ReservedRange.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *ReservedRange, allocator: Allocator, reader: anytype) Error!void {
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
self.start = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.start);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.end = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.end);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: ReservedRange, writer: anytype) Error!void {
if(self.has(.start)) {
try decoding.writeFieldKey(1, .varint, writer);
try decoding.writeVarint128(i32, self.start, writer, .int);
}
if(self.has(.end)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeVarint128(i32, self.end, writer, .int);
}
}
  };
pub const __field_nums = [_]usize{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
pub const __field_ranges = decoding.fieldRanges(DescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(DescriptorProto, exclude_fields);
pub const __field_names_map = DescriptorProto.FieldNameMap.init(.{
.name = "name", .field = "field", .nested_type = "nested_type", .enum_type = "enum_type", .extension_range = "extension_range", .extension = "extension", .options = "options", .oneof_decl = "oneof_decl", .reserved_range = "reserved_range", .reserved_name = "reserved_name", });
pub const FieldEnum = decoding.FieldEnum(DescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(DescriptorProto.FieldEnum, []const u8);
pub fn set(self: *DescriptorProto, comptime field: DescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime DescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *DescriptorProto, comptime field: DescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: DescriptorProto, comptime field: DescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *DescriptorProto, comptime field: DescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = DescriptorProto.__field_ranges_lut[idx];
    const range = DescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *DescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
//FieldDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: FieldDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(FieldDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.field.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.field);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//DescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: DescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(DescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.nested_type.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.nested_type);
},
4 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//EnumDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: EnumDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(EnumDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.enum_type.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.enum_type);
},
5 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//ExtensionRange isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: ExtensionRange = undefined;
if(false) { // isrecursive
  it = try allocator.create(ExtensionRange);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.extension_range.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.extension_range);
},
6 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//FieldDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: FieldDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(FieldDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.extension.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.extension);
},
7 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//MessageOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(MessageOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
8 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//OneofDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: OneofDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(OneofDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.oneof_decl.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.oneof_decl);
},
9 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//ReservedRange isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: ReservedRange = undefined;
if(false) { // isrecursive
  it = try allocator.create(ReservedRange);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.reserved_range.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.reserved_range);
},
10 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
try self.reserved_name.append(allocator, out.toOwnedSlice());
}
self.setPresent(.reserved_name);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: DescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.field)) {
{
var iter = decoding.constListIterator(self.field);
while (iter.next()) |it| {
  try decoding.writeFieldKey(2, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.nested_type)) {
{
var iter = decoding.constListIterator(self.nested_type);
while (iter.next()) |it| {
  try decoding.writeFieldKey(3, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.enum_type)) {
{
var iter = decoding.constListIterator(self.enum_type);
while (iter.next()) |it| {
  try decoding.writeFieldKey(4, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.extension_range)) {
{
var iter = decoding.constListIterator(self.extension_range);
while (iter.next()) |it| {
  try decoding.writeFieldKey(5, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.extension)) {
{
var iter = decoding.constListIterator(self.extension);
while (iter.next()) |it| {
  try decoding.writeFieldKey(6, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.options)) {
try decoding.writeFieldKey(7, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
if(self.has(.oneof_decl)) {
{
var iter = decoding.constListIterator(self.oneof_decl);
while (iter.next()) |it| {
  try decoding.writeFieldKey(8, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.reserved_range)) {
{
var iter = decoding.constListIterator(self.reserved_range);
while (iter.next()) |it| {
  try decoding.writeFieldKey(9, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.reserved_name)) {
{
var iter = decoding.constListIterator(self.reserved_name);
while (iter.next()) |it| {
  try decoding.writeFieldKey(10, .length_delimited, writer);
  try decoding.writeString(it, writer);
}
}}
}
};
pub const FieldDescriptorProto = struct {
  name: []const u8 = "",// 1
  number: i32 = 0,// 3
  label: Label = .LABEL_ERROR,// 4
  type: Type = .TYPE_ERROR,// 5
  type_name: []const u8 = "",// 6
  extendee: []const u8 = "",// 2
  default_value: []const u8 = "",// 7
  oneof_index: i32 = 0,// 9
  json_name: []const u8 = "",// 10
  options: ?*FieldOptions = null,// 8
  proto3_optional: bool = false,// 17
__fields_present: std.StaticBitSet(11)  = std.StaticBitSet(11).initEmpty(),
  pub const Type = enum(u5) {
    TYPE_ERROR = 0,
    TYPE_DOUBLE = 1,
    TYPE_FLOAT = 2,
    TYPE_INT64 = 3,
    TYPE_UINT64 = 4,
    TYPE_INT32 = 5,
    TYPE_FIXED64 = 6,
    TYPE_FIXED32 = 7,
    TYPE_BOOL = 8,
    TYPE_STRING = 9,
    TYPE_GROUP = 10,
    TYPE_MESSAGE = 11,
    TYPE_BYTES = 12,
    TYPE_UINT32 = 13,
    TYPE_ENUM = 14,
    TYPE_SFIXED32 = 15,
    TYPE_SFIXED64 = 16,
    TYPE_SINT32 = 17,
    TYPE_SINT64 = 18,
  };
  pub const Label = enum(u2) {
    LABEL_ERROR = 0,
    LABEL_OPTIONAL = 1,
    LABEL_REQUIRED = 2,
    LABEL_REPEATED = 3,
  };
pub const __field_nums = [_]usize{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 17 };
pub const __field_ranges = decoding.fieldRanges(FieldDescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(FieldDescriptorProto, exclude_fields);
pub const __field_names_map = FieldDescriptorProto.FieldNameMap.init(.{
.name = "name", .extendee = "extendee", .number = "number", .label = "label", .type = "type", .type_name = "type_name", .default_value = "default_value", .options = "options", .oneof_index = "oneof_index", .json_name = "json_name", .proto3_optional = "proto3_optional", });
pub const FieldEnum = decoding.FieldEnum(FieldDescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(FieldDescriptorProto.FieldEnum, []const u8);
pub fn set(self: *FieldDescriptorProto, comptime field: FieldDescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime FieldDescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *FieldDescriptorProto, comptime field: FieldDescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: FieldDescriptorProto, comptime field: FieldDescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *FieldDescriptorProto, comptime field: FieldDescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = FieldDescriptorProto.__field_ranges_lut[idx];
    const range = FieldDescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *FieldDescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
self.extendee = out.toOwnedSlice();
}
self.setPresent(.extendee);
},
3 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.number = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.number);
},
4 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.label = try decoding.readEnum(Label, reader);
self.setPresent(.label);
},
5 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.type = try decoding.readEnum(Type, reader);
self.setPresent(.type);
},
6 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.type_name = out.toOwnedSlice();
}
self.setPresent(.type_name);
},
7 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.default_value = out.toOwnedSlice();
}
self.setPresent(.default_value);
},
8 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//FieldOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(FieldOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
9 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.oneof_index = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.oneof_index);
},
10 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.json_name = out.toOwnedSlice();
}
self.setPresent(.json_name);
},
17 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.proto3_optional = try decoding.readBool(reader);
self.setPresent(.proto3_optional);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: FieldDescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.extendee)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
try decoding.writeString(self.extendee, writer);
}
if(self.has(.number)) {
try decoding.writeFieldKey(3, .varint, writer);
try decoding.writeVarint128(i32, self.number, writer, .int);
}
if(self.has(.label)) {
try decoding.writeFieldKey(4, .varint, writer);
try decoding.writeEnum(Label, self.label, writer);
}
if(self.has(.type)) {
try decoding.writeFieldKey(5, .varint, writer);
try decoding.writeEnum(Type, self.type, writer);
}
if(self.has(.type_name)) {
try decoding.writeFieldKey(6, .length_delimited, writer);
try decoding.writeString(self.type_name, writer);
}
if(self.has(.default_value)) {
try decoding.writeFieldKey(7, .length_delimited, writer);
try decoding.writeString(self.default_value, writer);
}
if(self.has(.options)) {
try decoding.writeFieldKey(8, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
if(self.has(.oneof_index)) {
try decoding.writeFieldKey(9, .varint, writer);
try decoding.writeVarint128(i32, self.oneof_index, writer, .int);
}
if(self.has(.json_name)) {
try decoding.writeFieldKey(10, .length_delimited, writer);
try decoding.writeString(self.json_name, writer);
}
if(self.has(.proto3_optional)) {
try decoding.writeFieldKey(17, .varint, writer);
try decoding.writeBool(self.proto3_optional, writer);
}
}
};
pub const OneofDescriptorProto = struct {
  name: []const u8 = "",// 1
  options: ?*OneofOptions = null,// 2
__fields_present: std.StaticBitSet(2)  = std.StaticBitSet(2).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2 };
pub const __field_ranges = decoding.fieldRanges(OneofDescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(OneofDescriptorProto, exclude_fields);
pub const __field_names_map = OneofDescriptorProto.FieldNameMap.init(.{
.name = "name", .options = "options", });
pub const FieldEnum = decoding.FieldEnum(OneofDescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(OneofDescriptorProto.FieldEnum, []const u8);
pub fn set(self: *OneofDescriptorProto, comptime field: OneofDescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime OneofDescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *OneofDescriptorProto, comptime field: OneofDescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: OneofDescriptorProto, comptime field: OneofDescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *OneofDescriptorProto, comptime field: OneofDescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = OneofDescriptorProto.__field_ranges_lut[idx];
    const range = OneofDescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *OneofDescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
//OneofOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(OneofOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: OneofDescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.options)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
}
};
pub const EnumDescriptorProto = struct {
  name: []const u8 = "",// 1
  value: std.ArrayListUnmanaged(EnumValueDescriptorProto) = .{},// 2
  options: ?*EnumOptions = null,// 3
  reserved_range: std.ArrayListUnmanaged(EnumReservedRange) = .{},// 4
  reserved_name: std.ArrayListUnmanaged([]const u8) = .{},// 5
__fields_present: std.StaticBitSet(5)  = std.StaticBitSet(5).initEmpty(),
  pub const EnumReservedRange = struct {
    start: i32 = 0,// 1
    end: i32 = 0,// 2
__fields_present: std.StaticBitSet(2)  = std.StaticBitSet(2).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2 };
pub const __field_ranges = decoding.fieldRanges(EnumReservedRange, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(EnumReservedRange, exclude_fields);
pub const __field_names_map = EnumReservedRange.FieldNameMap.init(.{
.start = "start", .end = "end", });
pub const FieldEnum = decoding.FieldEnum(EnumReservedRange, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(EnumReservedRange.FieldEnum, []const u8);
pub fn set(self: *EnumReservedRange, comptime field: EnumReservedRange.FieldEnum, value: anytype) void {
    const field_name = comptime EnumReservedRange.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *EnumReservedRange, comptime field: EnumReservedRange.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: EnumReservedRange, comptime field: EnumReservedRange.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *EnumReservedRange, comptime field: EnumReservedRange.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = EnumReservedRange.__field_ranges_lut[idx];
    const range = EnumReservedRange.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *EnumReservedRange, allocator: Allocator, reader: anytype) Error!void {
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
self.start = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.start);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.end = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.end);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: EnumReservedRange, writer: anytype) Error!void {
if(self.has(.start)) {
try decoding.writeFieldKey(1, .varint, writer);
try decoding.writeVarint128(i32, self.start, writer, .int);
}
if(self.has(.end)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeVarint128(i32, self.end, writer, .int);
}
}
  };
pub const __field_nums = [_]usize{ 1, 2, 3, 4, 5 };
pub const __field_ranges = decoding.fieldRanges(EnumDescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(EnumDescriptorProto, exclude_fields);
pub const __field_names_map = EnumDescriptorProto.FieldNameMap.init(.{
.name = "name", .value = "value", .options = "options", .reserved_range = "reserved_range", .reserved_name = "reserved_name", });
pub const FieldEnum = decoding.FieldEnum(EnumDescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(EnumDescriptorProto.FieldEnum, []const u8);
pub fn set(self: *EnumDescriptorProto, comptime field: EnumDescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime EnumDescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *EnumDescriptorProto, comptime field: EnumDescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: EnumDescriptorProto, comptime field: EnumDescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *EnumDescriptorProto, comptime field: EnumDescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = EnumDescriptorProto.__field_ranges_lut[idx];
    const range = EnumDescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *EnumDescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
//EnumValueDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: EnumValueDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(EnumValueDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.value.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.value);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//EnumOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(EnumOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
4 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//EnumReservedRange isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: EnumReservedRange = undefined;
if(false) { // isrecursive
  it = try allocator.create(EnumReservedRange);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.reserved_range.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.reserved_range);
},
5 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
try self.reserved_name.append(allocator, out.toOwnedSlice());
}
self.setPresent(.reserved_name);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: EnumDescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.value)) {
{
var iter = decoding.constListIterator(self.value);
while (iter.next()) |it| {
  try decoding.writeFieldKey(2, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.options)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
if(self.has(.reserved_range)) {
{
var iter = decoding.constListIterator(self.reserved_range);
while (iter.next()) |it| {
  try decoding.writeFieldKey(4, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.reserved_name)) {
{
var iter = decoding.constListIterator(self.reserved_name);
while (iter.next()) |it| {
  try decoding.writeFieldKey(5, .length_delimited, writer);
  try decoding.writeString(it, writer);
}
}}
}
};
pub const EnumValueDescriptorProto = struct {
  name: []const u8 = "",// 1
  number: i32 = 0,// 2
  options: ?*EnumValueOptions = null,// 3
__fields_present: std.StaticBitSet(3)  = std.StaticBitSet(3).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3 };
pub const __field_ranges = decoding.fieldRanges(EnumValueDescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(EnumValueDescriptorProto, exclude_fields);
pub const __field_names_map = EnumValueDescriptorProto.FieldNameMap.init(.{
.name = "name", .number = "number", .options = "options", });
pub const FieldEnum = decoding.FieldEnum(EnumValueDescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(EnumValueDescriptorProto.FieldEnum, []const u8);
pub fn set(self: *EnumValueDescriptorProto, comptime field: EnumValueDescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime EnumValueDescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *EnumValueDescriptorProto, comptime field: EnumValueDescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: EnumValueDescriptorProto, comptime field: EnumValueDescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *EnumValueDescriptorProto, comptime field: EnumValueDescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = EnumValueDescriptorProto.__field_ranges_lut[idx];
    const range = EnumValueDescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *EnumValueDescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.number = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.number);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//EnumValueOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(EnumValueOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: EnumValueDescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.number)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeVarint128(i32, self.number, writer, .int);
}
if(self.has(.options)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
}
};
pub const ServiceDescriptorProto = struct {
  name: []const u8 = "",// 1
  method: std.ArrayListUnmanaged(MethodDescriptorProto) = .{},// 2
  options: ?*ServiceOptions = null,// 3
__fields_present: std.StaticBitSet(3)  = std.StaticBitSet(3).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3 };
pub const __field_ranges = decoding.fieldRanges(ServiceDescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(ServiceDescriptorProto, exclude_fields);
pub const __field_names_map = ServiceDescriptorProto.FieldNameMap.init(.{
.name = "name", .method = "method", .options = "options", });
pub const FieldEnum = decoding.FieldEnum(ServiceDescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(ServiceDescriptorProto.FieldEnum, []const u8);
pub fn set(self: *ServiceDescriptorProto, comptime field: ServiceDescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime ServiceDescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *ServiceDescriptorProto, comptime field: ServiceDescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: ServiceDescriptorProto, comptime field: ServiceDescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *ServiceDescriptorProto, comptime field: ServiceDescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = ServiceDescriptorProto.__field_ranges_lut[idx];
    const range = ServiceDescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *ServiceDescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
//MethodDescriptorProto isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: MethodDescriptorProto = undefined;
if(false) { // isrecursive
  it = try allocator.create(MethodDescriptorProto);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.method.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.method);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//ServiceOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(ServiceOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: ServiceDescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.method)) {
{
var iter = decoding.constListIterator(self.method);
while (iter.next()) |it| {
  try decoding.writeFieldKey(2, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.options)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
}
};
pub const MethodDescriptorProto = struct {
  name: []const u8 = "",// 1
  input_type: []const u8 = "",// 2
  output_type: []const u8 = "",// 3
  options: ?*MethodOptions = null,// 4
  client_streaming: bool = false,// 5
  server_streaming: bool = false,// 6
__fields_present: std.StaticBitSet(6)  = std.StaticBitSet(6).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3, 4, 5, 6 };
pub const __field_ranges = decoding.fieldRanges(MethodDescriptorProto, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(MethodDescriptorProto, exclude_fields);
pub const __field_names_map = MethodDescriptorProto.FieldNameMap.init(.{
.name = "name", .input_type = "input_type", .output_type = "output_type", .options = "options", .client_streaming = "client_streaming", .server_streaming = "server_streaming", });
pub const FieldEnum = decoding.FieldEnum(MethodDescriptorProto, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(MethodDescriptorProto.FieldEnum, []const u8);
pub fn set(self: *MethodDescriptorProto, comptime field: MethodDescriptorProto.FieldEnum, value: anytype) void {
    const field_name = comptime MethodDescriptorProto.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *MethodDescriptorProto, comptime field: MethodDescriptorProto.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: MethodDescriptorProto, comptime field: MethodDescriptorProto.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *MethodDescriptorProto, comptime field: MethodDescriptorProto.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = MethodDescriptorProto.__field_ranges_lut[idx];
    const range = MethodDescriptorProto.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *MethodDescriptorProto, allocator: Allocator, reader: anytype) Error!void {
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
self.input_type = out.toOwnedSlice();
}
self.setPresent(.input_type);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.output_type = out.toOwnedSlice();
}
self.setPresent(.output_type);
},
4 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//MethodOptions isrecursive true
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
if(true) { // isrecursive
  if (self.options == null) {
    self.options = try allocator.create(MethodOptions);
    self.options.?.* = .{};
  }
  try self.options.?.deserialize(allocator, reader);
} else try self.options.?.deserialize(allocator, reader);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.options);
},
5 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.client_streaming = try decoding.readBool(reader);
self.setPresent(.client_streaming);
},
6 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.server_streaming = try decoding.readBool(reader);
self.setPresent(.server_streaming);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: MethodDescriptorProto, writer: anytype) Error!void {
if(self.has(.name)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name, writer);
}
if(self.has(.input_type)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
try decoding.writeString(self.input_type, writer);
}
if(self.has(.output_type)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
try decoding.writeString(self.output_type, writer);
}
if(self.has(.options)) {
try decoding.writeFieldKey(4, .length_delimited, writer);
var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

try self.options.?.serialize(cwriter);
try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
try self.options.?.serialize(writer);
}
if(self.has(.client_streaming)) {
try decoding.writeFieldKey(5, .varint, writer);
try decoding.writeBool(self.client_streaming, writer);
}
if(self.has(.server_streaming)) {
try decoding.writeFieldKey(6, .varint, writer);
try decoding.writeBool(self.server_streaming, writer);
}
}
};
pub const FileOptions = struct {
  java_package: []const u8 = "",// 1
  java_outer_classname: []const u8 = "",// 8
  java_multiple_files: bool = false,// 10
  java_generate_equals_and_hash: bool = false,// 20
  java_string_check_utf8: bool = false,// 27
  optimize_for: OptimizeMode = .SPEED,// 9
  go_package: []const u8 = "",// 11
  cc_generic_services: bool = false,// 16
  java_generic_services: bool = false,// 17
  py_generic_services: bool = false,// 18
  php_generic_services: bool = false,// 42
  deprecated: bool = false,// 23
  cc_enable_arenas: bool = false,// 31
  objc_class_prefix: []const u8 = "",// 36
  csharp_namespace: []const u8 = "",// 37
  swift_prefix: []const u8 = "",// 39
  php_class_prefix: []const u8 = "",// 40
  php_namespace: []const u8 = "",// 41
  php_metadata_namespace: []const u8 = "",// 44
  ruby_package: []const u8 = "",// 45
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(21)  = std.StaticBitSet(21).initEmpty(),
  pub const OptimizeMode = enum(u2) {
    NONE = 0,
    SPEED = 1,
    CODE_SIZE = 2,
    LITE_RUNTIME = 3,
  };
pub const __field_nums = [_]usize{ 1, 8, 9, 10, 11, 16, 17, 18, 20, 23, 27, 31, 36, 37, 39, 40, 41, 42, 44, 45, 999 };
pub const __field_ranges = decoding.fieldRanges(FileOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(FileOptions, exclude_fields);
pub const __field_names_map = FileOptions.FieldNameMap.init(.{
.java_package = "java_package", .java_outer_classname = "java_outer_classname", .optimize_for = "optimize_for", .java_multiple_files = "java_multiple_files", .go_package = "go_package", .cc_generic_services = "cc_generic_services", .java_generic_services = "java_generic_services", .py_generic_services = "py_generic_services", .java_generate_equals_and_hash = "java_generate_equals_and_hash", .deprecated = "deprecated", .java_string_check_utf8 = "java_string_check_utf8", .cc_enable_arenas = "cc_enable_arenas", .objc_class_prefix = "objc_class_prefix", .csharp_namespace = "csharp_namespace", .swift_prefix = "swift_prefix", .php_class_prefix = "php_class_prefix", .php_namespace = "php_namespace", .php_generic_services = "php_generic_services", .php_metadata_namespace = "php_metadata_namespace", .ruby_package = "ruby_package", .uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(FileOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(FileOptions.FieldEnum, []const u8);
pub fn set(self: *FileOptions, comptime field: FileOptions.FieldEnum, value: anytype) void {
    const field_name = comptime FileOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *FileOptions, comptime field: FileOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: FileOptions, comptime field: FileOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *FileOptions, comptime field: FileOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = FileOptions.__field_ranges_lut[idx];
    const range = FileOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *FileOptions, allocator: Allocator, reader: anytype) Error!void {
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
self.java_package = out.toOwnedSlice();
}
self.setPresent(.java_package);
},
8 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.java_outer_classname = out.toOwnedSlice();
}
self.setPresent(.java_outer_classname);
},
9 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.optimize_for = try decoding.readEnum(OptimizeMode, reader);
self.setPresent(.optimize_for);
},
10 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.java_multiple_files = try decoding.readBool(reader);
self.setPresent(.java_multiple_files);
},
11 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.go_package = out.toOwnedSlice();
}
self.setPresent(.go_package);
},
16 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.cc_generic_services = try decoding.readBool(reader);
self.setPresent(.cc_generic_services);
},
17 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.java_generic_services = try decoding.readBool(reader);
self.setPresent(.java_generic_services);
},
18 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.py_generic_services = try decoding.readBool(reader);
self.setPresent(.py_generic_services);
},
20 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.java_generate_equals_and_hash = try decoding.readBool(reader);
self.setPresent(.java_generate_equals_and_hash);
},
23 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.deprecated = try decoding.readBool(reader);
self.setPresent(.deprecated);
},
27 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.java_string_check_utf8 = try decoding.readBool(reader);
self.setPresent(.java_string_check_utf8);
},
31 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.cc_enable_arenas = try decoding.readBool(reader);
self.setPresent(.cc_enable_arenas);
},
36 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.objc_class_prefix = out.toOwnedSlice();
}
self.setPresent(.objc_class_prefix);
},
37 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.csharp_namespace = out.toOwnedSlice();
}
self.setPresent(.csharp_namespace);
},
39 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.swift_prefix = out.toOwnedSlice();
}
self.setPresent(.swift_prefix);
},
40 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.php_class_prefix = out.toOwnedSlice();
}
self.setPresent(.php_class_prefix);
},
41 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.php_namespace = out.toOwnedSlice();
}
self.setPresent(.php_namespace);
},
42 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.php_generic_services = try decoding.readBool(reader);
self.setPresent(.php_generic_services);
},
44 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.php_metadata_namespace = out.toOwnedSlice();
}
self.setPresent(.php_metadata_namespace);
},
45 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.ruby_package = out.toOwnedSlice();
}
self.setPresent(.ruby_package);
},
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: FileOptions, writer: anytype) Error!void {
if(self.has(.java_package)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.java_package, writer);
}
if(self.has(.java_outer_classname)) {
try decoding.writeFieldKey(8, .length_delimited, writer);
try decoding.writeString(self.java_outer_classname, writer);
}
if(self.has(.optimize_for)) {
try decoding.writeFieldKey(9, .varint, writer);
try decoding.writeEnum(OptimizeMode, self.optimize_for, writer);
}
if(self.has(.java_multiple_files)) {
try decoding.writeFieldKey(10, .varint, writer);
try decoding.writeBool(self.java_multiple_files, writer);
}
if(self.has(.go_package)) {
try decoding.writeFieldKey(11, .length_delimited, writer);
try decoding.writeString(self.go_package, writer);
}
if(self.has(.cc_generic_services)) {
try decoding.writeFieldKey(16, .varint, writer);
try decoding.writeBool(self.cc_generic_services, writer);
}
if(self.has(.java_generic_services)) {
try decoding.writeFieldKey(17, .varint, writer);
try decoding.writeBool(self.java_generic_services, writer);
}
if(self.has(.py_generic_services)) {
try decoding.writeFieldKey(18, .varint, writer);
try decoding.writeBool(self.py_generic_services, writer);
}
if(self.has(.java_generate_equals_and_hash)) {
try decoding.writeFieldKey(20, .varint, writer);
try decoding.writeBool(self.java_generate_equals_and_hash, writer);
}
if(self.has(.deprecated)) {
try decoding.writeFieldKey(23, .varint, writer);
try decoding.writeBool(self.deprecated, writer);
}
if(self.has(.java_string_check_utf8)) {
try decoding.writeFieldKey(27, .varint, writer);
try decoding.writeBool(self.java_string_check_utf8, writer);
}
if(self.has(.cc_enable_arenas)) {
try decoding.writeFieldKey(31, .varint, writer);
try decoding.writeBool(self.cc_enable_arenas, writer);
}
if(self.has(.objc_class_prefix)) {
try decoding.writeFieldKey(36, .length_delimited, writer);
try decoding.writeString(self.objc_class_prefix, writer);
}
if(self.has(.csharp_namespace)) {
try decoding.writeFieldKey(37, .length_delimited, writer);
try decoding.writeString(self.csharp_namespace, writer);
}
if(self.has(.swift_prefix)) {
try decoding.writeFieldKey(39, .length_delimited, writer);
try decoding.writeString(self.swift_prefix, writer);
}
if(self.has(.php_class_prefix)) {
try decoding.writeFieldKey(40, .length_delimited, writer);
try decoding.writeString(self.php_class_prefix, writer);
}
if(self.has(.php_namespace)) {
try decoding.writeFieldKey(41, .length_delimited, writer);
try decoding.writeString(self.php_namespace, writer);
}
if(self.has(.php_generic_services)) {
try decoding.writeFieldKey(42, .varint, writer);
try decoding.writeBool(self.php_generic_services, writer);
}
if(self.has(.php_metadata_namespace)) {
try decoding.writeFieldKey(44, .length_delimited, writer);
try decoding.writeString(self.php_metadata_namespace, writer);
}
if(self.has(.ruby_package)) {
try decoding.writeFieldKey(45, .length_delimited, writer);
try decoding.writeString(self.ruby_package, writer);
}
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const MessageOptions = struct {
  message_set_wire_format: bool = false,// 1
  no_standard_descriptor_accessor: bool = false,// 2
  deprecated: bool = false,// 3
  map_entry: bool = false,// 7
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(5)  = std.StaticBitSet(5).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3, 7, 999 };
pub const __field_ranges = decoding.fieldRanges(MessageOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(MessageOptions, exclude_fields);
pub const __field_names_map = MessageOptions.FieldNameMap.init(.{
.message_set_wire_format = "message_set_wire_format", .no_standard_descriptor_accessor = "no_standard_descriptor_accessor", .deprecated = "deprecated", .map_entry = "map_entry", .uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(MessageOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(MessageOptions.FieldEnum, []const u8);
pub fn set(self: *MessageOptions, comptime field: MessageOptions.FieldEnum, value: anytype) void {
    const field_name = comptime MessageOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *MessageOptions, comptime field: MessageOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: MessageOptions, comptime field: MessageOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *MessageOptions, comptime field: MessageOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = MessageOptions.__field_ranges_lut[idx];
    const range = MessageOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *MessageOptions, allocator: Allocator, reader: anytype) Error!void {
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
self.message_set_wire_format = try decoding.readBool(reader);
self.setPresent(.message_set_wire_format);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.no_standard_descriptor_accessor = try decoding.readBool(reader);
self.setPresent(.no_standard_descriptor_accessor);
},
3 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.deprecated = try decoding.readBool(reader);
self.setPresent(.deprecated);
},
7 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.map_entry = try decoding.readBool(reader);
self.setPresent(.map_entry);
},
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: MessageOptions, writer: anytype) Error!void {
if(self.has(.message_set_wire_format)) {
try decoding.writeFieldKey(1, .varint, writer);
try decoding.writeBool(self.message_set_wire_format, writer);
}
if(self.has(.no_standard_descriptor_accessor)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeBool(self.no_standard_descriptor_accessor, writer);
}
if(self.has(.deprecated)) {
try decoding.writeFieldKey(3, .varint, writer);
try decoding.writeBool(self.deprecated, writer);
}
if(self.has(.map_entry)) {
try decoding.writeFieldKey(7, .varint, writer);
try decoding.writeBool(self.map_entry, writer);
}
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const FieldOptions = struct {
  ctype: CType = .STRING,// 1
  packed_: bool = false,// 2
  jstype: JSType = .JS_NORMAL,// 6
  lazy: bool = false,// 5
  unverified_lazy: bool = false,// 15
  deprecated: bool = false,// 3
  weak: bool = false,// 10
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(8)  = std.StaticBitSet(8).initEmpty(),
  pub const CType = enum(u2) {
    STRING = 0,
    CORD = 1,
    STRING_PIECE = 2,
  };
  pub const JSType = enum(u2) {
    JS_NORMAL = 0,
    JS_STRING = 1,
    JS_NUMBER = 2,
  };
pub const __field_nums = [_]usize{ 1, 2, 3, 5, 6, 10, 15, 999 };
pub const __field_ranges = decoding.fieldRanges(FieldOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(FieldOptions, exclude_fields);
pub const __field_names_map = FieldOptions.FieldNameMap.init(.{
.ctype = "ctype", .packed_ = "packed_", .deprecated = "deprecated", .lazy = "lazy", .jstype = "jstype", .weak = "weak", .unverified_lazy = "unverified_lazy", .uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(FieldOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(FieldOptions.FieldEnum, []const u8);
pub fn set(self: *FieldOptions, comptime field: FieldOptions.FieldEnum, value: anytype) void {
    const field_name = comptime FieldOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *FieldOptions, comptime field: FieldOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: FieldOptions, comptime field: FieldOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *FieldOptions, comptime field: FieldOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = FieldOptions.__field_ranges_lut[idx];
    const range = FieldOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *FieldOptions, allocator: Allocator, reader: anytype) Error!void {
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
self.ctype = try decoding.readEnum(CType, reader);
self.setPresent(.ctype);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.packed_ = try decoding.readBool(reader);
self.setPresent(.packed_);
},
3 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.deprecated = try decoding.readBool(reader);
self.setPresent(.deprecated);
},
5 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.lazy = try decoding.readBool(reader);
self.setPresent(.lazy);
},
6 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.jstype = try decoding.readEnum(JSType, reader);
self.setPresent(.jstype);
},
10 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.weak = try decoding.readBool(reader);
self.setPresent(.weak);
},
15 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.unverified_lazy = try decoding.readBool(reader);
self.setPresent(.unverified_lazy);
},
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: FieldOptions, writer: anytype) Error!void {
if(self.has(.ctype)) {
try decoding.writeFieldKey(1, .varint, writer);
try decoding.writeEnum(CType, self.ctype, writer);
}
if(self.has(.packed_)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeBool(self.packed_, writer);
}
if(self.has(.deprecated)) {
try decoding.writeFieldKey(3, .varint, writer);
try decoding.writeBool(self.deprecated, writer);
}
if(self.has(.lazy)) {
try decoding.writeFieldKey(5, .varint, writer);
try decoding.writeBool(self.lazy, writer);
}
if(self.has(.jstype)) {
try decoding.writeFieldKey(6, .varint, writer);
try decoding.writeEnum(JSType, self.jstype, writer);
}
if(self.has(.weak)) {
try decoding.writeFieldKey(10, .varint, writer);
try decoding.writeBool(self.weak, writer);
}
if(self.has(.unverified_lazy)) {
try decoding.writeFieldKey(15, .varint, writer);
try decoding.writeBool(self.unverified_lazy, writer);
}
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const OneofOptions = struct {
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(1)  = std.StaticBitSet(1).initEmpty(),
pub const __field_nums = [_]usize{ 999 };
pub const __field_ranges = decoding.fieldRanges(OneofOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(OneofOptions, exclude_fields);
pub const __field_names_map = OneofOptions.FieldNameMap.init(.{
.uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(OneofOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(OneofOptions.FieldEnum, []const u8);
pub fn set(self: *OneofOptions, comptime field: OneofOptions.FieldEnum, value: anytype) void {
    const field_name = comptime OneofOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *OneofOptions, comptime field: OneofOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: OneofOptions, comptime field: OneofOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *OneofOptions, comptime field: OneofOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = OneofOptions.__field_ranges_lut[idx];
    const range = OneofOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *OneofOptions, allocator: Allocator, reader: anytype) Error!void {
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
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: OneofOptions, writer: anytype) Error!void {
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const EnumOptions = struct {
  allow_alias: bool = false,// 2
  deprecated: bool = false,// 3
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(3)  = std.StaticBitSet(3).initEmpty(),
pub const __field_nums = [_]usize{ 2, 3, 999 };
pub const __field_ranges = decoding.fieldRanges(EnumOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(EnumOptions, exclude_fields);
pub const __field_names_map = EnumOptions.FieldNameMap.init(.{
.allow_alias = "allow_alias", .deprecated = "deprecated", .uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(EnumOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(EnumOptions.FieldEnum, []const u8);
pub fn set(self: *EnumOptions, comptime field: EnumOptions.FieldEnum, value: anytype) void {
    const field_name = comptime EnumOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *EnumOptions, comptime field: EnumOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: EnumOptions, comptime field: EnumOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *EnumOptions, comptime field: EnumOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = EnumOptions.__field_ranges_lut[idx];
    const range = EnumOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *EnumOptions, allocator: Allocator, reader: anytype) Error!void {
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
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.allow_alias = try decoding.readBool(reader);
self.setPresent(.allow_alias);
},
3 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.deprecated = try decoding.readBool(reader);
self.setPresent(.deprecated);
},
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: EnumOptions, writer: anytype) Error!void {
if(self.has(.allow_alias)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeBool(self.allow_alias, writer);
}
if(self.has(.deprecated)) {
try decoding.writeFieldKey(3, .varint, writer);
try decoding.writeBool(self.deprecated, writer);
}
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const EnumValueOptions = struct {
  deprecated: bool = false,// 1
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(2)  = std.StaticBitSet(2).initEmpty(),
pub const __field_nums = [_]usize{ 1, 999 };
pub const __field_ranges = decoding.fieldRanges(EnumValueOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(EnumValueOptions, exclude_fields);
pub const __field_names_map = EnumValueOptions.FieldNameMap.init(.{
.deprecated = "deprecated", .uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(EnumValueOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(EnumValueOptions.FieldEnum, []const u8);
pub fn set(self: *EnumValueOptions, comptime field: EnumValueOptions.FieldEnum, value: anytype) void {
    const field_name = comptime EnumValueOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *EnumValueOptions, comptime field: EnumValueOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: EnumValueOptions, comptime field: EnumValueOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *EnumValueOptions, comptime field: EnumValueOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = EnumValueOptions.__field_ranges_lut[idx];
    const range = EnumValueOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *EnumValueOptions, allocator: Allocator, reader: anytype) Error!void {
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
self.deprecated = try decoding.readBool(reader);
self.setPresent(.deprecated);
},
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: EnumValueOptions, writer: anytype) Error!void {
if(self.has(.deprecated)) {
try decoding.writeFieldKey(1, .varint, writer);
try decoding.writeBool(self.deprecated, writer);
}
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const ServiceOptions = struct {
  deprecated: bool = false,// 33
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(2)  = std.StaticBitSet(2).initEmpty(),
pub const __field_nums = [_]usize{ 33, 999 };
pub const __field_ranges = decoding.fieldRanges(ServiceOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(ServiceOptions, exclude_fields);
pub const __field_names_map = ServiceOptions.FieldNameMap.init(.{
.deprecated = "deprecated", .uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(ServiceOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(ServiceOptions.FieldEnum, []const u8);
pub fn set(self: *ServiceOptions, comptime field: ServiceOptions.FieldEnum, value: anytype) void {
    const field_name = comptime ServiceOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *ServiceOptions, comptime field: ServiceOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: ServiceOptions, comptime field: ServiceOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *ServiceOptions, comptime field: ServiceOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = ServiceOptions.__field_ranges_lut[idx];
    const range = ServiceOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *ServiceOptions, allocator: Allocator, reader: anytype) Error!void {
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
33 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.deprecated = try decoding.readBool(reader);
self.setPresent(.deprecated);
},
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: ServiceOptions, writer: anytype) Error!void {
if(self.has(.deprecated)) {
try decoding.writeFieldKey(33, .varint, writer);
try decoding.writeBool(self.deprecated, writer);
}
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const MethodOptions = struct {
  deprecated: bool = false,// 33
  idempotency_level: IdempotencyLevel = .IDEMPOTENCY_UNKNOWN,// 34
  uninterpreted_option: std.ArrayListUnmanaged(UninterpretedOption) = .{},// 999
__fields_present: std.StaticBitSet(3)  = std.StaticBitSet(3).initEmpty(),
  pub const IdempotencyLevel = enum(u2) {
    IDEMPOTENCY_UNKNOWN = 0,
    NO_SIDE_EFFECTS = 1,
    IDEMPOTENT = 2,
  };
pub const __field_nums = [_]usize{ 33, 34, 999 };
pub const __field_ranges = decoding.fieldRanges(MethodOptions, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(MethodOptions, exclude_fields);
pub const __field_names_map = MethodOptions.FieldNameMap.init(.{
.deprecated = "deprecated", .idempotency_level = "idempotency_level", .uninterpreted_option = "uninterpreted_option", });
pub const FieldEnum = decoding.FieldEnum(MethodOptions, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(MethodOptions.FieldEnum, []const u8);
pub fn set(self: *MethodOptions, comptime field: MethodOptions.FieldEnum, value: anytype) void {
    const field_name = comptime MethodOptions.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *MethodOptions, comptime field: MethodOptions.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: MethodOptions, comptime field: MethodOptions.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *MethodOptions, comptime field: MethodOptions.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = MethodOptions.__field_ranges_lut[idx];
    const range = MethodOptions.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *MethodOptions, allocator: Allocator, reader: anytype) Error!void {
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
33 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.deprecated = try decoding.readBool(reader);
self.setPresent(.deprecated);
},
34 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.idempotency_level = try decoding.readEnum(IdempotencyLevel, reader);
self.setPresent(.idempotency_level);
},
999 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//UninterpretedOption isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: UninterpretedOption = undefined;
if(false) { // isrecursive
  it = try allocator.create(UninterpretedOption);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.uninterpreted_option.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.uninterpreted_option);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: MethodOptions, writer: anytype) Error!void {
if(self.has(.deprecated)) {
try decoding.writeFieldKey(33, .varint, writer);
try decoding.writeBool(self.deprecated, writer);
}
if(self.has(.idempotency_level)) {
try decoding.writeFieldKey(34, .varint, writer);
try decoding.writeEnum(IdempotencyLevel, self.idempotency_level, writer);
}
if(self.has(.uninterpreted_option)) {
{
var iter = decoding.constListIterator(self.uninterpreted_option);
while (iter.next()) |it| {
  try decoding.writeFieldKey(999, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const UninterpretedOption = struct {
  name: std.ArrayListUnmanaged(NamePart) = .{},// 2
  identifier_value: []const u8 = "",// 3
  positive_int_value: u64 = 0,// 4
  negative_int_value: i64 = 0,// 5
  double_value: f64 = 0.0,// 6
  string_value: []const u8 = "",// 7
  aggregate_value: []const u8 = "",// 8
__fields_present: std.StaticBitSet(7)  = std.StaticBitSet(7).initEmpty(),
  pub const NamePart = struct {
    name_part: []const u8 = "",// 1
    is_extension: bool = false,// 2
__fields_present: std.StaticBitSet(2)  = std.StaticBitSet(2).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2 };
pub const __field_ranges = decoding.fieldRanges(NamePart, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(NamePart, exclude_fields);
pub const __field_names_map = NamePart.FieldNameMap.init(.{
.name_part = "name_part", .is_extension = "is_extension", });
pub const FieldEnum = decoding.FieldEnum(NamePart, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(NamePart.FieldEnum, []const u8);
pub fn set(self: *NamePart, comptime field: NamePart.FieldEnum, value: anytype) void {
    const field_name = comptime NamePart.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *NamePart, comptime field: NamePart.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: NamePart, comptime field: NamePart.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *NamePart, comptime field: NamePart.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = NamePart.__field_ranges_lut[idx];
    const range = NamePart.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *NamePart, allocator: Allocator, reader: anytype) Error!void {
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
self.name_part = out.toOwnedSlice();
}
self.setPresent(.name_part);
},
2 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.is_extension = try decoding.readBool(reader);
self.setPresent(.is_extension);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: NamePart, writer: anytype) Error!void {
if(self.has(.name_part)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
try decoding.writeString(self.name_part, writer);
}
if(self.has(.is_extension)) {
try decoding.writeFieldKey(2, .varint, writer);
try decoding.writeBool(self.is_extension, writer);
}
}
  };
pub const __field_nums = [_]usize{ 2, 3, 4, 5, 6, 7, 8 };
pub const __field_ranges = decoding.fieldRanges(UninterpretedOption, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(UninterpretedOption, exclude_fields);
pub const __field_names_map = UninterpretedOption.FieldNameMap.init(.{
.name = "name", .identifier_value = "identifier_value", .positive_int_value = "positive_int_value", .negative_int_value = "negative_int_value", .double_value = "double_value", .string_value = "string_value", .aggregate_value = "aggregate_value", });
pub const FieldEnum = decoding.FieldEnum(UninterpretedOption, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(UninterpretedOption.FieldEnum, []const u8);
pub fn set(self: *UninterpretedOption, comptime field: UninterpretedOption.FieldEnum, value: anytype) void {
    const field_name = comptime UninterpretedOption.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *UninterpretedOption, comptime field: UninterpretedOption.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: UninterpretedOption, comptime field: UninterpretedOption.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *UninterpretedOption, comptime field: UninterpretedOption.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = UninterpretedOption.__field_ranges_lut[idx];
    const range = UninterpretedOption.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *UninterpretedOption, allocator: Allocator, reader: anytype) Error!void {
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
2 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
//NamePart isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: NamePart = undefined;
if(false) { // isrecursive
  it = try allocator.create(NamePart);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.name.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.name);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.identifier_value = out.toOwnedSlice();
}
self.setPresent(.identifier_value);
},
4 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.positive_int_value = @bitCast(u64, try decoding.readVarint128(u64, reader, .int));
self.setPresent(.positive_int_value);
},
5 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.negative_int_value = @bitCast(i64, try decoding.readVarint128(u64, reader, .int));
self.setPresent(.negative_int_value);
},
6 => {
if(key.wire_type != .fixed64) return error.InvalidKeyWireType;
self.double_value =  @bitCast(f64, try decoding.readInt64(u64, reader));
self.setPresent(.double_value);
},
7 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.string_value = out.toOwnedSlice();
}
self.setPresent(.string_value);
},
8 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.aggregate_value = out.toOwnedSlice();
}
self.setPresent(.aggregate_value);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: UninterpretedOption, writer: anytype) Error!void {
if(self.has(.name)) {
{
var iter = decoding.constListIterator(self.name);
while (iter.next()) |it| {
  try decoding.writeFieldKey(2, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
if(self.has(.identifier_value)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
try decoding.writeString(self.identifier_value, writer);
}
if(self.has(.positive_int_value)) {
try decoding.writeFieldKey(4, .varint, writer);
try decoding.writeVarint128(u64, self.positive_int_value, writer, .int);
}
if(self.has(.negative_int_value)) {
try decoding.writeFieldKey(5, .varint, writer);
try decoding.writeVarint128(i64, self.negative_int_value, writer, .int);
}
if(self.has(.double_value)) {
try decoding.writeFieldKey(6, .fixed64, writer);
try decoding.writeInt64(@bitCast(u64, self.double_value), writer);
}
if(self.has(.string_value)) {
try decoding.writeFieldKey(7, .length_delimited, writer);
try decoding.writeString(self.string_value, writer);
}
if(self.has(.aggregate_value)) {
try decoding.writeFieldKey(8, .length_delimited, writer);
try decoding.writeString(self.aggregate_value, writer);
}
}
};
pub const SourceCodeInfo = struct {
  location: std.ArrayListUnmanaged(Location) = .{},// 1
__fields_present: std.StaticBitSet(1)  = std.StaticBitSet(1).initEmpty(),
  pub const Location = struct {
    path: std.ArrayListUnmanaged(i32) = .{},// 1
    span: std.ArrayListUnmanaged(i32) = .{},// 2
    leading_comments: []const u8 = "",// 3
    trailing_comments: []const u8 = "",// 4
    leading_detached_comments: std.ArrayListUnmanaged([]const u8) = .{},// 6
__fields_present: std.StaticBitSet(5)  = std.StaticBitSet(5).initEmpty(),
pub const __field_nums = [_]usize{ 1, 2, 3, 4, 6 };
pub const __field_ranges = decoding.fieldRanges(Location, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(Location, exclude_fields);
pub const __field_names_map = Location.FieldNameMap.init(.{
.path = "path", .span = "span", .leading_comments = "leading_comments", .trailing_comments = "trailing_comments", .leading_detached_comments = "leading_detached_comments", });
pub const FieldEnum = decoding.FieldEnum(Location, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(Location.FieldEnum, []const u8);
pub fn set(self: *Location, comptime field: Location.FieldEnum, value: anytype) void {
    const field_name = comptime Location.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *Location, comptime field: Location.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: Location, comptime field: Location.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *Location, comptime field: Location.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = Location.__field_ranges_lut[idx];
    const range = Location.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *Location, allocator: Allocator, reader: anytype) Error!void {
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
const len = try decoding.readVarint128(usize, reader, .int);
var countreader = std.io.countingReader(reader);
const creader = countreader.reader();
while (countreader.bytes_read < len) {
  try self.path.append(allocator, @bitCast(i32, try decoding.readVarint128(u32, creader, .int)));
}
}
self.setPresent(.path);
},
2 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
const len = try decoding.readVarint128(usize, reader, .int);
var countreader = std.io.countingReader(reader);
const creader = countreader.reader();
while (countreader.bytes_read < len) {
  try self.span.append(allocator, @bitCast(i32, try decoding.readVarint128(u32, creader, .int)));
}
}
self.setPresent(.span);
},
3 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.leading_comments = out.toOwnedSlice();
}
self.setPresent(.leading_comments);
},
4 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.trailing_comments = out.toOwnedSlice();
}
self.setPresent(.trailing_comments);
},
6 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
try self.leading_detached_comments.append(allocator, out.toOwnedSlice());
}
self.setPresent(.leading_detached_comments);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: Location, writer: anytype) Error!void {
if(self.has(.path)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
var countwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countwriter.writer();
{
var iter = decoding.constListIterator(self.path);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, cwriter, .int);
}
}
try decoding.writeVarint128(usize, countwriter.bytes_written, writer, .int);
{
var iter = decoding.constListIterator(self.path);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, writer, .int);
}
}
}
if(self.has(.span)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
var countwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countwriter.writer();
{
var iter = decoding.constListIterator(self.span);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, cwriter, .int);
}
}
try decoding.writeVarint128(usize, countwriter.bytes_written, writer, .int);
{
var iter = decoding.constListIterator(self.span);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, writer, .int);
}
}
}
if(self.has(.leading_comments)) {
try decoding.writeFieldKey(3, .length_delimited, writer);
try decoding.writeString(self.leading_comments, writer);
}
if(self.has(.trailing_comments)) {
try decoding.writeFieldKey(4, .length_delimited, writer);
try decoding.writeString(self.trailing_comments, writer);
}
if(self.has(.leading_detached_comments)) {
{
var iter = decoding.constListIterator(self.leading_detached_comments);
while (iter.next()) |it| {
  try decoding.writeFieldKey(6, .length_delimited, writer);
  try decoding.writeString(it, writer);
}
}}
}
  };
pub const __field_nums = [_]usize{ 1 };
pub const __field_ranges = decoding.fieldRanges(SourceCodeInfo, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(SourceCodeInfo, exclude_fields);
pub const __field_names_map = SourceCodeInfo.FieldNameMap.init(.{
.location = "location", });
pub const FieldEnum = decoding.FieldEnum(SourceCodeInfo, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(SourceCodeInfo.FieldEnum, []const u8);
pub fn set(self: *SourceCodeInfo, comptime field: SourceCodeInfo.FieldEnum, value: anytype) void {
    const field_name = comptime SourceCodeInfo.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *SourceCodeInfo, comptime field: SourceCodeInfo.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: SourceCodeInfo, comptime field: SourceCodeInfo.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *SourceCodeInfo, comptime field: SourceCodeInfo.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = SourceCodeInfo.__field_ranges_lut[idx];
    const range = SourceCodeInfo.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *SourceCodeInfo, allocator: Allocator, reader: anytype) Error!void {
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
//Location isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: Location = undefined;
if(false) { // isrecursive
  it = try allocator.create(Location);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.location.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.location);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: SourceCodeInfo, writer: anytype) Error!void {
if(self.has(.location)) {
{
var iter = decoding.constListIterator(self.location);
while (iter.next()) |it| {
  try decoding.writeFieldKey(1, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
pub const GeneratedCodeInfo = struct {
  annotation: std.ArrayListUnmanaged(Annotation) = .{},// 1
__fields_present: std.StaticBitSet(1)  = std.StaticBitSet(1).initEmpty(),
  pub const Annotation = struct {
    path: std.ArrayListUnmanaged(i32) = .{},// 1
    source_file: []const u8 = "",// 2
    begin: i32 = 0,// 3
    end: i32 = 0,// 4
    semantic: Semantic = .NONE,// 5
__fields_present: std.StaticBitSet(5)  = std.StaticBitSet(5).initEmpty(),
    pub const Semantic = enum(u2) {
      NONE = 0,
      SET = 1,
      ALIAS = 2,
    };
pub const __field_nums = [_]usize{ 1, 2, 3, 4, 5 };
pub const __field_ranges = decoding.fieldRanges(Annotation, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(Annotation, exclude_fields);
pub const __field_names_map = Annotation.FieldNameMap.init(.{
.path = "path", .source_file = "source_file", .begin = "begin", .end = "end", .semantic = "semantic", });
pub const FieldEnum = decoding.FieldEnum(Annotation, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(Annotation.FieldEnum, []const u8);
pub fn set(self: *Annotation, comptime field: Annotation.FieldEnum, value: anytype) void {
    const field_name = comptime Annotation.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *Annotation, comptime field: Annotation.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: Annotation, comptime field: Annotation.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *Annotation, comptime field: Annotation.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = Annotation.__field_ranges_lut[idx];
    const range = Annotation.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *Annotation, allocator: Allocator, reader: anytype) Error!void {
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
const len = try decoding.readVarint128(usize, reader, .int);
var countreader = std.io.countingReader(reader);
const creader = countreader.reader();
while (countreader.bytes_read < len) {
  try self.path.append(allocator, @bitCast(i32, try decoding.readVarint128(u32, creader, .int)));
}
}
self.setPresent(.path);
},
2 => {
if(key.wire_type != .length_delimited) return error.InvalidKeyWireType;
{
var out = std.ArrayList(u8).init(allocator);
try decoding.readString(reader, out.writer());
self.source_file = out.toOwnedSlice();
}
self.setPresent(.source_file);
},
3 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.begin = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.begin);
},
4 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.end = @bitCast(i32, try decoding.readVarint128(u32, reader, .int));
self.setPresent(.end);
},
5 => {
if(key.wire_type != .varint) return error.InvalidKeyWireType;
self.semantic = try decoding.readEnum(Semantic, reader);
self.setPresent(.semantic);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: Annotation, writer: anytype) Error!void {
if(self.has(.path)) {
try decoding.writeFieldKey(1, .length_delimited, writer);
var countwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countwriter.writer();
{
var iter = decoding.constListIterator(self.path);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, cwriter, .int);
}
}
try decoding.writeVarint128(usize, countwriter.bytes_written, writer, .int);
{
var iter = decoding.constListIterator(self.path);
while (iter.next()) |it| {
  try decoding.writeVarint128(i32, it, writer, .int);
}
}
}
if(self.has(.source_file)) {
try decoding.writeFieldKey(2, .length_delimited, writer);
try decoding.writeString(self.source_file, writer);
}
if(self.has(.begin)) {
try decoding.writeFieldKey(3, .varint, writer);
try decoding.writeVarint128(i32, self.begin, writer, .int);
}
if(self.has(.end)) {
try decoding.writeFieldKey(4, .varint, writer);
try decoding.writeVarint128(i32, self.end, writer, .int);
}
if(self.has(.semantic)) {
try decoding.writeFieldKey(5, .varint, writer);
try decoding.writeEnum(Semantic, self.semantic, writer);
}
}
  };
pub const __field_nums = [_]usize{ 1 };
pub const __field_ranges = decoding.fieldRanges(GeneratedCodeInfo, exclude_fields);
pub const __field_ranges_lut = decoding.rangeLookupTable(GeneratedCodeInfo, exclude_fields);
pub const __field_names_map = GeneratedCodeInfo.FieldNameMap.init(.{
.annotation = "annotation", });
pub const FieldEnum = decoding.FieldEnum(GeneratedCodeInfo, exclude_fields);
pub const FieldNameMap = std.enums.EnumMap(GeneratedCodeInfo.FieldEnum, []const u8);
pub fn set(self: *GeneratedCodeInfo, comptime field: GeneratedCodeInfo.FieldEnum, value: anytype) void {
    const field_name = comptime GeneratedCodeInfo.__field_names_map.get(field) orelse unreachable;
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
pub fn setPresent(self: *GeneratedCodeInfo, comptime field: GeneratedCodeInfo.FieldEnum) void {
    self.clear(field);
    const idx = comptime @enumToInt(field);
    self.__fields_present.set(idx);
}
pub fn has(self: GeneratedCodeInfo, comptime field: GeneratedCodeInfo.FieldEnum) bool {
    const idx = comptime @enumToInt(field);
    return self.__fields_present.isSet(idx);
}
pub fn clear(self: *GeneratedCodeInfo, comptime field: GeneratedCodeInfo.FieldEnum) void {
    const idx = comptime @enumToInt(field);
    const range_idx = GeneratedCodeInfo.__field_ranges_lut[idx];
    const range = GeneratedCodeInfo.__field_ranges[range_idx];
    self.__fields_present.setRangeValue(range, false);
}
pub fn deserialize(self: *GeneratedCodeInfo, allocator: Allocator, reader: anytype) Error!void {
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
//Annotation isrecursive false
const len = try decoding.readVarint128(usize, reader, .int);
const bytes_left = reader.context.bytes_left;
reader.context.bytes_left = len;
var it: Annotation = undefined;
if(false) { // isrecursive
  it = try allocator.create(Annotation);
  it.?.* = .{};
}
else it = .{};
try it.deserialize(allocator, reader);
try self.annotation.append(allocator, it);
reader.context.bytes_left = bytes_left - len;
}
self.setPresent(.annotation);
},
            else => {std.debug.print("unexpected key {}\n", .{key}); return error.InvalidKey;},
}
}
}

pub fn serialize(self: GeneratedCodeInfo, writer: anytype) Error!void {
if(self.has(.annotation)) {
{
var iter = decoding.constListIterator(self.annotation);
while (iter.next()) |it| {
  try decoding.writeFieldKey(1, .length_delimited, writer);
  var countingwriter = std.io.countingWriter(std.io.null_writer);
const cwriter = countingwriter.writer();

  try it.serialize(cwriter);
  try decoding.writeVarint128(usize, countingwriter.bytes_written, writer, .int);
  try it.serialize(writer);
}
}
}
}
};
test {
    _ = std.testing.refAllDecls(@This());
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allr = arena.allocator();
{
    var x: FileDescriptorSet = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: FileDescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: ExtensionRangeOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: DescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: FieldDescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: OneofDescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: EnumDescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: EnumValueDescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: ServiceDescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: MethodDescriptorProto = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: FileOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: MessageOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: FieldOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: OneofOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: EnumOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: EnumValueOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: ServiceOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: MethodOptions = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: UninterpretedOption = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: SourceCodeInfo = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
{
    var x: GeneratedCodeInfo = .{};
    x.__fields_present = @TypeOf(x.__fields_present).initEmpty();
    var fbs = std.io.fixedBufferStream("\xFF\xFF\xFF\x00");
    try std.testing.expectError(error.InvalidKey, x.deserialize(allr, fbs.reader()));
    var output = std.ArrayList(u8).init(allr);
    x.serialize(output.writer()) catch {};
}
}
