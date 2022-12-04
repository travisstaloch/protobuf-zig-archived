const std = @import("std");
const decoding = @import("decoding.zig");
pub const descriptor = @import("gen/examples/google/protobuf/descriptor.proto.zig");
pub const plugin = @import("gen/examples/google/protobuf/compiler/plugin.proto.zig");
const FileDescriptorProto = descriptor.FileDescriptorProto;
const FieldDescriptorProto = descriptor.FieldDescriptorProto;
const DescriptorProto = descriptor.DescriptorProto;
const EnumDescriptorProto = descriptor.EnumDescriptorProto;
const OneofDescriptorProto = descriptor.OneofDescriptorProto;

pub const Token = struct {
    id: Id,
    loc: Loc,
    line_col_start: LineCol,
    line_col_end: LineCol,

    pub const keywords = std.ComptimeStringMap(Id, .{
        .{ "enum", .keyword_enum },
        .{ "extensions", .keyword_extensions },
        .{ "message", .keyword_message },
        .{ "repeated", .keyword_repeated },
        .{ "optional", .keyword_optional },
        .{ "option", .keyword_option },
        .{ "oneof", .keyword_oneof },
        .{ "syntax", .keyword_syntax },
        .{ "package", .keyword_package },
        .{ "import", .keyword_import },
        .{ "reserved", .keyword_reserved },
        .{ "required", .keyword_required },
        .{ "map", .keyword_map },
    });

    pub fn getKeyword(bytes: []const u8) ?Id {
        return keywords.get(bytes);
    }

    pub const Id = enum {
        // zig fmt: off
        eof,

        invalid,
        l_brace,          // {
        r_brace,          // }
        l_sbrace,         // [
        r_sbrace,         // ]
        l_paren,          // (
        r_paren,          // )
        dot,              // .
        comma,            // ,
        semicolon,        // ;
        equal,            // =
        lt,               // <
        gt,               // >

        string_literal,   // "something"
        int_literal,      // 1
        identifier,       // ident
        identifier_dotted,// .a.b or a.b (or a.) // TODO disallow trailing dot ie: 'a.' 

        keyword_enum,       // enum { ... }
        keyword_extensions, // extensions 10 to 20, 40 to max
        keyword_message,    // message { ... }
        keyword_repeated,   // repeated Type field = 5;
        keyword_option,     // option some_option = true;
        keyword_optional,   // optional Type field = 5;
        keyword_oneof,      // oneof { ... }
        keyword_syntax,     // syntax = "proto3";
        keyword_package,    // package my_pkg;
        keyword_import,     // import "other.proto";
        keyword_reserved,   // reserved 2, 15, 9 to 11;  reserved "foo", "bar";
        keyword_required,   // required Type field = 5;
        keyword_map,        // map<int32, int32> map_int32_int32 = 56;

        // zig fmt: on

        pub fn toString(id: Id) []const u8 {
            return switch (id) {
                .l_brace => "{",
                .r_brace => "}",
                .l_sbrace => "[",
                .r_sbrace => "]",
                .l_paren => "(",
                .r_paren => ")",
                .dot => ".",
                .comma => ",",
                .semicolon => ";",
                .equal => "=",
                .lt => "<",
                .gt => ">",
                else => @tagName(id),
            };
        }

        pub fn format(id: Id, comptime _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
            _ = try writer.write(id.toString());
        }
    };
};

pub const TokenIterator = struct {
    tokens: []const Token,
    pos: TokenIndex = 0,

    pub fn next(self: *TokenIterator) Token {
        const token = self.tokens[self.pos];
        self.pos += 1;
        return token;
    }

    pub fn peek(self: TokenIterator) ?Token {
        if (self.pos >= self.tokens.len) return null;
        return self.tokens[self.pos];
    }

    pub fn reset(self: *TokenIterator) void {
        self.pos = 0;
    }

    pub fn seekTo(self: *TokenIterator, pos: TokenIndex) void {
        self.pos = pos;
    }

    pub fn seekBy(self: *TokenIterator, offset: isize) void {
        const new_pos = @bitCast(isize, self.pos) + offset;
        if (new_pos < 0) {
            self.pos = 0;
        } else {
            self.pos = @intCast(usize, new_pos);
        }
    }
};

pub const TokenIndex = usize;

pub fn Result(comptime Ok: type) type {
    return union(enum) { ok: Ok, err };
}

pub const Error = error{
    OutOfMemory,
    GenFail,
    ParseFail,
} ||
    std.fmt.ParseIntError ||
    std.fs.File.WriteFileError ||
    std.fs.File.ReadError ||
    std.fs.File.OpenError ||
    std.fmt.BufPrintError ||
    std.os.RealPathError;

pub const Scope = struct {
    parent: ?*const Scope,
    file: *File,
    node: Node,

    pub const Node = union(enum) {
        file: *FileDescriptorProto,
        message: *DescriptorProto,
        enum_: *EnumDescriptorProto,

        pub const Tag = std.meta.Tag(Node);
        pub fn TagItem(comptime tag: Tag) type {
            return switch (tag) {
                .file => FileDescriptorProto,
                .message => DescriptorProto,
                .enum_ => EnumDescriptorProto,
            };
        }
        pub fn init(comptime tag: Tag, item: *TagItem(tag)) Node {
            return comptime switch (tag) {
                .file => .{ .file = item },
                .message => .{ .message = item },
                .enum_ => .{ .enum_ = item },
            };
        }
        pub fn name(n: Node) []const u8 {
            return switch (n) {
                .file => n.file.name,
                .message => n.message.name,
                .enum_ => n.enum_.name,
            };
        }
    };

    pub fn init(parent: ?*const Scope, file: *File, node: Node) Scope {
        return .{
            .parent = parent,
            .file = file,
            .node = node,
        };
    }
};

