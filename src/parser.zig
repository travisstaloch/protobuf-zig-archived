const std = @import("std");
const mem = std.mem;
const Allocator = mem.Allocator;
const assert = std.debug.assert;
const tokenizer = @import("tokenizer.zig");
const types = @import("types.zig");
const protozig = @import("lib.zig");
const util = @import("util.zig");
const plugin = types.plugin;
const descriptor = types.descriptor;
const CodeGeneratorRequest = plugin.CodeGeneratorRequest;
const DescriptorProto = descriptor.DescriptorProto;
const EnumValueDescriptorProto = descriptor.EnumValueDescriptorProto;
const EnumDescriptorProto = descriptor.EnumDescriptorProto;
const FieldDescriptorProto = descriptor.FieldDescriptorProto;
const SourceCodeInfo = descriptor.SourceCodeInfo;
const FileDescriptorProto = descriptor.FileDescriptorProto;
const Token = types.Token;
const TokenIndex = types.TokenIndex;
const TokenIterator = types.TokenIterator;
const Error = types.Error;
const File = types.File;
const FileMap = types.FileMap;
const Scope = types.Scope;
const ScopedField = types.ScopedField;
const todo = util.todo;

pub fn init(allocator: Allocator, path: [*:0]const u8, source: [*:0]const u8, include_paths: []const [:0]const u8, errwriter: anytype) Parser(@TypeOf(errwriter)) {
    return Parser(@TypeOf(errwriter)).init(allocator, path, source, include_paths, errwriter);
}

