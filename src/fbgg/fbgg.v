module fbgg

import os
import gx
import gg
// import time


const (
	width       = 400
	height      = 240
	components  = 4
	line_length = width * components
)

pub struct Config {
mut:
	bg_color  gx.Color
	user_data voidptr
	frame_fn  FNCb = unsafe { nil }
	init_fn   FNCb = unsafe { nil }
	event_fn FNEvent = unsafe { nil }
	// compability only (not used)
	width         int
	height        int
	create_window bool
	window_title  string
}

pub struct Context {
mut:
	gg_ctx &gg.Context
	img_id int
pub mut:
	bg_color    gx.Color

	width          int
	height         int
	// width_extended int

	// user_data voidptr
	// frame_fn  FNCb = unsafe { nil }
	// init_fn   FNCb = unsafe { nil }
	// event_fn		FNEvent = unsafe { nil }
}

pub fn new_context(args Config) &Context {
	mut context := &Context{
		gg_ctx: &gg.Context{}

		width: args.width
		height: args.height
		// width_extended: screen_width_ext
		bg_color: args.bg_color

		// user_data: args.user_data
		// frame_fn: args.frame_fn
		// init_fn: args.init_fn
		// event_fn:		args.event_fn
	}

	// mut test_ctx := gg.new_context(
	// 	bg_color: gx.white
	// 	width: 400
	// 	height: 240
	// 	create_window: true
	// 	window_title: 'BEEPINGPEBBLE'
	// 	// init_fn: init_fn
	// 	// init_fn: graphics_init
	// 	// init_fn: fn [mut dwg] (_ voidptr) {
	// 	// 	dwg.img_id = dwg.hw_ctx.new_streaming_image(width, height, components, pixel_format: .rgba8)
	// 	// }
	// 	// frame_fn: frame_fn
	// 	// event_fn: event_fn
	// 	// user_data: user_data
	// )
	// test_ctx.run()

	gg_ctx := gg.new_context(
		bg_color: gx.white
		width: args.width
		height: args.height
		create_window: true
		window_title: 'BEEPINGPEBBLE'
		init_fn: fn [mut context] (_ voidptr) {
			context.img_id = context.gg_ctx.new_streaming_image(width, height, components, pixel_format: .rgba8)
		}
		frame_fn: args.frame_fn
		event_fn: args.event_fn
		user_data: args.user_data
	)
	context.gg_ctx = gg_ctx

	// println("gg_ctx ${gg_ctx}")


	return context
}

pub fn (context &Context) begin() {
	context.gg_ctx.begin()
}

pub fn (mut context Context) end() {
	context.gg_ctx.end()
}

pub fn (mut context Context) blit(virtualbuffer []u8) {
	mut buffer := [height][width]u32{}
	for y in 0 .. height {
		for x in 0 .. width {
			// convert from BGRA8 to RGBA8
			pos := u64(y * line_length + x * components)
			// println("pos ${pos}")
			blue := virtualbuffer[pos + 0]
			green := virtualbuffer[pos + 1]
			red := virtualbuffer[pos + 2]
			// a: dwg.pixel_buffer[u64((line_length*y+x))+3]
			buffer[y][x] = u32((red | (u32(green) << 8) | (u32(blue) << 16) | (0xFF << 24)))
		}
	}
	// see https://github.com/vlang/v/blob/007519e1300ef42a36380307cbbd248bb2940937/examples/gg/random.v
	mut img := context.gg_ctx.get_cached_image_by_idx(context.img_id)
	img.update_pixel_data(unsafe { &u8(&buffer) })
	context.gg_ctx.draw_image(0, 0, width, height, img)
}

pub fn (mut context Context) run() {
	context.gg_ctx.run()
}

pub fn (mut context Context) quit() {
	context.gg_ctx.quit()
}
