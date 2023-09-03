module main

import gg
import gx
// import sokol.gfx
import math
import time

// NOTE: in order to simulate the pixelated screen of 400x240, you need to
// change line 472 of gg.c.v to `high_dpi: false`

// these should be automatically determined from the framebuffer device
// see: https://github.com/grz0zrg/fbg/blob/master/src/fbgraphics.c for example
const (
	width  = 400
	height = 240
	components = 4
	line_length=width*components
)

pub struct Context {
mut:
	pixel_buffer []u8
	fps_stopwatch time.Time
	frames	   int
	fps 	   int
	img_id       int
	gg_ctx       &gg.Context = unsafe { nil }
}

pub fn create_context(user_data voidptr, frame_fn fn (voidptr), event_fn fn (&gg.Event, voidptr)) &Context {
	mut ctx := &Context{
		pixel_buffer: []u8{len: line_length*height*components, cap: line_length*height*components, init:0}
		gg_ctx: &gg.Context{}
	}
	ctx.gg_ctx = gg.new_context(
		bg_color: gx.white
		width: width
		height: height
		create_window: true
		window_title: 'BEEPINGPEBBLE'
		// init_fn: init_fn
		// init_fn: graphics_init
		init_fn: fn [mut ctx] (_ voidptr) {
			ctx.gg_ctx.new_streaming_image(width, height, 4, pixel_format: .rgba8)
		}
		frame_fn: frame_fn
		event_fn: event_fn
		user_data: user_data
	)

	ctx.fps_stopwatch = time.now()

	return ctx
}

pub fn (mut ctx Context) compute_fps() {
	ctx.frames += 1
	elapsed := time.since(ctx.fps_stopwatch)
	// println("elapsed ${elapsed}")
	if elapsed.nanoseconds() > 1_000_000_000 {
		ctx.fps = int(ctx.frames)
		println("fps ${ctx.fps}")
		ctx.frames = 0
		ctx.fps_stopwatch = time.now()
	}
}

pub fn (ctx &Context) begin() {
	ctx.gg_ctx.begin()
}

pub fn (mut ctx Context) end() {
	ctx.compute_fps()
	ctx.blit()
	ctx.gg_ctx.end()
}

pub fn (mut ctx Context) run() {
	ctx.gg_ctx.run()
}

pub fn (mut ctx Context) clear() {
	for y in 0 .. height {
		for x in 0 .. width {
			ctx.draw_pixel(x,y, gx.white)
		}
	}
}

pub fn (ctx &Context) blit() {

	// mut buffer := [][]u32{len: height, init: []u32{len: width}}
	mut buffer := [height][width]u32{}
	for y in 0 .. height {
		for x in 0 .. width {
			// convert from BGRA8 to RGBA8
			pos := u64(y*line_length+x*components)
			// println("pos ${pos}")
			blue := ctx.pixel_buffer[pos+0]
			green:= ctx.pixel_buffer[pos+1]
			red:= ctx.pixel_buffer[pos+2]
			// a: ctx.pixel_buffer[u64((line_length*y+x))+3]
			buffer[y][x] = u32((red | (u32(green) << 8) | (u32(blue) << 16) | (0xFF << 24)))

		}
	}
	mut img := ctx.gg_ctx.get_cached_image_by_idx(ctx.img_id)
	img.update_pixel_data(unsafe { &u8(&buffer) })
	ctx.gg_ctx.draw_image(0, 0, width, height, img)
}

[inline]
pub fn (mut ctx Context) draw_pixel(x_ f32, y_ f32, c gx.Color) {
	x:=int(x_)
	y:=int(y_)
	// println("draw_pixel_inv x ${x} y ${y}")
	// println("pixel_buffer len ${ctx.pixel_buffer.len}")

	if x < 0 || x >= width || y < 0 || y >= height { return }
	pos := u64(y*line_length+x*components)
	ctx.pixel_buffer[pos] = u8(c.b)
	ctx.pixel_buffer[pos+1] = u8(c.g)
	ctx.pixel_buffer[pos+2] = u8(c.r)
	ctx.pixel_buffer[pos+3] = u8(255)
}

pub fn (mut ctx Context) draw_pixel_inv(x_ f32, y_ f32) {
	x:=int(x_)
	y:=int(y_)
	if x < 0 || x >= width || y < 0 || y >= height { return }
	pos := u64(y*line_length+x*components)
	ctx.pixel_buffer[pos] = ctx.pixel_buffer[pos] ^ 0xFF
	ctx.pixel_buffer[pos+1] = ctx.pixel_buffer[pos+1] ^ 0xFF
	ctx.pixel_buffer[pos+2] = ctx.pixel_buffer[pos+2] ^ 0xFF
	ctx.pixel_buffer[pos+3] = u8(255)
}

// https://github.com/miloyip/line
// https://github.com/miloyip/line/blob/master/line_bresenham.c
pub fn (mut ctx Context) draw_line(x f32, y f32, x1 f32, y1 f32, c gx.Color) {

	mut x0 := x
	mut y0 := y

	dx := math.abs(x1 - x0)
	sx := if x0 < x1 { 1 } else { -1 }
	dy := math.abs(y1 - y0)
	sy := if y0 < y1 { 1 } else { -1 }
	mut err := (if dx > dy { dx } else { -dy }) / 2
	mut e2 := f32(0)

	for {
		ctx.draw_pixel(x0, y0, c)
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
		ctx.draw_pixel_inv(x0,y0)
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
