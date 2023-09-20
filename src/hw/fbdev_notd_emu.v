module hw

import os
import gx
import time

pub struct Config {
	bg_color  gx.Color
	user_data voidptr
	frame_fn  FNCb    = unsafe { nil }
	init_fn   FNCb    = unsafe { nil }
	event_fn  FNEvent = unsafe { nil }
	width     int
	height    int
	// Keyboard related config
	buffer_size          int  = 256
	hide_cursor          bool = true
	capture_events       bool
	use_alternate_buffer bool = true
	skip_init_checks     bool
	// All kill signals to set up exit listeners on:
	reset []os.Signal = [.hup, .int, .quit, .ill, .abrt, .bus, .fpe, .kill, .segv, .pipe, .alrm, .term,
	.stop]
}

pub struct Context {
pub mut:
	framebuffer os.File

	width          int
	height         int
	width_extended int

	config Config
	// Keyboard related information
	print_buf []u8
	// *nix only implemenationtion information, see: https://github.com/vlang/v/blob/77219de1734e59700aafa12698ac90cc8b359d82/vlib/term/ui/input_nix.c.v
	read_buf []u8
	// read_all_bytes causes all the raw bytes to be read as one event unit.
	// This is cruicial for UTF-8 support since Unicode codepoints can span several bytes.
	read_all_bytes bool = true
}

pub fn new_context(cfg Config) &Context {
	if !(os.exists('/dev/fb1') && os.exists('/sys/class/graphics/fb1/virtual_size')
		&& os.exists('/sys/class/graphics/fb1/stride')) {
		panic('Framebuffer output is not supported')
	}

	virtual_size := os.read_file('/sys/class/graphics/fb1/virtual_size') or {
		panic('Unable to read screen sizes')
	}
	screen_width := virtual_size.split(',')[0].int()
	screen_height := virtual_size.split(',')[1].int()
	screen_width_ext := int(os.read_file('/sys/class/graphics/fb1/stride') or {
		panic('Unable to get extended width')
	}.int() / 4)

	// println('${screen_width}, ${screen_height} (${virtual_size} ${screen_width_ext})')

	mut context := &Context{
		framebuffer: os.open_file('/dev/fb1', 'w') or { panic('Unable to open framebuffer device') }
		width: screen_width
		height: screen_height
		width_extended: screen_width_ext
		config: cfg
	}

	context.read_buf = []u8{cap: cfg.buffer_size}
	context.termios_setup() or { panic('could not setup termios') }

	return context
}

pub fn (context &Context) begin() {
}

pub fn (mut context Context) end() {
}

pub fn (mut context Context) blit(virtualbuffer []u8) {
	context.framebuffer.write_to(0, virtualbuffer) or {}
}

pub fn (mut context Context) run() {
	if context.config.init_fn != unsafe { nil } {
		context.config.init_fn(context.config.user_data)
	}
	unlimited_fps := true
	fps_limit := 60
	for {
		start_time := time.now()
		context.config.frame_fn(context.config.user_data)
		context.fetch_events()
		end_time := time.now()
		$if !unlimited_fps ? {
			frame_draw_time := end_time - start_time
			time.sleep(int(f32(1000) / fps_limit * 1000000) * time.nanosecond - frame_draw_time)
		}
	}
}

pub fn (mut context Context) quit() {
	// context.framebuffer.close()
	restore_terminal_state()
}
