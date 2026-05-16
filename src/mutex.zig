const std = @import("std");
const linux = std.os.linux;


pub const Mutex = struct {
    state:i32 = 0,

    pub fn lock(self : *Mutex) void {
        while(true){
            const old = @cmpxchgStrong(i32,&self.state,0,1,.acquire,.monotonic);
            if(old == null) return; // The Mutex Is Lock 
            
            _ = linux.syscall4(
                .futex,
                @intFromPtr(&self.state),
                @as(usize,0 | 128), //WAIT | PRIVATE_FLAG
                @as(usize,1), // Expected time out
                @as(usize,0),
                );
        }
    }

  pub fn unlock(self : *Mutex) void{
        @atomicStore(i32,&self.state,0,.release);

        _=linux.syscall4(
            .futex,
            @intFromPtr(&self.state),
            @as(usize,1 | 128), // WAKE | PRIVATE FLAG
            @as(usize,1), // WAKE 1 thread
            @as(usize,0),
        );
  }
};