pub const ScopedField = struct {
    scope: *const Scope,
    field: *FieldDescriptorProto,
};

pub const File = struct {
    source: ?[*:0]const u8,
    path: [*:0]const u8,
    token_it: TokenIterator,
    descriptor: *FileDescriptorProto,
    syntax: Syntax = .proto2,

    pub const Syntax = enum { proto2, proto3 };
    pub const ImportType = enum { import, root };

    pub fn init(
        source: ?[*:0]const u8,
        path: [*:0]const u8,
    ) File {
        return .{
            .source = source,
            .path = path,
            .descriptor = undefined,
            .token_it = .{ .tokens = &.{} },
        };
    }
};

pub fn SegmentedList(comptime T: type) type {
    return std.SegmentedList(T, 0);
}

/// represents a token within a file
pub const Site = struct {
    tokid: TokenIndex,
    file: *File,

    pub fn init(tokid: TokenIndex, file: *File) Site {
        return .{ .tokid = tokid, .file = file };
    }

    pub fn content(site: Site) []const u8 {
        const tok = site.file.token_it.tokens[site.tokid];
        return site.file.source.?[tok.loc.start..tok.loc.end];
    }
};

pub const FileMap = std.StringHashMapUnmanaged(*File);

pub const LineCol = struct {
    line: i32,
    col: i32,
};
pub const Loc = struct {
    start: u32,
    end: u32,
};

pub const ErrorMsg = struct {
    msg: []const u8,
    token: Token,
    file: *File,
};

pub const MessageDescriptor = struct {
    // magic: u32,
    name: []const u8,
    // short_name: [*c]const u8,
    // c_name: [*c]const u8,
    // package_name: [*c]const u8,
    // sizeof_message: usize,
    // n_fields: c_uint,
    fields: std.ArrayListUnmanaged(FieldDescriptor) = .{},
    nested_type: std.ArrayListUnmanaged(MessageDescriptor) = .{},
    enum_type: std.ArrayListUnmanaged(EnumDescriptor) = .{},
    // fields_sorted_by_name: [*c]const c_uint,
    // n_field_ranges: c_uint,
    // field_ranges: [*c]const ProtobufCIntRange,
    // message_init: ProtobufCMessageInit,
    // reserved1: ?*anyopaque,
    // reserved2: ?*anyopaque,
    // reserved3: ?*anyopaque,
};
pub const FieldDescriptor = struct {
    name: []const u8,
    id: i32,
    label: descriptor.FieldDescriptorProto.Label,
    type: descriptor.FieldDescriptorProto.Type,
    // quantifier_offset: c_uint,
    offset: u32,
    descriptor: ?Descriptor,
    // oneof_index: ?u32,
    // default_value: ?*const anyopaque,
    flags: Flags,
    // reserved_flags: c_uint,
    // reserved2: ?*anyopaque,
    // reserved3: ?*anyopaque,
    pub const Flag = enum {
        oneof,
        packt,
    };
    pub const Flags = std.EnumSet(Flag);
};
pub const EnumDescriptor = struct {
    // magic: u32,
    name: []const u8,
    // short_name: [*c]const u8,
    // c_name: [*c]const u8,
    // package_name: [*c]const u8,
    // n_values: c_uint,
    values: std.ArrayListUnmanaged(EnumValue) = .{},
    // n_value_names: c_uint,
    // values_by_name: [*c]const ProtobufCEnumValueIndex,
    // n_value_ranges: c_uint,
    // value_ranges: [*c]const ProtobufCIntRange,
    // reserved1: ?*anyopaque,
    // reserved2: ?*anyopaque,
    // reserved3: ?*anyopaque,
    // reserved4: ?*anyopaque,
};

pub const EnumValue = struct {
    name: []const u8,
    // c_name: [*c]const u8,
    value: i32,
};

pub const FileDescriptor = struct {
    name: []const u8,
    package: []const u8,
    message_type: std.ArrayListUnmanaged(MessageDescriptor) = .{},
    enum_type: std.ArrayListUnmanaged(EnumDescriptor) = .{},
};

pub const Descriptor = extern struct {
    payload: Payload,
    ty: Type,
    const Payload = extern union {
        message: *MessageDescriptor,
        enum_: *EnumDescriptor,
        file: *FileDescriptor,
    };
    const Type = enum(u8) { message, enum_, file };
    pub fn init(comptime ty: Type, payload: anytype) Descriptor {
        const pl = switch (ty) {
            .file => .{ .file = payload },
            .message => .{ .message = payload },
            .enum_ => .{ .enum_ = payload },
        };
        return .{ .ty = ty, .payload = pl };
    }
    pub fn name(self: Descriptor) []const u8 {
        return switch (self.ty) {
            .message => |x| x.name,
            .enum_ => |x| x.name,
            .file => |x| x.name,
        };
    }
};

pub const DescriptorMap = std.StringHashMapUnmanaged(*Descriptor);

pub const Message = extern struct {
    base: Descriptor,
};
