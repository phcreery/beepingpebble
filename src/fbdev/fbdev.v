module fbdev

import os
import gx
// import gg
import time
// import vpng
// built-in
// import fbdev.mouse
import fbdev.keyboard

pub type FNCb = fn (data voidptr)
pub type FNEvent = fn (e &Event, data voidptr)

pub struct Config {
	bg_color  gx.Color
	user_data voidptr
	frame_fn  FNCb = unsafe { nil }
	init_fn   FNCb = unsafe { nil }
	event_fn		FNEvent = unsafe { nil }
	
	// compability only (not used)
	width         int
	height        int
	create_window bool
	window_title  string
}

pub struct Context {
pub mut:
	framebuffer os.File
	bg_color    gx.Color

	width          int
	height         int
	width_extended int

	user_data voidptr
	frame_fn  FNCb = unsafe { nil }
	init_fn   FNCb = unsafe { nil }
	event_fn		FNEvent = unsafe { nil }
	
	keyboard_manager	&keyboard.Manager = unsafe { nil }
	keydown_fn		FNKeyDown = unsafe { nil }
	char_fn			FNChar    = unsafe { nil }
}

pub fn new_context(args Config) &Context {
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

	println('${screen_width}, ${screen_height} (${virtual_size} ${screen_width_ext})')

	mut context := &Context{
		framebuffer: os.open_file('/dev/fb1', 'w') or { panic('Unable to open framebuffer device') }
		width: screen_width
		height: screen_height
		width_extended: screen_width_ext
		bg_color: args.bg_color
		user_data: args.user_data
		frame_fn: args.frame_fn
		init_fn: args.init_fn
		event_fn:		args.event_fn
	}

	context.keyboard_manager = keyboard.new_manager(
		keyboard_fn: fn [context] (key keyboard.KeyCode) {
			println(key)
			if context.event_fn != unsafe { nil } {
				context.event_fn(&Event{
					typ: .key_down
					key_code: key
				}, context.user_data)
			}
			if context.keydown_fn != unsafe { nil } {
				context.keydown_fn(key, unsafe { Modifier(0) }, context.user_data)
			}
			if context.char_fn != unsafe { nil } {
				if key != .escape && key != .enter && key != .backspace && key != .left &&
					key != .right && key != .up && key != .down {
						context.char_fn(u32(key), context.user_data)
				}
			}
		}
	)

	return context
}

pub fn (context &Context) begin() {
	// context.draw_rect_filled(0, 0, context.width, context.height, context.bg_color)
}

pub fn (mut context Context) end() {
}

pub fn (mut context Context) blit(virtualbuffer []u8) {
	context.framebuffer.write_to(0, virtualbuffer) or {}
}

pub fn (mut context Context) run() {
	if context.init_fn != unsafe { nil } {
		context.init_fn(context.user_data)
	}
	for {
		context.frame_fn(context.user_data)
		// time.sleep(1000 / 30 * time.millisecond)
	}
}

pub fn (mut context Context) quit() {
	keyboard.restore_term()
	// context.framebuffer.close()
	exit(0)
}
