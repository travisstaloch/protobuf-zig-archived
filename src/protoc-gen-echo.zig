const std = @import("std");
const io = std.io;

pub fn main() !void {
    const stdin = io.getStdIn().reader();
    const stderr = io.getStdErr().writer();
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allr = arena.allocator();
    const input = try stdin.readAllAlloc(allr, std.math.maxInt(u32));
    _ = try stderr.writeAll(input);
}
