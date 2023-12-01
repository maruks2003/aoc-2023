const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    var input = std.io.getStdIn();
    defer input.close();

    var buf_reader = std.io.bufferedReader(input.reader());
    var in_stream = buf_reader.reader();

    var total_val: u32 = 0;

    var buf: [1024]u8 = undefined;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var got_first = false;
        var first: u8 = undefined;
        var last: u8 = undefined;

        for (line) |char| {
            if (('0' <= char and char <= '9')) {
                if (!got_first) {
                    first = char;
                    got_first = true;
                }
                last = char;
            }
        }

        var num_str = [_]u8{ first, last };
        total_val += try std.fmt.parseInt(u32, &num_str, 10);
    }

    _ = try stdout.print("{d}\n", .{total_val});
}
