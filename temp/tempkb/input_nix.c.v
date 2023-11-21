module main

// init initializes the terminal console with Config `cfg`.
pub fn init(cfg Config) &Context {
	mut ctx := &Context{
		cfg: cfg
	}
	ctx.read_buf = []u8{cap: cfg.buffer_size}
	return ctx
}

// run sets up and starts the terminal.
pub fn (mut ctx Context) run() ! {
	if ctx.cfg.use_x11 {
		ctx.fail('error: x11 backend not implemented yet')
		exit(1)
	} else {
		ctx.termios_setup() or { panic(err) }
		ctx.termios_loop()
	}
}

// shifts the array left, to remove any data that was just read, and updates its len
// TODO: remove
@[inline]
fn (mut ctx Context) shift(len int) {
	unsafe {
		C.memmove(ctx.read_buf.data, &u8(ctx.read_buf.data) + len, ctx.read_buf.cap - len)
		ctx.resize_arr(ctx.read_buf.len - len)
	}
}

// TODO: don't actually do this, lmao
@[inline]
fn (mut ctx Context) resize_arr(size int) {
	mut l := unsafe { &ctx.read_buf.len }
	unsafe {
		*l = size
		_ = l
	}
}
