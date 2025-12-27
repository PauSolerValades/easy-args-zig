const std = @import("std");
const eaz = @import("easy_args_zig");
const Arg = eaz.Arg;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const definitions = .{
        Arg(u32, "limit", "Limits are meant to be broken"),
        Arg(bool, "verbose", "print a little, or print a lot"),
        Arg([]const u8, "username", "who are you dear?"), // Added a string to prove it works
    };
    const config = eaz.parseArgs(allocator, definitions) catch |err| {
        std.debug.print("Failed to parse args: {any}\n", .{err});
        return;
    };
    
    // ------- Proofs of this thing is actually working you know
    // it's actually a new struct type
    const T = @TypeOf(config);
    std.debug.print("\n--- Who is this struct? ---\n", .{});
    std.debug.print("Type Name: {s}\n", .{@typeName(T)});
    
    // proof of memory layout
    std.debug.print("Size: {d} bytes\n", .{@sizeOf(T)});
    std.debug.print("Limit offset: {d}\n", .{@offsetOf(T, "limit")});
    std.debug.print("Verbose offset: {d}\n", .{@offsetOf(T, "verbose")});
    
    // proof of names actually being in there
    const typeInfo = @typeInfo(T);
    std.debug.print("\n--- Field Inspection ---\n", .{});
    inline for (typeInfo.@"struct".fields) |f| {
       std.debug.print("Field '{s}' is type: {s}\n", .{ f.name, @typeName(f.type) });
    }

    // struct access
    std.debug.print("\n--- Result ---\n", .{});
    std.debug.print("Limit:    {d}\n", .{config.limit});
    std.debug.print("Verbose:  {any}\n", .{config.verbose});
    std.debug.print("Username: {s}\n", .{config.username});

}

