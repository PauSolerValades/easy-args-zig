const std = @import("std");
const args = @import("eazy_args");

const Arg = args.Arg;
const OptArg = args.OptArg;
const Flag = args.Flag;

pub fn main() !void {

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const gpa = arena.allocator();
    
    var buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&buffer);
    const stdout = &stdout_writer.interface;
    
    var buferr: [1024]u8 = undefined;
    var stderr_writer = std.fs.File.stdout().writer(&buferr);
    const stderr = &stderr_writer.interface;
    
    const definition = .{
        .required = .{
            Arg(f64, "lambda", "Interarrival passanger rate (exponential)"),
            Arg(f64, "mu", "Interarrival bus rate (exponential)"),
            Arg(f64, "bus_capacity", "Bus capacity when arrives (X)"),
            Arg(u64, "system_capacity", "Total System capacity (K)"),
        },
        .optional = .{
            OptArg(f64, "horizon", "t", 1000, "Simulation duration"),
            OptArg(u64, "repetitions", "n", 1, "Number of repetitions"),
            OptArg([]const u8, "output_file", "o", "traca.txt", "Ouput file for the system"),
        },
        .flags = .{},
    };
    
    const arguments = args.parseArgs(gpa, definition, stdout, stderr) catch |err| {
        switch (err) {
            error.HelpShown => try stdout.flush(),
            else => try stderr.flush(),
        }    

        std.process.exit(0);
    };

    try stdout.print("{any}\n", .{arguments});
    try stdout.flush();

    // ---------- old code
    //
    //const HELP =
    //     \\This program runs a Simulation of an M/M^[X]/1/K system. 
    //     \\Both arrivals and services are Exp, with parameters lambda (arrivals) and mu (services).
    //     \\X is the batch services, and K is the maximum system clients.
    //     \\Boarding times are assumed to be negliglble (1e-16)
    //     \\Parameter B allows to run the simulation B times.
    //     \\
    //     \\Usage:
    //     \\      lambda  <f64>
    //     \\      mu      <f64>
    //     \\      X       <u64>
    //     \\      K       <u64>
    //     \\      horizon <f64>
    //     \\      B       <u64>
    // ;
    //
    // if (args.len != 7) {
    //     try stdout.print("Usage: lambda <float> mu <float> X <int> K <int> horizon <float> B <int>. Write --help for more\n", .{});
    //     try stdout.flush();
    //     std.process.exit(0);
    // }
    //
    // if (eql(u8, args[1], "-h") or
    //     eql(u8, args[1], "--help") or
    //     eql(u8, args[1], "help"))
    // {
    //     try stdout.print("{s}\n", .{HELP});
    //     try stdout.flush();
    //     std.process.exit(0);
    // }
    //
    // const lambda = try std.fmt.parseFloat(f64, args[1]);
    // const mu = try std.fmt.parseFloat(f64, args[2]);
    // const x = try std.fmt.parseFloat(f64, args[3]);
    // const k = try std.fmt.parseInt(u64, args[4], 10);
    // const horizon = try std.fmt.parseFloat(f64, args[5]);
    // const B = try std.fmt.parseInt(usize, args[6], 10);
    //
    // const config = SimConfig{
    //     .horizon = horizon,
    //     .passenger_interarrival = Distribution{ .exponential = lambda }, // lambda
    //     .bus_interarrival = Distribution{ .exponential = mu }, // mu
    //     .bus_capacity = Distribution{ .constant = x }, // X
    //     .boarding_time = Distribution{ .constant = 1e-16 }, // minim perque no importa
    //     .system_capacity = k, // K
    // };

}
