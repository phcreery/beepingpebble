module draw_gg

import gg
import gx
// import sokol.gfx
import math

// NOTE: in order to simulate the pixelated screen of 400x240, you need to
// change line 472 of gg.c.v to `high_dpi: false`

const (
	width  = 400
	height = 240
)

pub struct Context {
mut:
	// pixel_buffer []int       = []int{len: draw_gg.width * draw_gg.height, init: 0}
	// pixel_buffer gfx.Image
	pixel_buffer [height][width]u32
	img_id       int
	gg_ctx       &gg.Context = unsafe { nil }
}

pub fn create_context(user_data voidptr, frame_fn fn (voidptr), event_fn fn (&gg.Event, voidptr)) &Context {
	mut ctx := &Context{
		gg_ctx: &gg.Context{}
	}
	ctx.gg_ctx = gg.new_context(
		bg_color: gx.white
		width: draw_gg.width
		height: draw_gg.height
		create_window: true
		window_title: 'BEEPINGPEBBLE'
		// init_fn: init_fn
		// init_fn: graphics_init
		init_fn: fn [mut ctx] (_ voidptr) {
			ctx.gg_ctx.new_streaming_image(draw_gg.width, draw_gg.height, 4, pixel_format: .rgba8)
		}
		frame_fn: frame_fn
		event_fn: event_fn
		user_data: user_data
	)

	return ctx
}

pub fn (ctx &Context) begin() {
	ctx.gg_ctx.begin()
}

pub fn (ctx &Context) end() {
	ctx.blit()
	ctx.gg_ctx.end()
}

pub fn (mut ctx Context) run() {
	ctx.gg_ctx.run()
}

pub fn (mut ctx Context) clear() {
	for y in 0 .. draw_gg.height {
		for x in 0 .. draw_gg.width {
			ctx.pixel_buffer[y][x] = u32(gx.white.abgr8())
		}
	}
}

pub fn (ctx &Context) blit() {
	mut img := ctx.gg_ctx.get_cached_image_by_idx(ctx.img_id)
	img.update_pixel_data(unsafe { &u8(&ctx.pixel_buffer) })
	ctx.gg_ctx.draw_image(0, 0, draw_gg.width, draw_gg.height, img)
}

pub fn (mut ctx Context) draw_test_image() {
	for y in 0 .. 24 {
		for x in 0 .. 40 {
			ctx.pixel_buffer[y][x] = u32(gx.green.abgr8())
		}
	}
	mut img := ctx.gg_ctx.get_cached_image_by_idx(ctx.img_id)
	img.update_pixel_data(unsafe { &u8(&ctx.pixel_buffer) })
	ctx.gg_ctx.draw_image(0, 0, draw_gg.width, draw_gg.height, img)
}

pub fn (mut ctx Context) draw_pixel(x int, y int, c gx.Color) {
	if x < 0 || x >= draw_gg.width || y < 0 || y >= draw_gg.height {
		return
	}
	ctx.pixel_buffer[y][x] = u32(c.abgr8())
}

pub fn (mut ctx Context) draw_pixel_inv(x int, y int) {
	if x < 0 || x >= draw_gg.width || y < 0 || y >= draw_gg.height {
		return
	}
	ctx.pixel_buffer[y][x] = (ctx.pixel_buffer[y][x] ^ 0x00ffffff)
}

// https://github.com/miloyip/line
// https://github.com/miloyip/line/blob/master/line_bresenham.c
pub fn (mut ctx Context) draw_line(x f32, y f32, x1 f32, y1 f32, c gx.Color) {
	// ctx.gg_ctx.draw_line(x, y, x1, y1, c)

	mut x0 := x
	mut y0 := y

	dx := math.abs(x1 - x0)
	sx := if x0 < x1 { 1 } else { -1 }
	dy := math.abs(y1 - y0)
	sy := if y0 < y1 { 1 } else { -1 }
	mut err := (if dx > dy { dx } else { -dy }) / 2
	mut e2 := f32(0)

	for {
		ctx.draw_pixel(int(x0), int(y0), c)
		if x0 == x1 && y0 == y1 {
			break
		}
		e2 = err
		if e2 > -dx {
			err -= dy
			x0 += sx
		}
		if e2 < dy {
			err += dx
			y0 += sy
		}
	}
}

pub fn (mut ctx Context) draw_line_inv(x f32, y f32, x1 f32, y1 f32) {
	mut x0 := x
	mut y0 := y

	dx := math.abs(x1 - x0)
	sx := if x0 < x1 { 1 } else { -1 }
	dy := math.abs(y1 - y0)
	sy := if y0 < y1 { 1 } else { -1 }
	mut err := (if dx > dy { dx } else { -dy }) / 2
	mut e2 := f32(0)

	for {
		ctx.draw_pixel_inv(int(x0), int(y0))
		if x0 == x1 && y0 == y1 {
			break
		}
		e2 = err
		if e2 > -dx {
			err -= dy
			x0 += sx
		}
		if e2 < dy {
			err += dx
			y0 += sy
		}
	}
}

pub fn (mut ctx Context) draw_rect_filled(x f32, y f32, w f32, h f32, c gx.Color) {
	// ctx.gg_ctx.draw_rect_filled(x, y, w, h, c)

	ix := int(x)
	iy := int(y)
	iw := int(w)
	ih := int(h)

	for yy in iy .. iy + ih {
		for xx in ix .. ix + iw {
			ctx.draw_pixel(xx, yy, c)
		}
	}
}

pub fn (mut ctx Context) draw_rect_filled_inv(x f32, y f32, w f32, h f32) {
	// ctx.gg_ctx.draw_rect_filled(x, y, w, h, c)

	ix := int(x)
	iy := int(y)
	iw := int(w)
	ih := int(h)

	for yy in iy .. iy + ih {
		for xx in ix .. ix + iw {
			ctx.draw_pixel_inv(xx, yy)
		}
	}
}

pub fn (mut ctx Context) draw_rect_empty(x f32, y f32, w f32, h f32, c gx.Color) {
	// ctx.gg_ctx.draw_rect_empty(x, y, w, h, c)
	ctx.draw_line(x, y, x + w, y, c)
	ctx.draw_line(x + w, y, x + w, y + h, c)
	ctx.draw_line(x + w, y + h, x, y + h, c)
	ctx.draw_line(x, y + h, x, y, c)
}

pub fn (ctx &Context) draw_text(x int, y int, text string, c gx.Color) {
	// gx.FontDef{
	// 	font_size: 8
	// 	font_path: 'assets/fonts/RobotoMono-Regular.ttf'
	// })
	// ctx.gg_ctx.draw_text(x, y, text, c)
	ctx.gg_ctx.draw_text_def(x, y, text)
}
