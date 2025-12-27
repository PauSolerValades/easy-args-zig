const std = @import("std");
const Allocator = std.mem.Allocator;

/// Creates the Argument Structure
/// name uses [:0] to avoid the \0 string
pub fn Arg(comptime T: type, comptime name: [:0]const u8, comptime description: []const u8) type {
    return struct {
        pub const type_id = T;
        pub const field_name = name;
        pub const help = description;
    };
}

fn GeneratedStruct(comptime args_tuple: anytype) type {
    const len = args_tuple.len;
    
    var names: [len][]const u8 = undefined;
    var types: [len]type = undefined;
    
    // fill the attributes
    var attrs: [len]std.builtin.Type.StructField.Attributes = undefined;

    inline for (args_tuple, 0..) |arg, i| {
        names[i] = arg.field_name;
        types[i] = arg.type_id;
        
        attrs[i] = .{
            .default_value_ptr = null,  // no fucking clue
            .@"comptime" = false,       // save it when compiled (user will be able to use it) 
            .@"align" = null,           // natural alignment
        };
    }
    
    // return an Struct with the data you've specified
    return @Struct(.auto, null, &names, &types, &attrs);
}

fn printUsage(comptime args_def: anytype) void {

    std.debug.print("Usage: app", .{});
    inline for (args_def) |arg| {
        std.debug.print(" <{s}>", .{arg.field_name});
    }
    std.debug.print("\n\nArguments:\n", .{});

    inline for (args_def) |arg| {
        const type_name = @typeName(arg.type_id);
        
        std.debug.print("  {s:<10} ({s}): {s}\n", .{
            arg.field_name, 
            type_name, 
            arg.help
        });
    }
    std.debug.print("\n", .{});
}

pub fn parseArgs(allocator: Allocator, comptime args_def: anytype) !GeneratedStruct(args_def) {
    const ResultType = GeneratedStruct(args_def);
    var result: ResultType = undefined;

    var args_iter = try std.process.argsWithAllocator(allocator);
    defer args_iter.deinit();

    _ = args_iter.skip(); 

    // THE ZIPPER: Iterate fields (Comptime) + consume args (Runtime)
    // We look at the *fields* of the generated type directly.
    const struct_fields = @typeInfo(ResultType).@"struct".fields;

    inline for (struct_fields) |field| {
        const arg_str = args_iter.next() orelse {
            std.debug.print("\n[ERROR] Missing argument: '{s}'\n\n", .{field.name});
            printUsage(args_def);
            return error.MissingArgument;
        };
        const parsed_val = try parseValue(field.type, arg_str);
        
        // @field(result, name) allows us to access the struct field dynamically by string name
        @field(result, field.name) = parsed_val;
    }
    
    if (args_iter.next()) |_| {
        return error.TooManyArguments;
    }

    return result;
}

fn parseValue(comptime T: type, str: []const u8) !T {
    if (T == u32) {
        return std.fmt.parseInt(u32, str, 10);
    } else if (T == bool) {
        return std.mem.eql(u8, str, "true");
    } else if (T == []const u8) {
        return str; // It's already a string!
    }

    return error.UnsupportedType;
}


