# EazyArgs

A simple, type-safe argument parser for Zig that leverages compile-time metaprogramming to generate a ready-to-use struct from the arguments definitions.
Absolutely inspired by @gouwsxander [easy-args](https://github.com/gouwsxander/easy-args) C library.

## Main Idea

In general, argument parsers require the user to write the struct to parse, and then implement the parsing logic. EazyArgs goes the other way around: the user defines the arguments of the program and the Zig compiler generates the struct for you.

This idea offers the following features:
+ **Simple, No Boilerplate**: Define your arguments once with their required type, those will become the struct fields. No need to write a separte string and then call a parser. 
+ **Flexible**: Can specify required positional arguments, optional named arguments and boolean flags separately.
+ **Help Generation**: generate help strings with just the provided description.

## Example Use

Import the library and the argument structs.

```zig
const eargs = @import("eazy_args");

const Arg = eargs.Arg;
const OptArg = eargs.OptArg;
const Flag = eargs.Flag;
```

Then, declare an anonymous struct which has to contain the following elements: `.required`, `.optional` and `.flags`.

```zig
const definitions = .{
    .required = .{
      Arg(u32, "limit", "Limits are meant to be broken"),
      Arg([]const u8, "username", "who are you dear?"),
    },
    .optional = .{
      // type, field_name, short, default, description
      OptArg(u32, "--break", "-b", 100, "Stop before the limit"),
    },
    .flag = .{
      // default as false, type is bool
      // field_name, short, description
      Flag("--verbose", "-v", "Print a little, print a lot"),
    }
};
```

If you don't need flags or optional arguments, you must leave that parameter empty: 

```zig
const definitions = .{
    .required = .{
      Arg(u32, "limit", "Limits are meant to be broken"),
      Arg([]const u8, "username", "who are you dear?"),
    },
    .optional = .{},
    .flag = .{}
};
```

Now, just call `parseArgs` to obtain an struct with all the data contained

```zig
const arguments = eaz.parseArgs(allocator, definitions, stdout, stderr) catch |err| {
    switch (err) {
        error.HelpShown => {
            try stdout.flush();
        },
        else => {
            try stderr.flush();
        }
    }    
    std.process.exit(0);
};
```

If they match, arguments will contain all the terminal data properly parsed, with optionals not found with their default value and flags to false.

Use `help` as a first argument to print the help string:

```
$: ./program help
Usage: app [options] <limit> <username>

Positional Arguments:
  limit        (u32): Limits are meant to be broken
  username     ([]const u8): who are you dear?

Options:
  -b, --break        <u32>: Stop before the limit (default: 100)
  -v, --verbose            : Print a little, print a lot
```

You cannot declare a positional argument called `help` nor a optional/flag called `--help` or `-h`, those are reserved and will throw a compile time error.

## API Reference

Arg (Positional)
+ Type: The Zig type to parse (e.g., u32, []const u8, bool).
+ Name: The field name in the struct.
+ Description: Help text displayed in usage.

OptArg (Optional Option)
+ Type: The value type. 
+ Name: Long flag name (e.g., "port" → --port).
+ Short: Short flag alias (e.g., "p" → -p).
+ Default: The value used if the flag is omitted (Must match Type).
+ Description: Help text.

Flag (Boolean Switch)
+ Name: Long flag name.
+ Short: Short flag alias.
+ Description: Help text.

Note: Flags are always bool and default to false.


