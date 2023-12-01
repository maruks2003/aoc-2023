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
        var first: u8 = 0;
        var last: u8 = 0;

        for (0..line.len) |idx| {
            var num: u8 = 0;

            if (line.len - idx + 1 > 3 and std.mem.eql(u8, line[idx .. idx + 3], "one")) {
                num = 1;
            } else if (line.len - idx + 1 > 3 and std.mem.eql(u8, line[idx .. idx + 3], "two")) {
                num = 2;
            } else if (line.len - idx + 1 > 5 and std.mem.eql(u8, line[idx .. idx + 5], "three")) {
                num = 3;
            } else if (line.len - idx + 1 > 4 and std.mem.eql(u8, line[idx .. idx + 4], "four")) {
                num = 4;
            } else if (line.len - idx + 1 > 4 and std.mem.eql(u8, line[idx .. idx + 4], "five")) {
                num = 5;
            } else if (line.len - idx + 1 > 3 and std.mem.eql(u8, line[idx .. idx + 3], "six")) {
                num = 6;
            } else if (line.len - idx + 1 > 5 and std.mem.eql(u8, line[idx .. idx + 5], "seven")) {
                num = 7;
            } else if (line.len - idx + 1 > 5 and std.mem.eql(u8, line[idx .. idx + 5], "eight")) {
                num = 8;
            } else if (line.len - idx + 1 > 4 and std.mem.eql(u8, line[idx .. idx + 4], "nine")) {
                num = 9;
            } else if ('0' <= line[idx] and line[idx] <= '9') {
                num = try std.fmt.parseInt(u8, line[idx .. idx + 1], 10);
            }

            if (num != 0) {
                if (!got_first) {
                    first = num;
                    got_first = true;
                }
                last = num;
            }
        }
        _ = try stdout.print("{s} - {d}{d}\n", .{ line, first, last });
        //_ = try stdout.write("\n");

        total_val += first * 10 + last;
    }

    _ = try stdout.print("{d}\n", .{total_val});
}