pub fn Parser(comptime ErrWriter: type) type {
    return struct {
        arena: Allocator,
        include_paths: []const [:0]const u8 = &.{},
        req: CodeGeneratorRequest = .{},
        root_file: File,
        errwriter: ErrWriter,
        deps_map: FileMap = .{},
        tmp_buf: std.ArrayListUnmanaged(u8) = .{},
        unresolved_types: std.StringHashMapUnmanaged(ScopedField) = .{},

        const Self = @This();

        pub fn init(arena: Allocator, path: [*:0]const u8, source: [*:0]const u8, include_paths: []const [:0]const u8, errwriter: ErrWriter) Self {
            return .{
                .arena = arena,
                .root_file = .{
                    .path = path,
                    .source = source,
                    .token_it = undefined,
                    .descriptor = undefined,
                    .scope = Scope.init(null, undefined, undefined),
                },
                .include_paths = include_paths,
                .errwriter = errwriter,
            };
        }

        fn fail(parser: *Self, comptime format: []const u8, args: anytype, token_idx: TokenIndex, file: *File) Error {
            try protozig.writeErr(.{
                .msg = try std.fmt.allocPrint(parser.arena, format ++ "\n", args),
                .token = file.token_it.tokens[token_idx],
                .file = file,
            }, parser.errwriter);
            return error.ParseFail;
        }

        pub fn tokenize(allocator: Allocator, file: *File) !void {
            var t: tokenizer.Tokenizer = .{ .source = file.source.? };
            var tokens = std.ArrayList(types.Token).init(allocator);

            while (true) {
                const token = t.next();
                try tokens.append(token);
                if (token.id == .eof) break;
            }

            var token_it = TokenIterator{ .tokens = tokens.toOwnedSlice() };
            file.token_it = token_it;
        }

        pub fn parse(p: *Self) !CodeGeneratorRequest {
            try p.deps_map.put(p.arena, std.mem.span(p.root_file.path), &p.root_file);
            try tokenize(p.arena, &p.root_file);
            try p.parseFile(&p.root_file, .root);
            // FIXME if necessary find a real solution to ordering the proto_files.
            // maybe relating to declaration order.
            std.mem.reverse(FileDescriptorProto, p.req.proto_file.items);
            var iter = p.unresolved_types.iterator();
            while (iter.next()) |ent| {
                //     std.debug.print("{s}\n", .{ent.key_ptr.*});
                const typename = ent.key_ptr.*;
                const scoped_field = ent.value_ptr.*;
                try p.fixupFieldTypes(typename, scoped_field);
            }

            return p.req;
        }

        fn findTypenameScoped(typename: []const u8, scope_: *const Scope) ?FieldDescriptorProto.Type {
            var mscope: ?*const Scope = scope_;
            while (mscope) |scope| : (mscope = scope.parent) {
                // std.debug.print("findTypenameScoped({s}) node tag {s} name {s}\n", .{ typename, @tagName(scope.node), scope.node.name() });
                switch (scope.node) {
                    .file => |f| {
                        for (f.enum_type.items) |e| {
                            if (std.mem.eql(u8, typename, e.name)) return .TYPE_ENUM;
                        }
                        for (f.message_type.items) |m| {
                            if (std.mem.eql(u8, typename, m.name)) return .TYPE_MESSAGE;
                        }
                    },
                    .message => |m| {
                        if (std.mem.eql(u8, typename, m.name)) return .TYPE_MESSAGE;
                        for (m.enum_type.items) |e|
                            if (std.mem.eql(u8, typename, e.name)) return .TYPE_ENUM;
                    },
                    .enum_ => |e| {
                        if (std.mem.eql(u8, typename, e.name)) return .TYPE_ENUM;
                    },
                }
            }
            return null;
        }

        pub fn parseFile(parser: *Self, file: *File, ty: File.ImportType) !void {
            parser.req.setPresent(.proto_file);
            file.descriptor = try parser.req.proto_file.addOne(parser.arena);
            file.descriptor.* = .{};
            file.scope = Scope.init(null, file, .{ .file = file.descriptor });
            const file_base = std.fs.path.basename(std.mem.span(file.path));
            file.descriptor.set(.name, file_base);
            const source_code_info = try parser.arena.create(descriptor.SourceCodeInfo);
            source_code_info.* = .{};
            file.descriptor.set(.source_code_info, source_code_info);

            while (true) {
                const pos = file.token_it.pos;
                const token = file.token_it.next();
                if (token.id == .eof) break;

                switch (token.id) {
                    .keyword_syntax => {
                        _ = try parser.expectToken(.equal, file);
                        const syntax = try parser.expectToken(.string_literal, file);
                        const syntax_content = tokenIdContent(syntax, file);
                        file.syntax = std.meta.stringToEnum(File.Syntax, syntax_content[1 .. syntax_content.len - 1]) orelse
                            return parser.fail("invalid syntax {s}", .{syntax_content}, syntax, file);
                        file.descriptor.set(.syntax, syntax_content[1 .. syntax_content.len - 1]);
                        _ = try parser.expectToken(.semicolon, file);
                        if (file.syntax == .proto2)
                            return parser.fail("proto2 syntax not yet supported", .{}, syntax, file);
                    },
                    .keyword_package => {
                        const package = try parser.expectTokenIn(&.{ .identifier, .identifier_dotted }, file);
                        file.descriptor.set(.package, tokenIdContent(package, file));
                        _ = try parser.expectToken(.semicolon, file);
                    },
                    .keyword_enum => {
                        try parser.parseEnum(
                            pos,
                            file,
                            &file.descriptor.enum_type,
                            source_code_info,
                        );
                        file.descriptor.setPresent(.enum_type);
                    },
                    .keyword_import => {
                        const filename = try parser.expectToken(.string_literal, file);
                        _ = try parser.expectToken(.semicolon, file);
                        try parser.resolveImport(filename, file);
                    },
                    .keyword_message => {
                        try parser.parseMessage(
                            pos,
                            file,
                            &file.descriptor.message_type,
                            source_code_info,
                            &file.scope,
                        );
                        file.descriptor.setPresent(.message_type);
                    },
                    .keyword_option => {
                        const nameid = try parser.expectToken(.identifier, file);
                        _ = try parser.expectToken(.equal, file);
                        const contentid = try parser.expectTokenIn(&.{ .string_literal, .int_literal, .identifier }, file);
                        _ = try parser.expectToken(.semicolon, file);
                        const optname = tokenIdContent(nameid, file);
                        const options = if (file.descriptor.options) |o| o else blk: {
                            const o = try parser.arena.create(descriptor.FileOptions);
                            o.* = .{};
                            break :blk o;
                        };

                        const matched = try parser.parseOptions(
                            descriptor.FileOptions,
                            descriptor.FileOptions.FileOptionsFieldEnum,
                            optname,
                            nameid,
                            options,
                            contentid,
                            file,
                        );

                        if (!matched)
                            return parser.fail("failed to match file option {s}", .{optname}, nameid, file);

                        file.descriptor.set(.options, options);
                    },
                    else => return parser.fail("TODO unhandled token '{s}' ", .{tokenContent(token, file)}, pos, file),
                }
            }
            if (ty != .import) {
                parser.req.setPresent(.file_to_generate);
                try parser.req.file_to_generate.append(parser.arena, file_base);
            }

            // parse imported files
            for (file.descriptor.dependency.items) |dep_name| {
                const depfile = parser.deps_map.get(dep_name).?;
                if (depfile.token_it.tokens.len == 0) {
                    assert(depfile.token_it.pos == 0);
                    try tokenize(parser.arena, depfile);
                    try parser.parseFile(depfile, .import);
                }
            }
        }

        /// assumes '[' was previous
        /// used for parsing options of form '[ctype = CORD]'
        /// T: descriptor.FileOptions or FieldOptions
        /// E: descriptor.FieldOptions.FieldOptionsFieldEnum
        fn parseOptions(
            parser: *Self,
            comptime T: type,
            comptime E: type,
            optname: []const u8,
            nameid: TokenIndex,
            options: *T,
            contentid: TokenIndex,
            file: *File,
        ) Error!bool {
            inline for (std.meta.fields(T)) |f| {
                @setEvalBranchQuota(8000);
                if (comptime std.mem.eql(u8, f.name, "__fields_present")) continue;

                const last_uscore_idx = comptime blk: {
                    var lasttuidx = f.name.len - 1;
                    while (f.name[lasttuidx] == '_') lasttuidx -= 1;
                    break :blk lasttuidx;
                };

                if (std.mem.eql(u8, f.name[0 .. last_uscore_idx + 1], optname)) {
                    const fe = comptime std.meta.stringToEnum(E, f.name) orelse
                        @compileError("enum value not found for field '" ++ f.name ++ "'");
                    const info = @typeInfo(f.field_type);
                    switch (info) {
                        .Bool => {
                            options.set(fe, try parser.parseBool(contentid, file));
                            return true;
                        },
                        .Enum => {
                            const content = tokenIdContent(contentid, file);
                            const e = std.meta.stringToEnum(f.field_type, content) orelse
                                return parser.fail("invalid value '{s}' for enum type '{s}'", .{ content, @typeName(f.field_type) }, contentid, file);
                            options.set(fe, e);
                            return true;
                        },

                        else => if (comptime std.meta.trait.isZigString(f.field_type)) {
                            const content = tokenIdContent(contentid, file);
                            // trim leading/trailing quotes
                            const content_trimmed = if (content.len > 1 and content[0] == '"' and content[content.len - 1] == '"')
                                content[1 .. content.len - 1]
                            else
                                content;
                            options.set(fe, content_trimmed);
                            return true;
                        } else {
                            return parser.fail("TODO: option '{s}' handle type {s} or parse as uninterpreted_option", .{ optname, @tagName(info) }, nameid, file);
                        },
                    }
                }
            } else {
                // var uo = option.uninterpreted_option.addOne(parser.arena);
                // option.setPresent(.uninterpreted_option);
                return parser.fail("TODO parse uninterpreted_option {s}", .{optname}, nameid, file);
            }
            return false;
        }

        fn findTypenameInner(parser: *Self, typename: []const u8, it: anytype, parent: anytype) Allocator.Error!bool {
            // std.debug.print("findTypenameInner typename {s} it.name {s} parser.tmp_buf {s}\n", .{ typename, it.name, parser.tmp_buf.items });
            if (std.mem.eql(u8, it.name, typename)) return true;
            if (std.mem.startsWith(u8, typename, parent.package)) {
                const rest = typename[parent.package.len..];
                if (rest.len > 0 and rest[0] == '.') {
                    if (std.mem.eql(u8, rest[1..], it.name)) return true;
                }
            }
            // FIXME this is incomplete and will only match singly nested
            //       typename such as 'Struct.FieldEntry'
            const parent_name = parser.tmp_buf.items;
            if (std.mem.startsWith(u8, typename, parent_name)) {
                const rest = typename[parent_name.len..];
                if (rest.len > 0 and rest[0] == '.') {
                    return parser.findTypenameInner(rest[1..], it, parent);
                }
            }
            return false;
        }

        fn findTypename(parser: *Self, typename_: []const u8, _: *DescriptorProto) !?FieldDescriptorProto.Type {
            // std.debug.print("findTypename typename_ {s} parent.name {s} \n", .{ typename_, parent.name });

            if (typename_.len == 0) return null;
            parser.tmp_buf.items.len = 0;
            const absolute_path = typename_[0] == '.';
            // std.debug.print("typename_ {s}\n", .{typename_});
            if (absolute_path) {
                const typename = typename_[1..];

                for (parser.root_file.descriptor.enum_type.items) |it|
                    if (try parser.findTypenameInner(typename, it, parser.root_file.descriptor))
                        return .TYPE_ENUM;

                for (parser.root_file.descriptor.message_type.items) |it| {
                    if (try parser.findTypenameInner(typename, it, parser.root_file.descriptor))
                        return .TYPE_MESSAGE;
                    try parser.tmp_buf.ensureTotalCapacity(parser.arena, it.name.len);
                    parser.tmp_buf.items.len = it.name.len;
                    std.mem.copy(u8, parser.tmp_buf.items, it.name);
                    for (it.nested_type.items) |nit| {
                        if (try parser.findTypenameInner(typename, nit, parser.root_file.descriptor))
                            return .TYPE_MESSAGE;
                    }
                }
            } else {
                // TODO !absolute_path
            }
            return null;
        }

        // fixup field types set to .TYPE_ERROR which couldn't be resolved
        fn fixupFieldTypes(p: *Self, typename: []const u8, scoped_field: ScopedField) Error!void {
            var mty = findTypenameScoped(typename, scoped_field.scope);
            if (mty == null) {
                var depsiter = p.deps_map.iterator();
                while (depsiter.next()) |dep| {
                    if (findTypenameScoped(typename, &dep.value_ptr.*.scope)) |ty| {
                        mty = ty;
                        break;
                    }
                }
            }
            if (mty) |ty| {
                scoped_field.field.set(.type, ty);
            } else
            // TODO pos
            return p.fail("invalid type name '{s}'", .{typename}, 0, scoped_field.scope.file);
        }

        /// searches include paths for an imported file path and
        /// adds it to file.descriptor.dependency and parser.deps_map if not already present
        fn resolveImport(parser: *Self, filename_tokid: TokenIndex, file: *File) !void {
            const filename = tokenIdContent(filename_tokid, file);
            const filename_trimmed = filename[1 .. filename.len - 1];
            var realpath: []const u8 = &.{};
            var buf0: [std.fs.MAX_PATH_BYTES]u8 = undefined;
            const f = std.fs.cwd().openFile(filename_trimmed, .{}) catch |err| switch (err) {
                // check include paths if not found
                error.FileNotFound => blk: {
                    for (parser.include_paths) |path| {
                        var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
                        var fba = std.heap.FixedBufferAllocator.init(&buf);
                        const path_full = try std.fs.path.join(fba.allocator(), &.{ path, filename_trimmed });
                        if (std.fs.cwd().openFile(path_full, .{})) |f| {
                            realpath = try std.fs.cwd().realpath(path_full, &buf0);
                            break :blk f;
                        } else |_| continue;
                    } else return parser.fail("file '{s}' not found.  checked {} include path.\n", .{ filename_trimmed, parser.include_paths.len }, filename_tokid, file);
                },
                else => return err,
            };
            defer f.close();

            if (realpath.len == 0)
                return parser.fail("import file not found {s}", .{filename}, filename_tokid, file);

            var gop = try parser.deps_map.getOrPut(parser.arena, filename_trimmed);

            if (!gop.found_existing) {
                const new_file = try parser.arena.create(File);
                new_file.* = File.init(
                    try f.readToEndAllocOptions(parser.arena, std.math.maxInt(u32), null, 1, 0),
                    try parser.arena.dupeZ(u8, realpath),
                    undefined, // file.descriptor is undefined. will be set later in parseFile
                );
                file.descriptor.setPresent(.dependency);
                try file.descriptor.dependency.append(parser.arena, filename_trimmed);
                try parser.deps_map.put(parser.arena, filename_trimmed, new_file);
                gop.value_ptr.* = new_file;
            } else {
                // assert(gop.value_ptr.name == .import);
                todo("nothing? can likely remove this just leaving it in as a reminder\n", .{});
            }
        }

        fn addToLocation(allocator: Allocator, location: *SourceCodeInfo.Location, source_code_info: *SourceCodeInfo, start_tok: Token) !void {
            // TODO
            // location.span
            // Always has exactly three or four elements: start line, start column,
            // end line (optional, otherwise assumed same as start line), end column.
            // These are packed into a single field for efficiency.  Note that line
            // and column numbers are zero-based -- typically you will want to add
            // 1 to each before displaying to a user.
            if (false) {
                try location.span.appendSlice(allocator, &.{
                    start_tok.line_col_start.line,
                    start_tok.line_col_start.col,
                    start_tok.line_col_end.line,
                    start_tok.line_col_end.col,
                });

                location.setPresent(.span);
                source_code_info.setPresent(.location);
            }
        }

        fn parseBool(parser: *Self, start: TokenIndex, file: *File) !bool {
            const str = tokenIdContent(start, file);
            const val = if (std.mem.eql(u8, str, "true"))
                true
            else if (std.mem.eql(u8, str, "false"))
                false
            else
                return parser.fail("invalid boolean value '{s}'", .{str}, start, file);
            return val;
        }

        fn parseEnum(
            parser: *Self,
            start: TokenIndex,
            file: *File,
            parent_list: *std.ArrayListUnmanaged(EnumDescriptorProto),
            source_code_info: *SourceCodeInfo,
        ) Error!void {
            var enum_node = try parent_list.addOne(parser.arena);
            enum_node.* = .{};
            file.descriptor.setPresent(.enum_type);

            const name = try parser.expectToken(.identifier, file);
            enum_node.set(.name, tokenIdContent(name, file));
            var location: SourceCodeInfo.Location = .{};
            try addToLocation(parser.arena, &location, source_code_info, file.token_it.tokens[start]);
            _ = try parser.expectToken(.l_brace, file);

            while (true) {
                const pos = file.token_it.pos;
                const token = file.token_it.next();

                switch (token.id) {
                    .identifier => {
                        const name_pos = pos;
                        _ = try parser.expectToken(.equal, file);
                        const field_value = try parser.expectToken(.int_literal, file);
                        _ = try parser.expectToken(.semicolon, file);
                        // for proto3, verify that the first field has value 0
                        if (file.syntax == .proto3 and enum_node.value.items.len == 0) {
                            const val_str = tokenIdContent(field_value, file);
                            const val = try std.fmt.parseInt(i32, val_str, 10);
                            if (val != 0) return parser.fail("proto3, the first enum field must have value 0. found {s}", .{val_str}, field_value, file);
                        }
                        const field_name = tokenIdContent(name_pos, file);
                        const number = try std.fmt.parseInt(i32, tokenIdContent(field_value, file), 10);
                        enum_node.setPresent(.value);
                        var value: EnumValueDescriptorProto = .{};
                        value.set(.name, field_name);
                        value.set(.number, number);
                        try enum_node.value.append(parser.arena, value);
                    },
                    .r_brace => break,
                    .keyword_option => {
                        const optionid = try parser.expectToken(.identifier, file);
                        _ = try parser.expectToken(.equal, file);
                        const optionval_id = try parser.expectTokenIn(&.{ .string_literal, .int_literal, .identifier }, file);
                        _ = try parser.expectToken(.semicolon, file);
                        const option = tokenIdContent(optionid, file);
                        var options = try parser.arena.create(descriptor.EnumOptions);
                        options.* = .{};
                        if (std.mem.eql(u8, "allow_alias", option)) {
                            options.set(.allow_alias, try parser.parseBool(optionval_id, file));
                        } else if (std.mem.eql(u8, "deprecated", option)) {
                            options.set(.deprecated, try parser.parseBool(optionval_id, file));
                        } else {
                            // try enumoption.uninterpreted_option.append(parser.arena, .{});
                            return parser.fail("TODO parse uninterpreted_option", .{}, pos, file);
                        }
                        enum_node.set(.options, options);
                    },

                    else => return parser.fail("unexpected token: {}", .{token.id}, pos, file),
                }
            }

            try source_code_info.location.append(parser.arena, location);
        }

        fn parseMessage(
            parser: *Self,
            start: TokenIndex,
            file: *File,
            parent_list: *std.ArrayListUnmanaged(DescriptorProto),
            source_code_info: *SourceCodeInfo,
            parent_scope: *const Scope,
        ) Error!void {
            var message_node = try parent_list.addOne(parser.arena);
            message_node.* = .{};

            const name = try parser.expectToken(.identifier, file);
            message_node.set(.name, tokenIdContent(name, file));
            var location: descriptor.SourceCodeInfo.Location = .{};
            try addToLocation(parser.arena, &location, source_code_info, file.token_it.tokens[start]);

            _ = try parser.expectToken(.l_brace, file);
            const scope = try parser.arena.create(Scope);
            scope.* = Scope.init(parent_scope, file, .{ .message = message_node });

            while (true) {
                const pos = file.token_it.pos;
                const token = file.token_it.next();
                switch (token.id) {
                    .identifier, .identifier_dotted, .keyword_repeated, .keyword_optional, .keyword_required, .keyword_map => {
                        // var field: FieldDescriptorProto = .{};
                        var field = try message_node.field.addOne(parser.arena);
                        field.* = .{};
                        try parser.parseField(field, pos, token, file, message_node, scope);
                        message_node.setPresent(.field);
                        // // honor syntax
                        // //   proto2: field label is required
                        // //   proto3: fields default to optional, required not allowed
                        // if (file.syntax == .proto3) {
                        //     if (field.labels.count() == 0) {
                        //         field.labels.insert(.optional);
                        //     } else if (field.labels.contains(.required)) {
                        //         return parser.fail("required fields are not allowed in proto3", .{}, field.tokens[0], file);
                        //     }
                        // } else if (file.syntax == .proto2 and field.labels.count() == 0) {
                        //     return parser.fail("missing field label. proto2 syntax requires all fields have a label preceding the name - either 'optional', 'required' or 'repeated'", .{}, field.tokens[0], file);
                        // }

                        // try message_node.fields.append(parser.arena, .{ .f = field });
                    },
                    .r_brace => {
                        // message_node.loc.end = pos;
                        break;
                    },
                    .keyword_enum => {
                        try parser.parseEnum(
                            pos,
                            file,
                            &message_node.enum_type,
                            source_code_info,
                        );
                    },
                    .keyword_message => {
                        try parser.parseMessage(
                            pos,
                            file,
                            &message_node.nested_type,
                            source_code_info,
                            scope,
                        );
                        message_node.setPresent(.nested_type);
                    },
                    .keyword_oneof => {
                        const oneof_id = message_node.oneof_decl.items.len;
                        const oneof = try message_node.oneof_decl.addOne(parser.arena);
                        oneof.* = .{};
                        message_node.setPresent(.oneof_decl);
                        const nameid = try parser.expectToken(.identifier, file);
                        oneof.set(.name, tokenIdContent(nameid, file));
                        _ = try parser.expectToken(.l_brace, file);
                        while (true) {
                            // var field: MessageNode.Field = .{ .tokens = undefined };
                            var field = try message_node.field.addOne(parser.arena);
                            field.* = .{};
                            const fieldpos = file.token_it.pos;
                            try parser.parseField(field, fieldpos, file.token_it.next(), file, message_node, scope);
                            field.set(.oneof_index, @intCast(i32, oneof_id));
                            message_node.setPresent(.field);

                            // TODO proto3 - verify field type not map
                            if (file.syntax == .proto3) {
                                if (field.label == .LABEL_REPEATED) {
                                    return parser.fail("repeated oneof fields are not allowed in proto3", .{}, fieldpos, file);
                                }
                            }

                            if (consumeToken(.r_brace, file)) |_| break;
                        }
                    },

                    else => return parser.fail("unexpected token: {}", .{token.id}, pos, file),
                }
            }
        }

        fn parseProtoFieldType(parser: *Self, typename: []const u8) !?FieldDescriptorProto.Type {
            const prefix = "TYPE_";
            const len = prefix.len + typename.len;
            try parser.tmp_buf.ensureTotalCapacity(parser.arena, len);
            parser.tmp_buf.items.len = len;
            std.mem.copy(u8, parser.tmp_buf.items, prefix);
            const rest = parser.tmp_buf.items[prefix.len..];
            _ = std.ascii.upperString(rest, typename);
            return std.meta.stringToEnum(FieldDescriptorProto.Type, parser.tmp_buf.items);
        }

        fn parseField(
            parser: *Self,
            field: *FieldDescriptorProto,
            pos: TokenIndex,
            token: Token,
            file: *File,
            parent_message: *DescriptorProto,
            scope: *const Scope,
        ) Error!void {
            var typenameid = pos;

            if (file.syntax == .proto3) field.set(.label, .LABEL_OPTIONAL);
            blk: {
                switch (token.id) {
                    .keyword_repeated => field.set(.label, .LABEL_REPEATED),
                    .keyword_optional => field.set(.label, .LABEL_OPTIONAL),
                    .keyword_required => field.set(.label, .LABEL_REQUIRED),
                    else => break :blk,
                }
                typenameid = file.token_it.pos;
                _ = file.token_it.next();
            }
            const typename = tokenIdContent(typenameid, file);
            if (try parser.parseProtoFieldType(typename)) |ty|
                field.set(.type, ty)
            else {
                // const field_tyname = try std.fmt.allocPrint(parser.arena, ".{s}", .{typename});
                field.set(.type_name, typename);
            }

            if (token.id == .keyword_map) {
                _ = try parser.expectToken(.lt, file);
                const keytid = try parser.expectTokenIn(&.{ .identifier, .identifier_dotted }, file);
                _ = try parser.expectToken(.comma, file);
                const valtid = try parser.expectTokenIn(&.{ .identifier, .identifier_dotted }, file);
                _ = try parser.expectToken(.gt, file);
                field.set(.label, .LABEL_REPEATED);
                field.set(.type, .TYPE_ERROR);
                const keytyname = tokenIdContent(keytid, file);
                const keyty = if (try parser.parseProtoFieldType(keytyname)) |ty|
                    ty
                else
                    return parser.fail("invalid key type '{s}'", .{keytyname}, keytid, file);
                const valtyname = tokenIdContent(valtid, file);
                const valty = try parser.parseProtoFieldType(valtyname);
                const valtyname0 = if (valty) |ty| @tagName(ty)[5..] else valtyname;
                const mapent_tyname = try std.fmt.allocPrint(parser.arena, "Map{s}{s}Entry", .{ @tagName(keyty)[5..], valtyname0 });
                const field_tyname = try std.fmt.allocPrint(parser.arena, ".{s}.{s}", .{ parent_message.name, mapent_tyname });
                field.set(.type_name, field_tyname);

                // create the nested_type entry
                const map_type = try parent_message.nested_type.addOne(parser.arena);
                map_type.* = .{};
                map_type.set(.name, mapent_tyname);
                map_type.setPresent(.field);
                const options = try parser.arena.create(descriptor.MessageOptions);
                options.* = .{};
                options.set(.map_entry, true);
                map_type.set(.options, options);

                // create nested_type.key field
                const kfield = try map_type.field.addOne(parser.arena);
                kfield.* = .{};
                kfield.set(.name, "key");
                kfield.set(.json_name, "key");
                kfield.set(.number, 1);
                kfield.set(.label, .LABEL_OPTIONAL);
                kfield.set(.type, keyty);

                // create nested_type.value field
                const vfield = try map_type.field.addOne(parser.arena);
                vfield.* = .{};
                vfield.set(.name, "value");
                vfield.set(.json_name, "value");
                vfield.set(.number, 2);
                vfield.set(.label, .LABEL_OPTIONAL);

                if (valty) |ty| {
                    vfield.set(.type, ty);
                } else {
                    const mty = parser.findTypename(valtyname, parent_message) catch null;
                    const ty = if (mty) |ty|
                        ty
                    else ty: {
                        try parser.unresolved_types.put(parser.arena, valtyname, .{ .scope = scope, .field = field });
                        break :ty .TYPE_ERROR;
                    };
                    vfield.set(.type, ty);
                    vfield.set(.type_name, valtyname);
                }
                parent_message.setPresent(.nested_type);
            }

            // TODO save location
            // TODO handle other tokens
            // const nameid = try parser.expectTokenIn(&.{ .identifier, .keyword_package, .keyword_syntax }, file);
            const nameid = try parser.expectToken(.identifier, file);
            const name = tokenIdContent(nameid, file);
            field.set(.name, name);
            field.set(.json_name, name);

            _ = try parser.expectToken(.equal, file);
            // TODO save location
            const numid = try parser.expectToken(.int_literal, file);
            field.set(.number, try std.fmt.parseInt(i32, tokenIdContent(numid, file), 10));
            if (consumeToken(.l_sbrace, file)) |_| { // field options: ie [default=true]
                // save field options like default/deprecated/packed/json_name
                // TODO: [packed = true] can only be specified for repeated primitive fields
                // const option = try field.options.addOne(parser.arena);
                // TODO save option data/location
                const optnameid = try parser.expectToken(.identifier, file);
                _ = try parser.expectToken(.equal, file);
                // TODO save option data/location
                const optvalid = try parser.expectTokenIn(&.{.identifier}, file);
                _ = try parser.expectToken(.r_sbrace, file);

                const options = if (field.options) |o| o else blk: {
                    const o = try parser.arena.create(descriptor.FieldOptions);
                    o.* = .{};
                    break :blk o;
                };

                const optname = tokenIdContent(optnameid, file);
                const matched = try parser.parseOptions(
                    descriptor.FieldOptions,
                    descriptor.FieldOptions.FieldOptionsFieldEnum,
                    optname,
                    nameid,
                    options,
                    optvalid,
                    file,
                );

                if (!matched)
                    return parser.fail("failed to match field option {s}", .{optname}, nameid, file);

                field.set(.options, options);
            }
            _ = try parser.expectToken(.semicolon, file);
        }

        // fn parseRanges(parser: *Self, range_list: *RangeList, file: *File) Error!void {
        //     while (true) {
        //         const range = try range_list.addOne(parser.arena);
        //         range.end = null;
        //         errdefer range_list.items.len -= 1;
        //         range.start = try parser.expectToken(.int_literal, file);
        //         if (consumeTokenContent(.identifier, "to", file)) |_| {
        //             range.end = consumeToken(.int_literal, file) orelse
        //                 try parser.expectTokenContent(.identifier, "max", file);
        //         }
        //         if (consumeToken(.comma, file) == null) break;
        //     }
        // }

        fn consumeToken(id: Token.Id, file: *File) ?TokenIndex {
            const pos = file.token_it.pos;
            const token = file.token_it.peek() orelse return null;

            if (token.id == id) {
                _ = file.token_it.next();
                return pos;
            }
            return null;
        }

        fn consumeTokenContent(id: Token.Id, content: []const u8, file: *File) ?TokenIndex {
            const pos = file.token_it.pos;
            const token = file.token_it.peek() orelse return null;
            if (token.id == id) {
                const token_content = tokenContent(token, file);
                if (std.mem.eql(u8, content, token_content)) {
                    _ = file.token_it.next();
                    return pos;
                }
            }
            return null;
        }

        fn expectToken(parser: *Self, id: Token.Id, file: *File) Error!TokenIndex {
            const pos = file.token_it.pos;
            _ = file.token_it.peek() orelse return parser.fail("unexpected end of file", .{}, pos, file);
            const token = file.token_it.next();
            if (token.id == id) {
                return pos;
            } else {
                file.token_it.seekTo(pos);
                return parser.fail("unexpected token. expected {}, found {}", .{ id, token.id }, pos, file);
            }
        }

        fn expectTokenIn(parser: *Self, ids: []const Token.Id, file: *File) Error!TokenIndex {
            const pos = file.token_it.pos;
            _ = file.token_it.peek() orelse return parser.fail("unexpected end of file", .{}, pos, file);
            const token = file.token_it.next();
            if (std.mem.indexOfScalar(Token.Id, ids, token.id) != null) {
                return pos;
            } else {
                file.token_it.seekTo(pos);
                return parser.fail("unexpected token. expected one of {any}, found {}", .{ ids, token.id }, pos, file);
            }
        }

        fn expectTokenContent(parser: *Self, id: Token.Id, content: []const u8, file: *File) Error!TokenIndex {
            const pos = file.token_it.pos;
            _ = file.token_it.peek() orelse return parser.fail("unexpected end of file", .{}, pos, file);
            const token = file.token_it.next();
            if (token.id == id) {
                const token_content = tokenContent(token, file);
                if (std.mem.eql(u8, content, token_content))
                    return pos;
            }
            file.token_it.seekTo(pos);
            return parser.fail("unexpected token. expected {} with content '{s}', found {}", .{ id, content, token.id }, pos, file);
        }
    };
}
pub fn tokenContent(token: Token, file: *const File) []const u8 {
    return file.source.?[token.loc.start..token.loc.end];
}

pub fn tokenIdContent(token_id: TokenIndex, file: *const File) []const u8 {
    const tok = file.token_it.tokens[token_id];
    return file.source.?[tok.loc.start..tok.loc.end];
}
