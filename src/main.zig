const std = @import("std");
const mtx = @import("mutex.zig").Mutex;

var mutex = mtx{};
var counter : i64 = 0;

fn worker(_:void)void {
    var i :usize = 0;
    while(i < 10000) : (i+=1){
        mutex.lock();
        counter +=1;
        mutex.unlock();
    }
}


pub fn main() !void {
    const t1 = std.Thread.spawn(.{},worker,.{{}}) catch unreachable;
    const t2 = std.Thread.spawn(.{},worker,.{{}}) catch unreachable;

    t1.join();
    t2.join();

    std.debug.print("counter = {d}\n",.{counter});
}
