const std = @import("std");
const types = @import("types.zig");
const util = @import("util.zig");
const lib = @import("lib.zig");
const decoding = @import("decoding.zig");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;
const Node = types.Scope.Node;
const descriptor = types.descriptor;
const plugin = types.plugin;
const CodeGeneratorRequest = plugin.CodeGeneratorRequest;
const FdType = descriptor.FieldDescriptorProto.Type;
const Error = types.Error;
const File = types.File;
const FileMap = types.FileMap;
const Descriptor = types.Descriptor;
const MessageDescriptor = types.MessageDescriptor;
const EnumDescriptor = types.EnumDescriptor;
const FieldDescriptor = types.FieldDescriptor;
const FileDescriptor = types.FileDescriptor;
const DescriptorMap = types.DescriptorMap;
const todo = util.todo;

pub fn init(allocator: Allocator, req: CodeGeneratorRequest, deps_map: FileMap, errwriter: anytype) Analysis(@TypeOf(errwriter)) {
    return .{
        .arena = allocator,
        .req = req,
        .deps_map = deps_map,
        .errwriter = errwriter,
    };
}

pub fn Analysis(comptime ErrWriter: type) type {
    return struct {
        arena: Allocator,
        req: CodeGeneratorRequest,
        deps_map: FileMap,
        descriptors: DescriptorMap = .{},
        errwriter: ErrWriter,

        const Self = @This();
        pub const Match = union(enum) { full, partial: []const u8, none };

        fn matchTypename(
            typename: []const u8,
            node: Node,
            pkg: []const u8,
            ty: FdType,
            path: []const u8,
        ) ?NodeAndType {
            const name = node.name();
            std.log.debug("matchTypename({s}) name {s} pkg {s}", .{ typename, name, pkg });
            const match: Match = if (typename.len == 0) .full else if (std.mem.endsWith(u8, name, typename)) blk: {
                var rest = name[0 .. name.len - typename.len];
                if (rest.len == 0) break :blk .full;
                if (rest[0] == '.' and std.mem.eql(u8, rest[1..], pkg)) break :blk .full;
                std.log.debug("rest {s}", .{rest});
                break :blk .{ .partial = rest };
            } else if (std.mem.endsWith(u8, typename, name)) blk: {
                var rest = typename[0 .. typename.len - name.len - 1];
                std.log.debug("rest2 {s}", .{rest});
                if (rest.len == 0) break :blk .full;
                if (rest.len == pkg.len + 2 and rest[0] == '.' and
                    std.mem.eql(u8, rest[1..], pkg))
                    break :blk .full;
                break :blk .{ .partial = rest[1..] };
            } else .none;

            switch (match) {
                .full => return NodeAndType.init(ty, node),
                .none => {},
                .partial => |part| {
                    // this allows for matching nested local typenames such as:
                    //  message A {
                    //      message B {}
                    //      B b = 0;
                    //  }
                    std.log.debug("  part '{s}' path '{s}'", .{ part, path });
                    if (std.mem.eql(
                        u8,
                        std.mem.trim(u8, path, "."),
                        std.mem.trim(u8, part, "."),
                    ))
                        return NodeAndType.init(ty, node);
                },
            }
            return null;
        }

        fn findTypenameNode(
            a: *Self,
            typename: []const u8,
            node: Node,
            pkg: []const u8,
            path: []const u8,
        ) ?NodeAndType {
            std.log.debug("findTypenameNode({s}, .{s} = {s}) path {s}", .{ typename, @tagName(node), node.name(), path });

            blk: {
                const ty: FdType = switch (node) {
                    .message => .TYPE_MESSAGE,
                    .enum_ => .TYPE_ENUM,
                    .file => break :blk,
                };
                if (matchTypename(typename, node, pkg, ty, path)) |nt|
                    return nt;
            }

            switch (node) {
                .file => |fd| {
                    {
                        std.log.debug("  file.enum_types ", .{});
                        var iter = fd.enum_type.iterator(0);
                        while (iter.next()) |it| {
                            const node2 = Node.init(.enum_, it);
                            if (a.findTypenameNode(typename, node2, pkg, path)) |nt|
                                return nt;
                        }
                    }
                    {
                        std.log.debug("  file.message_types ", .{});
                        var iter = fd.message_type.iterator(0);
                        while (iter.next()) |it| {
                            const node2 = Node.init(.message, it);
                            if (a.findTypenameNode(typename, node2, pkg, path)) |nt|
                                return nt;
                            const typenameadj = if (std.mem.startsWith(u8, typename, it.name))
                                typename[it.name.len..]
                            else
                                typename;
                            if (a.findTypenameNode(typenameadj, node2, pkg, path)) |nt|
                                return nt;
                        }
                    }
                },
                .message => |m| {
                    {
                        var iter = m.enum_type.iterator(0);
                        while (iter.next()) |it| {
                            const node2 = Node.init(.enum_, it);
                            if (matchTypename(typename, node2, pkg, .TYPE_ENUM, path)) |nt|
                                return nt;
                        }
                    }
                    {
                        var iter = m.nested_type.iterator(0);
                        while (iter.next()) |it| {
                            const node2 = Node.init(.message, it);
                            if (a.findTypenameNode(typename, node2, pkg, m.name)) |nt|
                                return nt;
                        }
                    }
                },
                .enum_ => if (matchTypename(typename, node, pkg, .TYPE_ENUM, path)) |nt|
                    return nt,
            }
            return null;
        }

        pub const NodeAndType = struct {
            ty: FdType,
            node: Node,
            pub fn init(ty: FdType, node: Node) NodeAndType {
                return .{ .ty = ty, .node = node };
            }
        };

        pub fn findTypenameAbsolute(
            a: *Self,
            typename: []const u8,
        ) !?NodeAndType {
            std.log.debug("findTypenameAbsolute({s})", .{typename});
            std.debug.assert(typename.len > 0 and typename[0] == '.');
            var depsiter = a.deps_map.iterator();
            while (depsiter.next()) |ent| {
                // const name = ent.key_ptr.*;
                const file = ent.value_ptr.*;

                const node = Node.init(.file, file.descriptor);

                if (a.findTypenameNode(typename, node, file.descriptor.package, file.descriptor.package)) |nt|
                    return nt;
            }
            return null;
        }

        fn findTypename(
            a: *Self,
            typename: []const u8,
            file: *File,
        ) !?FdType {
            std.log.debug("findTypename({s}) ", .{typename});

            if (typename.len == 0) return null;
            const is_absolute_path = typename[0] == '.';
            if (is_absolute_path) {
                const mnode_ty = try a.findTypenameAbsolute(typename);
                std.log.debug("findTypename({s}) found {}", .{ typename, mnode_ty != null });
                if (mnode_ty) |node_ty|
                    return node_ty.ty;
            } else {
                return a.fail("internal error: unexpected non-absolute typename '{s}'", .{typename}, 0, file);
            }
            return null;
        }

        // const DescriptorAndType = struct { descriptor: Descriptor, ty: FdType };
        // pub fn findTypenameAbsoluteDescriptor(
        //     a: *Self,
        //     typename: []const u8,
        // ) !?DescriptorAndType {
        //     std.log.debug("findTypenameAbsoluteDescriptor({s})", .{typename});
        //     std.debug.assert(typename.len > 0 and typename[0] == '.');
        //     var depsiter = a.descriptors.iterator();
        //     while (depsiter.next()) |ent| {
        //         const name = ent.key_ptr.*;
        //         const fdescr = ent.value_ptr.*;
        //         const file = a.deps_map.get(name).?;

        //         if (a.findTypenameDesc(typename, fdescr.*, file.descriptor.package, file.descriptor.package)) |nt|
        //             return nt;
        //     }
        //     return null;
        // }

        // fn matchTypenameDesc(
        //     typename: []const u8,
        //     desc: Descriptor,
        //     pkg: []const u8,
        //     ty: FdType,
        //     path: []const u8,
        // ) ?DescriptorAndType {
        //     const name = desc.name();
        //     std.log.debug("matchTypenameDesc({s}) name {s} pkg {s}", .{ typename, name, pkg });
        //     const match: Match = if (typename.len == 0)
        //         .full
        //     else if (std.mem.endsWith(u8, name, typename)) blk: {
        //         var rest = name[0 .. name.len - typename.len];
        //         if (rest.len == 0) break :blk .full;
        //         if (rest[0] == '.' and std.mem.eql(u8, rest[1..], pkg)) break :blk .full;
        //         std.log.debug("rest {s}", .{rest});
        //         break :blk .{ .partial = rest };
        //     } else if (std.mem.endsWith(u8, typename, name)) blk: {
        //         var rest = typename[0 .. typename.len - name.len - 1];
        //         std.log.debug("rest2 {s}", .{rest});
        //         if (rest.len == 0) break :blk .full;
        //         if (rest.len == pkg.len + 2 and rest[0] == '.' and
        //             std.mem.eql(u8, rest[1..], pkg))
        //             break :blk .full;
        //         break :blk .{ .partial = rest[1..] };
        //     } else .none;

        //     switch (match) {
        //         .full => return .{ .descriptor = desc, .ty = ty },
        //         .none => {},
        //         .partial => |part| {
        //             // this allows for matching nested local typenames such as:
        //             //  message A {
        //             //      message B {}
        //             //      B b = 0;
        //             //  }
        //             std.log.debug("  part '{s}' path '{s}'", .{ part, path });
        //             if (std.mem.eql(
        //                 u8,
        //                 std.mem.trim(u8, path, "."),
        //                 std.mem.trim(u8, part, "."),
        //             ))
        //                 return .{ .descriptor = desc, .ty = ty };
        //         },
        //     }
        //     return null;
        // }

        // fn findTypenameDesc(
        //     a: *Self,
        //     typename: []const u8,
        //     desc: Descriptor,
        //     pkg: []const u8,
        //     path: []const u8,
        // ) ?DescriptorAndType {
        //     std.log.debug("findTypenameDesc({s}, .{s} = {s}) path {s}", .{ typename, @tagName(desc), desc.name(), path });
        //     blk: {
        //         const ty: FdType = switch (desc) {
        //             .message => .TYPE_MESSAGE,
        //             .enum_ => .TYPE_ENUM,
        //             .file => break :blk,
        //         };
        //         if (matchTypenameDesc(typename, desc, pkg, ty, path)) |nt|
        //             return nt;
        //     }

        //     switch (desc) {
        //         .file => |fd| {
        //             std.log.debug("  file.enum_types ", .{});
        //             for (fd.enum_type.items) |*it| {
        //                 if (a.findTypenameDesc(typename, .{ .enum_ = it }, pkg, path)) |nt|
        //                     return nt;
        //             }

        //             std.log.debug("  file.message_types ", .{});
        //             for (fd.message_type.items) |*it| {
        //                 if (a.findTypenameDesc(typename, .{ .message = it }, pkg, path)) |nt|
        //                     return nt;
        //                 const typenameadj = if (std.mem.startsWith(u8, typename, it.name))
        //                     typename[it.name.len..]
        //                 else
        //                     typename;
        //                 if (a.findTypenameDesc(typenameadj, .{ .message = it }, pkg, path)) |nt|
        //                     return nt;
        //             }
        //         },
        //         .message => |m| {
        //             for (m.enum_type.items) |*it| {
        //                 if (matchTypenameDesc(typename, .{ .enum_ = it }, pkg, .TYPE_ENUM, path)) |nt|
        //                     return nt;
        //             }
        //             for (m.nested_type.items) |*it| {
        //                 if (a.findTypenameDesc(typename, .{ .message = it }, pkg, m.name)) |nt|
        //                     return nt;
        //             }
        //         },
        //         .enum_ => if (matchTypenameDesc(typename, desc, pkg, .TYPE_ENUM, path)) |nt|
        //             return nt,
        //     }
        //     return null;
        // }

        // fixup non-sclar field types set to .TYPE_ERROR which aren't resolved
        pub fn resolveFieldTypes(a: *Self) Error!void {
            var depsiter = a.deps_map.iterator();
            while (depsiter.next()) |ent| {
                const name = ent.key_ptr.*;
                std.log.debug("resolveFieldTypes file.name '{s}'", .{name});
                const file = ent.value_ptr.*;
                const fdescr = try a.arena.create(FileDescriptor);
                fdescr.* = .{ .name = name, .package = file.descriptor.package };
                const descr = try a.arena.create(Descriptor);
                try a.descriptors.put(a.arena, name, descr);
                descr.* = Descriptor.init(.file, fdescr);
                try a.resolveFieldTypesInner(Node.init(.file, file.descriptor), descr.*, file);
            }
        }

        fn resolveFieldTypesInner(a: *Self, node: Node, descr: Descriptor, file: *File) Error!void {
            // TODO pos
            std.log.debug("resolveFieldTypesInner .{s} node.name {s}", .{ @tagName(node), node.name() });
            switch (node) {
                .file => |fd| {
                    var miter = fd.message_type.iterator(0);
                    while (miter.next()) |message| {
                        const mdescr = try descr.payload.file.message_type.addOne(a.arena);
                        mdescr.* = .{ .name = message.name };
                        try a.resolveFieldTypesInner(Node.init(.message, message), Descriptor.init(.message, mdescr), file);
                    }
                    var eiter = fd.enum_type.iterator(0);
                    while (eiter.next()) |enm| {
                        const edescr = try descr.payload.file.enum_type.addOne(a.arena);
                        edescr.* = .{ .name = enm.name };
                        try a.resolveFieldTypesInner(Node.init(.enum_, enm), Descriptor.init(.enum_, edescr), file);
                    }
                },
                .message => |m| {
                    for (m.field.items) |*field| {
                        if (field.has(.type)) continue;
                        std.log.debug("", .{});
                        std.log.debug("", .{});
                        std.log.debug("field '{s}' with unresolved type '{s}'", .{ field.name, field.type_name });
                        if ((!field.has(.type_name) or field.type_name.len == 0))
                            return a.fail("missing type name '{s}' for field '{s}'", .{ field.type_name, field.name }, 0, file);
                        const descty = try a.findTypenameAbsolute(field.type_name) orelse
                            return a.fail("type name '{s}' not found for field '{s}'", .{ field.type_name, field.name }, 0, file);
                        if (!(descty.ty == .TYPE_MESSAGE or descty.ty == .TYPE_ENUM))
                            return a.fail("internal error: unexpected type {s} for field '{s}'", .{ @tagName(descty.ty), field.name }, 0, file);
                        field.set(.type, descty.ty);

                        const descfield = try descr.payload.message.fields.addOne(a.arena);
                        var flags: FieldDescriptor.Flags = .{};
                        if (field.has(.oneof_index)) flags.insert(.oneof);
                        if (field.options) |opts| flags.setPresent(.packt, opts.packed_);

                        descfield.* = .{
                            .name = field.name,
                            .id = field.number,
                            .label = field.label,
                            .type = field.type,
                            // TODO offset
                            .offset = 0,
                            // TODO descriptor
                            .descriptor = null,
                            .flags = flags,
                        };
                    }
                    {
                        var miter = m.nested_type.iterator(0);
                        while (miter.next()) |nested| {
                            const mdescr = try descr.payload.message.nested_type.addOne(a.arena);
                            mdescr.* = .{ .name = nested.name };
                            try a.resolveFieldTypesInner(Node.init(.message, nested), Descriptor.init(.message, mdescr), file);
                        }
                    }
                },
                .enum_ => {},
            }
        }

        fn fail(a: *Self, comptime format: []const u8, args: anytype, token_idx: u32, file: *File) Error {
            // TODO
            try lib.writeErr(.{
                .msg = try std.fmt.allocPrint(a.arena, format ++ "\n", args),
                .token = file.token_it.tokens[token_idx],
                .file = file,
            }, a.errwriter);
            // try a.errwriter.print(format, args);
            return error.ParseFail;
        }
    };
}
