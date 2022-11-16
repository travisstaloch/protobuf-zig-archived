const std = @import("std");
const decoding = @import("decoding.zig");
pub const descriptor = @import("gen/examples/google/protobuf/descriptor.proto.zig");
pub const plugin = @import("gen/examples/google/protobuf/compiler/plugin.proto.zig");
const FileDescriptorProto = descriptor.FileDescriptorProto;
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

// pub const File = struct {
//     source: ?[*:0]const u8,
//     name: Name,
//     package: ?TokenIndex = null,
//     options: std.ArrayListUnmanaged([2]TokenIndex) = .{},
//     scope: Scope = .{},
//     token_it: TokenIterator,
//     syntax: Syntax = .proto2,
//     deps: std.AutoHashMapUnmanaged(*File, void) = .{},

//     pub const Name = union(enum) {
//         path: [*:0]const u8, // file path (usually a cli arg)
//         import: Import, // an imported name

//         pub fn pathStr(name: Name) []const u8 {
//             return switch (name) {
//                 .path => std.mem.span(name.path),
//                 .import => name.import.realpath,
//             };
//         }
//     };
//     pub const Import = struct {
//         /// resolved full path to import
//         realpath: []const u8 = &.{},
//         /// site where import occurs
//         site: Site,
//     };
//     pub const Syntax = enum { proto2, proto3 };

//     pub fn init(source: ?[*:0]const u8, name: Name) File {
//         return .{ .source = source, .name = name, .token_it = .{ .tokens = &.{} } };
//     }
// };
pub const File = struct {
    source: ?[*:0]const u8,
    path: [*:0]const u8,
    scope: Scope = .{},
    token_it: TokenIterator,
    descriptor: *FileDescriptorProto,
    syntax: Syntax = .proto2,

    pub const Syntax = enum { proto2, proto3 };
};
pub const Scope = struct {
    // enums: NodeList = .{},
    // messages: NodeList = .{},
    parent: ?*const Scope = null,
};
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

pub const FileMap = std.StringHashMapUnmanaged(File);

pub const Node = union(enum) {
    @"enum": *EnumNode,
    message: *MessageNode,

    pub fn nameToken(n: Node) TokenIndex {
        return switch (n) {
            .@"enum" => n.@"enum".name,
            .message => n.message.name,
        };
    }
};

pub const NodeList = std.ArrayListUnmanaged(Node);
pub const LineCol = struct {
    line: i32,
    col: i32,
};
pub const Loc = struct {
    start: u32,
    end: u32,
};

pub const EnumNode = struct {
    loc: Loc,
    name: TokenIndex,
    fields: std.ArrayListUnmanaged(Field) = .{},
    options: std.ArrayListUnmanaged([2]TokenIndex) = .{},

    pub const Field = [2]TokenIndex; // name, value
};

// pub const Scope = struct {
//     enums: NodeList = .{},
//     messages: NodeList = .{},
//     parent: ?*const Scope = null,
// };

pub const MessageNode = struct {
    loc: Loc,
    name: TokenIndex,
    fields: std.ArrayListUnmanaged(FieldU) = .{},
    scope: Scope = .{},
    extensions: RangeList = .{},
    reserved: RangeList = .{},
    parent_node: ?*const MessageNode,

    pub const FieldTag = std.meta.Tag(FieldU);
    pub const FieldU = union(enum) {
        f: Field,
        u: OneOfField,
    };

    pub const Field = struct {
        tokens: [3]TokenIndex, // type, name, number
        labels: std.EnumSet(decoding.Label) = .{},
        options: std.ArrayListUnmanaged([2]TokenIndex) = .{},
    };

    pub const OneOfField = struct {
        name: TokenIndex,
        fields: std.ArrayListUnmanaged(Field) = .{},
    };
};

pub const Range = struct { start: TokenIndex, end: ?TokenIndex };
pub const RangeList = std.ArrayListUnmanaged(Range);

pub const ErrorMsg = struct {
    msg: []const u8,
    token: Token,
    file: *File,
};

pub const NodeAndFile = struct {
    node: Node,
    file: *File,
};
