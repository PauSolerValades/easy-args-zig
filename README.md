# EazyArgs

A simple, type-safe, no boilerplate arg parser for Zig that leverages compile-time meta-programming to generate and fill an struct according to the provided definitions.
Absolutely inspired by @gouwsxander [easy-args](https://github.com/gouwsxander/easy-args) C library.

## Main Idea


EazyArgs leverages type [reification](https://en.wikipedia.org/wiki/Reification_(computer_science)) (create a type instead given a definition instead of explicitly writing it) to allow a much simpler and categorical definition. To parse your program arguments, you just need to define which `flags` the program accepts, which `options` and which `required` (positional) arguments are needed instead of defining the struct, as well as allowing to nest as many definitions as you want with `commands`.

+ **Simple, No Boilerplate**: Define your arguments once. The library generates the types, the validation, and the parser automatically.
+ **Categorical & Nested**: cleanly separate Flags, Options, and Positional arguments. Nest commands as deep as you need (e.g., git remote add origin).
+ [TODO] **Help Generation**: Usage strings are automatically generated from your definitions.
+ **Compile-time Specialized**: The validation happens at compile-time. The parser uses `inline` loops, meaning the resulting machine code is optimized specifically for your definition—no generic runtime overhead.

## Simple Example

Import the library and the argument structs.

```zig
const argz = @import("eazy_args");

const Arg = argz.Arguments;
const OptArg = argz.Option;
const Flag = argz.Flag;
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


## Features

To allow commands and subcommands, EazyArgs imposes the following rules in the definition
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


