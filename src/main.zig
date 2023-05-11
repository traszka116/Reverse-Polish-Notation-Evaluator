const std = @import("std");
const TStack = std.atomic.Stack;
const fmt = std.fmt;
const mem = std.mem;

const Stack = TStack(f32);
const Node = Stack.Node;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();
    const allocator = gpa.allocator();

    try stdout.print("insert \"reverse polish notation\" expresion to evaluation: \n", .{});
    const buffered = try stdin.readUntilDelimiterAlloc(allocator, '\n', 4096);
    const string = buffered[0 .. buffered.len - 1];

    var iterator: mem.TokenIterator(u8) = mem.tokenize(u8, string, " ");

    var stack: Stack = Stack.init();

    while (iterator.next()) |str| {
        if (fmt.parseFloat(f32, str)) |number| {
            var node: *Node = try allocator.create(Node);
            node.data = number;
            stack.push(node);
        } else |err| {
            _ = try std.fmt.allocPrint(allocator, "{}", .{err});
            if (mem.eql(u8, "+", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var second: ?*Node = stack.pop();
                if (second == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var new = try allocator.create(Node);
                new.data = second.?.data + first.?.data;
                allocator.destroy(first.?);
                allocator.destroy(second.?);
                stack.push(new);
            } else if (mem.eql(u8, "-", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var second: ?*Node = stack.pop();
                if (second == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var new = try allocator.create(Node);
                new.data = second.?.data - first.?.data;
                allocator.destroy(first.?);
                allocator.destroy(second.?);
                stack.push(new);
            } else if (mem.eql(u8, "*", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var second: ?*Node = stack.pop();
                if (second == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var new = try allocator.create(Node);
                new.data = second.?.data * first.?.data;
                allocator.destroy(first.?);
                allocator.destroy(second.?);
                stack.push(new);
            } else if (mem.eql(u8, "/", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var second: ?*Node = stack.pop();
                if (second == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var new = try allocator.create(Node);
                if (first.?.data == 0) {
                    try stdout.print("Trying to divide by 0.\n", .{});
                    return error.Trying_to_divide_by_0;
                }
                new.data = second.?.data / first.?.data;
                allocator.destroy(first.?);
                allocator.destroy(second.?);
                stack.push(new);
            } else if (mem.eql(u8, "sqrt", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                if (first.?.data < 0) {
                    try stdout.print("Trying to take square root of negative number.\n", .{});
                    return error.Trying_to_get_a_square_root_of_negative_numbers;
                }
                first.?.data = std.math.sqrt(first.?.data);
                stack.push(first.?);
            } else if (mem.eql(u8, "pow", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var second: ?*Node = stack.pop();
                if (second == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                var new = try allocator.create(Node);
                new.data = std.math.pow(f32, second.?.data, first.?.data);
                allocator.destroy(first.?);
                allocator.destroy(second.?);
                stack.push(new);
            } else if (mem.eql(u8, "PI", str)) {
                var node: *Node = try allocator.create(Node);
                node.data = @as(f32, std.math.pi);
                stack.push(node);
            } else if (mem.eql(u8, "E", str)) {
                var node: *Node = try allocator.create(Node);
                node.data = @as(f32, std.math.e);
                stack.push(node);
            } else if (mem.eql(u8, "sin", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                first.?.data = std.math.sin(first.?.data);
                stack.push(first.?);
            } else if (mem.eql(u8, "cos", str)) {
                var first: ?*Node = stack.pop();
                if (first == null) {
                    try stdout.print("Trying to take data from empty stack.\n", .{});
                    return error.Trying_to_pop_from_empty_stack;
                }
                first.?.data = std.math.cos(first.?.data);
                stack.push(first.?);
            } else {
                try stdout.print("Cannot evaluate non-numeric values.\n", .{});
                return error.Invalid_Statement;
            }
        }
    }
    var top = stack.pop();
    if (top == null) {
        try stdout.print("There is no data to evaluate.", .{});
    }
    try stdout.print("solution is : {d:.2}.\n", .{top.?.data});
}
