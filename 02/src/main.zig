const std = @import("std");

const sout = std.io.getStdOut().writer();

const entry = struct {
    key: []const u8,
    value: u8,
};

const preview = struct {
    red: u8,
    green: u8,
    blue: u8,

    // Takes only the biggest of each member
    pub fn add_preview(self: *preview, prev: *preview) void {
        if (self.red < prev.red) {
            self.red = prev.red;
        }
        if (self.green < prev.green) {
            self.green = prev.green;
        }
        if (self.blue < prev.blue) {
            self.blue = prev.blue;
        }
    }

    // Returns false when any value in self is larger than in the template
    pub fn validate_preview(self: *preview, template: *preview) bool {
        if (self.red > template.red) {
            return false;
        }
        if (self.green > template.green) {
            return false;
        }
        if (self.blue > template.blue) {
            return false;
        }
        return true;
    }

    pub fn print(self: *preview) !void {
        try sout.print("R:{d} G:{d} B:{d}\n", .{ self.red, self.green, self.blue });
    }

    pub fn pow(self: *preview) u32 {
        var i: u32 = self.red;
        i *= self.green;
        i *= self.blue;
        return i;
    }
};

pub fn parse_preview(section: []const u8) !preview {
    var vals = std.mem.splitSequence(u8, section, ", ");
    var prev = preview{ .red = 0, .blue = 0, .green = 0 };

    while (vals.next()) |val| {
        var split = std.mem.splitAny(u8, val, " ");
        var x: entry = undefined;

        if (split.next()) |v| {
            x.value = try std.fmt.parseInt(u8, v, 10);
        }
        if (split.next()) |c| {
            x.key = c;
        }

        if (x.key.len >= 3 and std.mem.eql(u8, "red", x.key)) {
            prev.red = x.value;
        } else if (x.key.len >= 5 and std.mem.eql(u8, "green", x.key)) {
            prev.green = x.value;
        } else if (x.key.len >= 4 and std.mem.eql(u8, "blue", x.key)) {
            prev.blue = x.value;
        }
    }

    return prev;
}

pub fn parse_line(records: []const u8) !preview {
    var sections = std.mem.splitSequence(u8, records, "; ");
    var stat = preview{ .red = 0, .blue = 0, .green = 0 };

    while (sections.next()) |sec| {
        var prev = parse_preview(sec) catch preview{ .red = 0, .green = 0, .blue = 0 };
        stat.add_preview(&prev);
    }

    return stat;
}

pub fn main() !void {
    var reader = std.io.getStdIn().reader();
    var total_val: u16 = 0;
    var total_pow: u32 = 0;

    var buf: [1024]u8 = undefined;
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        var x = std.mem.splitSequence(u8, line, ": ");
        var id: u8 = 0;

        if (x.next()) |header| {
            id = try std.fmt.parseInt(u8, header[5..], 10);
        }
        if (x.next()) |content| {
            var stat = try parse_line(content);
            var template = preview{
                .red = 12,
                .green = 13,
                .blue = 14,
            };

            if (stat.validate_preview(&template)) {
                total_val += id;
            }
            total_pow += stat.pow();
        }
    }

    try sout.print("Part1: {d}\n", .{total_val});
    try sout.print("Part2: {d}\n", .{total_pow});
}

test "parse_preview_test" {
    var prev = try parse_preview("2 red, 14 blue, 17 green");
    try std.testing.expect(prev.red == 2);
    try std.testing.expect(prev.blue == 14);
    try std.testing.expect(prev.green == 17);
}

test "add_preview_test" {
    var prev = try parse_preview("2 red, 14 blue, 17 green");
    var add = preview{
        .red = 4,
        .green = 16,
        .blue = 15,
    };
    prev.add_preview(&add);
    try std.testing.expect(prev.red == 4);
    try std.testing.expect(prev.blue == 15);
    try std.testing.expect(prev.green == 17);
}

test "parse_line_test" {
    var valid = try parse_line("1 red, 2 blue, 3 green; 17 red, 3 blue, 22 green");
    try std.testing.expect(!valid);
    valid = try parse_line("1 red, 2 blue, 3 green; 22 green; 1 blue");
    try std.testing.expect(!valid);
}
