const std = @import("std");
const argz = @import("eazy_args");

const Arg = argz.Argument;
const Opt = argz.Option;
const Flag = argz.Flag;

pub fn main(init: std.process.Init) !void {

    var buffer: [1024]u8 = undefined;
    var stdout_writer = std.Io.File.stdout().writer(init.io, &buffer);
    const stdout = &stdout_writer.interface;
    
    var buferr: [1024]u8 = undefined;
    var stderr_writer = std.Io.File.stdout().writer(init.io, &buferr);
    const stderr = &stderr_writer.interface;
    
    const definition = .{
        .required = .{
            Arg(f64, "lambda", "Interarrival passanger rate (exponential)"),
            Arg(f64, "mu", "Interarrival bus rate (exponential)"),
            Arg(f64, "bus_capacity", "Bus capacity when arrives (X)"),
            Arg(u64, "system_capacity", "Total System capacity (K)"),
        },
        .options = .{
            Opt(f64, "horizon", "t", 1000, "Simulation duration"),
            Opt(u64, "repetitions", "n", 1, "Number of repetitions"),
            Opt([]const u8, "output_file", "o", "traca.txt", "Ouput file for the system"),
        },
    };
    
    const args = try init.minimal.args.toSlice(init.gpa);
    const arguments = argz.parseArgs(init.gpa, definition, args, stdout, stderr) catch |err| {
        switch (err) {
            error.HelpShown => try stdout.flush(),
            else => try stderr.flush(),
        }    

        std.process.exit(0);
    };

    try stdout.print("{any}\n", .{arguments});
    try stdout.flush();

}
