module hw

import gx
import gg

const (
	width       = 400
	height      = 240
	components  = 4
	line_length = width * components
)

pub type FNCb = fn (data voidptr)

type Event = gg.Event

// pub type FNEvent = fn (e &gg.Event, data voidptr)
pub type FNEvent = fn (e &Event, data voidptr)

pub struct Config {
mut:
	bg_color  gx.Color
	user_data voidptr
	frame_fn  FNCb    = unsafe { nil }
	init_fn   FNCb    = unsafe { nil }
	event_fn  FNEvent = unsafe { nil }
	width     int
	height    int
}

pub struct Context {
mut:
	gg_ctx &gg.Context
	img_id int
pub mut:
	config Config
}

pub fn new_context(cfg Config) &Context {
	mut context := &Context{
		gg_ctx: &gg.Context{}
		config: cfg
	}

	gg_ctx := gg.new_context(
		bg_color: gx.white
		width: cfg.width
		height: cfg.height
		create_window: true
		window_title: 'BEEPINGPEBBLE'
		init_fn: fn [mut context] (_ voidptr) {
			context.img_id = context.gg_ctx.new_streaming_image(hw.width, hw.height, hw.components,
				pixel_format: .rgba8
			)
		}
		frame_fn: cfg.frame_fn
		event_fn: cfg.event_fn
		user_data: cfg.user_data
	)
	context.gg_ctx = gg_ctx

	return context
}

pub fn (context &Context) begin() {
	context.gg_ctx.begin()
}

pub fn (mut context Context) end() {
	context.gg_ctx.end()
}

[direct_array_access]
pub fn (mut context Context) blit(virtualbuffer []u8) {
	// convert from []BGRA8 to [][]RGBA32
	mut buffer := [hw.height][width]u32{}
	for y in 0 .. hw.height {
		for x in 0 .. hw.width {
			pos := u64(y * hw.line_length + x * hw.components)
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
	context.gg_ctx.draw_image(0, 0, hw.width, hw.height, img)
}

pub fn (mut context Context) run() {
	context.gg_ctx.run()
}

pub fn (mut context Context) quit() {
	context.gg_ctx.quit()
}
