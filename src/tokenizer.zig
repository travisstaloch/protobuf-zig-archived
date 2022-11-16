const std = @import("std");
const log = std.log;
const testing = std.testing;
const types = @import("types.zig");
const Token = types.Token;

pub const Tokenizer = struct {
    source: [*:0]const u8,
    index: u32 = 0,
    line_col: types.LineCol = .{ .line = 0, .col = 0 },

    pub fn next(self: *Tokenizer) Token {
        var result = Token{
            .id = .eof,
            .loc = .{
                .start = self.index,
                .end = undefined,
            },
            .line_col_start = self.line_col,
            .line_col_end = undefined,
        };

        var state: enum {
            start,
            identifier,
            identifier_dotted,
            dot,
            string_literal,
            int_literal,
            slash,
            line_comment,
            multiline_comment,
            multiline_comment_end,
        } = .start;

        while (self.source[self.index] != 0) : (self.index += 1) {
            const c = self.source[self.index];
            if (c == '\n') {
                self.line_col.line += 1;
                self.line_col.col = 0;
            } else self.line_col.col += 1;

            switch (state) {
                .start => switch (c) {
                    ' ', '\t', '\n', '\r' => {
                        result.loc.start = self.index + 1;
                    },
                    'a'...'z', 'A'...'Z', '_' => {
                        state = .identifier;
                        result.id = .identifier;
                    },
                    '{' => {
                        result.id = .l_brace;
                        self.index += 1;
                        break;
                    },
                    '}' => {
                        result.id = .r_brace;
                        self.index += 1;
                        break;
                    },
                    '[' => {
                        result.id = .l_sbrace;
                        self.index += 1;
                        break;
                    },
                    ']' => {
                        result.id = .r_sbrace;
                        self.index += 1;
                        break;
                    },
                    '(' => {
                        result.id = .l_paren;
                        self.index += 1;
                        break;
                    },
                    ')' => {
                        result.id = .r_paren;
                        self.index += 1;
                        break;
                    },
                    ';' => {
                        result.id = .semicolon;
                        self.index += 1;
                        break;
                    },
                    '.' => {
                        state = .dot;
                        result.id = .dot;
                    },
                    ',' => {
                        result.id = .comma;
                        self.index += 1;
                        break;
                    },
                    '0'...'9', '-' => {
                        state = .int_literal;
                        result.id = .int_literal;
                    },
                    '=' => {
                        result.id = .equal;
                        self.index += 1;
                        break;
                    },
                    '/' => {
                        state = .slash;
                    },
                    '"' => {
                        result.id = .string_literal;
                        state = .string_literal;
                    },
                    '<' => {
                        result.id = .lt;
                        self.index += 1;
                        break;
                    },
                    '>' => {
                        result.id = .gt;
                        self.index += 1;
                        break;
                    },
                    else => {
                        result.id = .invalid;
                        result.loc.end = self.index;
                        self.index += 1;
                        return result;
                    },
                },
                .slash => switch (c) {
                    '/' => {
                        state = .line_comment;
                    },
                    '*' => {
                        state = .multiline_comment;
                    },
                    else => {
                        result.id = .invalid;
                        self.index += 1;
                        break;
                    },
                },
                .line_comment => switch (c) {
                    '\n' => {
                        state = .start;
                        result.loc.start = self.index + 1;
                    },
                    else => {},
                },
                .multiline_comment => switch (c) {
                    '*' => {
                        state = .multiline_comment_end;
                    },
                    else => {},
                },
                .multiline_comment_end => switch (c) {
                    '/' => {
                        state = .start;
                        result.loc.start = self.index + 1;
                    },
                    else => {
                        state = .multiline_comment;
                    },
                },
                .dot => switch (c) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => {
                        state = .identifier_dotted;
                        result.id = .identifier_dotted;
                    },
                    else => {
                        result.id = .dot;
                        break;
                    },
                },
                .identifier, .identifier_dotted => switch (c) {
                    'a'...'z', 'A'...'Z', '_', '0'...'9' => {},
                    '.' => {
                        result.id = .identifier_dotted;
                    },
                    else => {
                        if (Token.getKeyword(self.source[result.loc.start..self.index])) |id| {
                            result.id = id;
                        }
                        break;
                    },
                },
                .int_literal => switch (c) {
                    '0'...'9' => {},
                    else => {
                        break;
                    },
                },
                .string_literal => switch (c) {
                    '"' => {
                        self.index += 1;
                        break;
                    },
                    else => {}, // TODO validate characters/encoding
                },
            }
        }

        if (result.id == .eof) {
            result.loc.start = self.index;
        }

        result.loc.end = self.index;
        result.line_col_end = self.line_col;
        return result;
    }
};

