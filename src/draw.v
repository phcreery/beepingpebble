module main

import gx
// import sokol.gfx
import math
import time
import arrays

// $if rpi ? {
// 	import fbdev as gg
// } $else {
	import gg
// }


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
	// gg_ctx       &fbdev.Context = unsafe { nil }
}

pub fn create_context(user_data voidptr, frame_fn fn (voidptr), event_fn fn (&gg.Event, voidptr)) &Context { //, event_fn fn (&gg.Event, voidptr)
	mut ctx := &Context{
		pixel_buffer: []u8{len: line_length*height*components, cap: line_length*height*components, init:0}
		gg_ctx: &gg.Context{}
		// gg_ctx: &fbdev.Context{}
	}
	// ---- GG ----
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

	// ---- fbdev ----
	// ctx.gg_ctx = fbdev.new_context(
	// 	bg_color: gx.white
	// 	width: width
	// 	height: height

	// 	frame_fn: frame_fn
	// 	// event_fn: event_fn
	// 	user_data: user_data
	// )



	ctx.fps_stopwatch = time.now()

	return ctx
}

pub fn (mut ctx Context) compute_fps() {
	ctx.frames += 1
	elapsed := time.since(ctx.fps_stopwatch)
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

pub fn (mut ctx Context) blit() {

	// ---- gg ----
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

	// ---- fbdev ----
	// ctx.gg_ctx.blit(ctx.pixel_buffer)
	// OR
	// ctx.gg_ctx.framebuffer.write_to(0, ctx.pixel_buffer) or {}
}

[inline]
pub fn (mut ctx Context) draw_pixel(x_ f32, y_ f32, c gx.Color) {
	x:=int(x_)
	y:=int(y_)

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
	ix := int(x)
	iy := int(y)
	iw := int(w)
	ih := int(h)


	for yy in iy .. iy + ih+1 {
		for xx in ix .. ix + iw+1 {
			ctx.draw_pixel(xx, yy, c)
		}
	}
}

pub fn (mut ctx Context) draw_rect_filled_inv(x f32, y f32, w f32, h f32) {
	ix := int(x)
	iy := int(y)
	iw := int(w)
	ih := int(h)

	for yy in iy .. iy + ih+1 {
		for xx in ix .. ix + iw+1 {
			ctx.draw_pixel_inv(xx, yy)
		}
	}
}

pub fn (mut ctx Context) draw_rect_empty(x f32, y f32, w f32, h f32, c gx.Color) {
	ctx.draw_line(x, y, x + w, y, c)
	ctx.draw_line(x + w, y, x + w, y + h, c)
	ctx.draw_line(x + w, y + h, x, y + h, c)
	ctx.draw_line(x, y + h, x, y, c)
}

pub fn (mut ctx Context) draw_rect_empty_inv(x f32, y f32, w f32, h f32) {
	ctx.draw_line_inv(x, y, x + w, y)
	ctx.draw_line_inv(x + w, y, x + w, y + h)
	ctx.draw_line_inv(x + w, y + h, x, y + h)
	ctx.draw_line_inv(x, y + h, x, y)
}

pub fn (mut ctx Context) draw_polygon(points []Point, c gx.Color) {
	for i in 0 .. points.len {
		ctx.draw_line(points[i].x, points[i].y, points[(i+1)%points.len].x, points[(i+1)%points.len].y, c)
	}
}

pub fn (mut ctx Context) draw_polygon_filled(points []Point, c gx.Color) {
	num_coreners := points.len
	mut vx := []int{}
	mut vy := []int{}
	for p in points {
		vx << int(p.x)
		vy << int(p.y)
	}
	bot := int(arrays.max(vy) or {0})
	top := int(arrays.min(vy) or {0})
	right := int(arrays.max(vx) or {0})
	left := int(arrays.min(vx) or {0})

	println("bot ${bot}, top ${top}, right ${right}, left ${left}")

	mut nodes := 0
	mut j:=0
	mut nodes_x := [20]int{}
	for py in int(top) .. int(bot) {
		nodes = 0
		j=num_coreners-1
		for i in 0 .. num_coreners {
			if (points[i].y < py && points[j].y >= py) || (points[j].y < py && points[i].y >= py) {
				nodes_x[nodes] = int(points[i].x + (py - points[i].y) / (points[j].y - points[i].y) * (points[j].x - points[i].x))
				nodes += 1
			}
			j = i
		}
		// println("py ${py}, nodes ${nodes}, nodes_x ${nodes_x}")
		// bubble sort, smallest to largest
		mut i:=0
		for i < nodes - 1 {
			if nodes_x[i] > nodes_x[i+1] {
				tmp := nodes_x[i]
				nodes_x[i] = nodes_x[i+1]
				nodes_x[i+1] = tmp
				if i > 0 {
					i -= 1
				}
			} else {
				i += 1
			}
		}
		println("py ${py}, nodes ${nodes}, nodes_x ${nodes_x}")
		// filling pixels between nodes
		for i=0; i<nodes; i+=2 {
			if nodes_x[i] >= right {
				break
			}
			if nodes_x[i+1] > left {
				if nodes_x[i] < left {
					nodes_x[i] = left
				}
				if nodes_x[i+1] > right {
					nodes_x[i+1] = right
				}
				for xx in int(nodes_x[i]) .. int(nodes_x[i+1]) {
					ctx.draw_pixel(xx, py, c)
				}
			}
		}
	}
}

// pub fn (ctx &Context) draw_text(x int, y int, text string, c gx.Color) {
// 	// gx.FontDef{
// 	// 	font_size: 8
// 	// 	font_path: 'assets/fonts/RobotoMono-Regular.ttf'
// 	// })
// 	// ctx.gg_ctx.draw_text(x, y, text, c)
// 	ctx.gg_ctx.draw_text_def(x, y, text)
// }


