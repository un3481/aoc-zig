
const std = @import("std");

const digits = [10]u8{
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
};

const literals = [10][]const u8{
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
};

const MyNumberError = error{
    InvalidLiteral,
};

pub fn main() !void {

    const allocator = std.heap.page_allocator;
    
    const stdout = std.io.getStdOut().writer(); 
    
    const args = try std.process.argsAlloc(allocator);
    const file_path = args[1];

    var file = try std.fs.cwd().openFile(file_path, .{});
    defer file.close();

    var calib_sum: usize = 0;
    var two_digit = [2]u4{ 0, 0 };
    var empty_digit: bool = true;
    var literal = std.ArrayList(u8).init(allocator);
    defer literal.deinit();

    const end = try file.getEndPos();
    while (end > try file.getPos()) {
        
        var chars: [1]u8 = undefined;
        const len = try file.read(&chars);
        if (len == 0) break;

        if (chars[0] == '\n') {
            const calib = (@as(u7, two_digit[0]) * 10) + two_digit[1];
            try stdout.print("calib: {}\n", .{calib});
            calib_sum += calib;
            literal.clearRetainingCapacity();
            empty_digit = true;
            continue;
        }
        
        try literal.append(chars[0]);
        const digit = std.fmt.parseInt(u4, &chars, 10) catch parseLiteral(literal) catch continue;
        literal.clearRetainingCapacity();

        if (empty_digit) {
            two_digit[0] = digit;
            empty_digit = false;
        }
        two_digit[1] = digit;
    }

    try stdout.print("the calibration sum value is: {d}\n", .{calib_sum});
}

fn parseLiteral(buff: std.ArrayList(u8)) MyNumberError!u4 {
    for (literals, 0..) |literal, i| {
        if (std.mem.count(u8, buff.items, literal) > 0) return @intCast(i);
    }
    return MyNumberError.InvalidLiteral;
}

