const Mutex = @import("mutex.zig").Mutex;


pub const Task = struct {
    func:*const fn (*anyopaque) void,
    arg:*anyopaque,
    next:?*Task = null,
};

pub const Queue = struct {
    head:?*Task = null,
    tail:?*Task =null,
    mutex:Mutex = .{},

    pub fn push(self:*Queue,task:*Task) void{
        self.mutex.lock();
        defer self.mutex.unlock();

        task.next = null;

        if(self.tail) |tail|{
            tail.next = task;
        }else {
            self.head = task;
        }

        self.tail = task;
    }

    pub fn pop(self:*Queue) *?Task{
        self.mutex.lock();
        defer self.mutex.unlock();

        const task = self.head orelse return null;
        self.head = task.next;

        if(self.head == null) self.tail = null;
        return task;
    }
};
