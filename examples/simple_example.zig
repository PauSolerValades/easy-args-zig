const std = @import("std");

const argz = @import("eazy-args");

const Arg = argz.Argument;
const Opt = argz.Option;
const Flag = argz.Flag;

pub fn main() !void {
    const definition = .{
        .required = .{ // type, field name, description
            Arg(u32, "limit", "Limits are meant to be broken"),
            Arg([]const u8, "username", "Who are you?"),
        },
        .options = .{ // type, field_name, short, default, description
            Opt(u32, "break", "b", 100, "Stop before the limit"),
            Opt(f64, "step", "s", 1.0, "Subdivision of the interval"),
        },
        .flag = .{ // field_name, short, description - default is false
            Flag("--verbose", "-v", "More info"),
        }
    };
    
    // call GNU freestyle parser
    const args = try init.minimal.args.toSlice(init.arena.allocator()); 
    const gnuargs = argz.parseArgs(init.gpa, gitu_def, args, stdout, stderr) catch |err| {
        switch (err) {
            ParseErrors.HelpShown => try stdout.flush(),
            else => try stderr.flush(),
        }    
        std.process.exit(0);
    };

    // call the posix parser function. No allocator needed (not in windows tho)
    var iter = init.minimal.args.iterate(); 
    const posixargs = argz.parseArgsPosix(gitu_def, &iter, stdout, stderr) catch |err| {
        switch (err) {
            ParseErrors.HelpShown => try stdout.flush(),
            else => try stderr.flush(),
        }
        std.process.exit(0);
    };
    
}