fn testExpected(source: [*:0]const u8, expected: []const Token.Id) !void {
    var tokenizer = Tokenizer{
        .source = source,
    };
    for (expected) |exp, i| {
        const token = tokenizer.next();
        if (exp != token.id) {
            const stderr = std.io.getStdErr().writer();
            try stderr.print("Tokens don't match: (exp) {} != (giv) {} at pos {d}\n", .{ exp, token.id, i + 1 });
            return error.TestExpectedEqual;
        }
        try testing.expectEqual(exp, token.id);
    }
}

test "simple enum" {
    try testExpected(
        \\/*
        \\ * Some cool kind
        \\ */
        \\enum SomeKind
        \\{
        \\  // This generally means none
        \\  NONE = 0;
        \\  // This means A
        \\  // and only A
        \\  A = 1;
        \\  /* B * * * * */
        \\  B = 2;
        \\  // And this one is just a C
        \\  C = 3;
        \\}
    , &[_]Token.Id{
        // zig fmt: off
        .keyword_enum, .identifier,
        .l_brace,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
        .r_brace,
        // zig fmt: on
    });
}

test "simple enum - weird formatting" {
    try testExpected(
        \\enum SomeKind {  NONE = 0;
        \\A = 1;
        \\       B = 2; C = 3;
        \\}
    , &[_]Token.Id{
        // zig fmt: off
        .keyword_enum, .identifier,
        .l_brace,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
        .r_brace,
        // zig fmt: on
    });
}

test "simple message" {
    try testExpected(
        \\message MyMessage
        \\{
        \\  Ptr ptr_field = 1;
        \\  int32 ptr_len = 2;
        \\}
    , &[_]Token.Id{
        // zig fmt: off
        .keyword_message, .identifier,
        .l_brace,
            .identifier, .identifier, .equal, .int_literal, .semicolon,
            .identifier, .identifier, .equal, .int_literal, .semicolon,
        .r_brace,
        // zig fmt: on
    });
}

test "full proto spec file" {
    try testExpected(
        \\// autogen by super_proto_gen.py
        \\
        \\syntax = "proto3";
        \\
        \\package my_pkg;
        \\
        \\import "another.proto";
        \\
        \\message MsgA {
        \\  int32 field_1 = 1;
        \\  repeated Msg msgs = 2 [(nanopb).type=FT_POINTER];
        \\}
        \\
        \\// Tagged union y'all!
        \\message Msg {
        \\  oneof msg {
        \\    MsgA msg_a = 1 [json_name="msg_a"];
        \\    MsgB msg_b = 2 [ json_name = "msg_b" ];
        \\  }
        \\}
        \\
        \\/*
        \\ * Message B
        \\ */
        \\message MsgB {
        \\  // Some kind
        \\  Kind kind = 1;
        \\  // If the message is valid
        \\  bool valid = 2;
        \\}
        \\
        \\enum Kind {
        \\  KIND_NONE = 0;
        \\  KIND_A = 1;
        \\  KIND_B = 2;
        \\}
    , &[_]Token.Id{
        // zig fmt: off

        .keyword_syntax, .equal, .string_literal, .semicolon,

        .keyword_package, .identifier, .semicolon,

        .keyword_import, .string_literal, .semicolon,

        .keyword_message, .identifier,
        .l_brace,
            .identifier, .identifier, .equal, .int_literal, .semicolon,
            .keyword_repeated, .identifier, .identifier, .equal, .int_literal, .l_sbrace, .l_paren, .identifier, .r_paren, .identifier_dotted, .equal, .identifier, .r_sbrace, .semicolon,
        .r_brace,

        .keyword_message, .identifier,
        .l_brace,
            .keyword_oneof, .identifier,
            .l_brace,
                .identifier, .identifier, .equal, .int_literal, .l_sbrace, .identifier, .equal, .string_literal, .r_sbrace, .semicolon,
                .identifier, .identifier, .equal, .int_literal, .l_sbrace, .identifier, .equal, .string_literal, .r_sbrace, .semicolon,
            .r_brace,
        .r_brace,

        .keyword_message, .identifier,
        .l_brace,
            .identifier, .identifier, .equal, .int_literal, .semicolon,
            .identifier, .identifier, .equal, .int_literal, .semicolon,
        .r_brace,

        .keyword_enum, .identifier,
        .l_brace,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
            .identifier, .equal, .int_literal, .semicolon,
        .r_brace,

        // zig fmt: on
    });
}

test "identifier_dotted" {
    try testExpected(
        \\ . .a.b a.b ab. . ab .
        , &[_]Token.Id{
            .dot,
            .identifier_dotted,  
            .identifier_dotted, 
            .identifier_dotted, 
            .dot, 
            .identifier,
            .dot, 
        });
}