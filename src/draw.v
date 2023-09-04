module main

// $if rpi ? {
// 	import fbdev as gg
// } $else {
import gx
// import sokol.gfx
import math
import time
import arrays
import stbi
import gg
// }

// NOTE: in order to simulate the pixelated screen of 400x240, you need to
// change line 472 of gg.c.v to `high_dpi: false`

// these should be automatically determined from the framebuffer device
// see: https://github.com/grz0zrg/fbg/blob/master/src/fbgraphics.c for example
const (
	width       = 400
	height      = 240
	components  = 4
	line_length = width * components
)

pub struct Context {
mut:
	pixel_buffer  []u8
	fps_stopwatch time.Time
	frames        int
	fps           int
	img_id        int
	gg_ctx        &gg.Context = unsafe { nil }
	// gg_ctx       &fbdev.Context = unsafe { nil }
	font &Font = unsafe { nil }
}

pub fn create_context(user_data voidptr, frame_fn fn (voidptr), event_fn fn (&gg.Event, voidptr)) &Context { //, event_fn fn (&gg.Event, voidptr)
	mut ctx := &Context{
		pixel_buffer: []u8{len: line_length * height * components, cap: line_length * height * components, init: 0}
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
	ctx.font = default_font()

	return ctx
}

pub fn (mut ctx Context) compute_fps() {
	ctx.frames += 1
	elapsed := time.since(ctx.fps_stopwatch)
	if elapsed.nanoseconds() > 1_000_000_000 {
		ctx.fps = int(ctx.frames)
		println('fps ${ctx.fps}')
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

pub fn (mut ctx Context) quit() {
	ctx.gg_ctx.quit()
}

pub fn (mut ctx Context) clear() {
	for y in 0 .. height {
		for x in 0 .. width {
			ctx.draw_pixel(x, y, gx.white)
		}
	}
}

pub fn (mut ctx Context) blit() {
	// ---- gg ----
	mut buffer := [height][width]u32{}
	for y in 0 .. height {
		for x in 0 .. width {
			// convert from BGRA8 to RGBA8
			pos := u64(y * line_length + x * components)
			// println("pos ${pos}")
			blue := ctx.pixel_buffer[pos + 0]
			green := ctx.pixel_buffer[pos + 1]
			red := ctx.pixel_buffer[pos + 2]
			// a: ctx.pixel_buffer[u64((line_length*y+x))+3]
			buffer[y][x] = u32((red | (u32(green) << 8) | (u32(blue) << 16) | (0xFF << 24)))
		}
	}
	// see https://github.com/vlang/v/blob/007519e1300ef42a36380307cbbd248bb2940937/examples/gg/random.v
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
	x := int(x_)
	y := int(y_)

	if x < 0 || x >= width || y < 0 || y >= height {
		return
	}
	pos := u64(y * line_length + x * components)
	ctx.pixel_buffer[pos] = u8(c.b)
	ctx.pixel_buffer[pos + 1] = u8(c.g)
	ctx.pixel_buffer[pos + 2] = u8(c.r)
	ctx.pixel_buffer[pos + 3] = u8(255)
}

pub fn (mut ctx Context) draw_pixel_inv(x_ f32, y_ f32) {
	x := int(x_)
	y := int(y_)
	if x < 0 || x >= width || y < 0 || y >= height {
		return
	}
	pos := u64(y * line_length + x * components)
	ctx.pixel_buffer[pos] = ctx.pixel_buffer[pos] ^ 0xFF
	ctx.pixel_buffer[pos + 1] = ctx.pixel_buffer[pos + 1] ^ 0xFF
	ctx.pixel_buffer[pos + 2] = ctx.pixel_buffer[pos + 2] ^ 0xFF
	ctx.pixel_buffer[pos + 3] = u8(255)
}

// https://github.com/miloyip/line
// https://github.com/miloyip/line/blob/master/line_bresenham.c
pub fn (mut ctx Context) draw_line(x_0 f32, y_0 f32, x_1 f32, y_1 f32, c TColor) {
	mut x0 := int(x_0)
	mut y0 := int(y_0)
	mut x1 := int(x_1)
	mut y1 := int(y_1)

	dx := math.abs(x1 - x0)
	sx := if x0 < x1 { 1 } else { -1 }
	dy := math.abs(y1 - y0)
	sy := if y0 < y1 { 1 } else { -1 }
	mut err := (if dx > dy { dx } else { -dy }) / 2
	mut e2 := f32(0)

	for {
		if c is bool {
			ctx.draw_pixel_inv(x0, y0)
		} else if c is gx.Color {
			ctx.draw_pixel(x0, y0, c)
		}
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

pub fn (mut ctx Context) draw_rect_filled(x f32, y f32, w f32, h f32, c TColor) {
	ix := int(x)
	iy := int(y)
	iw := int(w)
	ih := int(h)

	for yy in iy .. iy + ih + 1 {
		for xx in ix .. ix + iw + 1 {
			if c is bool {
				ctx.draw_pixel_inv(xx, yy)
			} else if c is gx.Color {
				ctx.draw_pixel(xx, yy, c)
			}
		}
	}
}

pub fn (mut ctx Context) draw_rect_empty(x f32, y f32, w f32, h f32, c TColor) {
	ctx.draw_line(x, y, x + w, y, c)
	ctx.draw_line(x + w, y, x + w, y + h, c)
	ctx.draw_line(x + w, y + h, x, y + h, c)
	ctx.draw_line(x, y + h, x, y, c)
}

pub fn (mut ctx Context) draw_polygon(points []Point, c TColor) {
	for i in 0 .. points.len {
		ctx.draw_line(points[i].x, points[i].y, points[(i + 1) % points.len].x, points[(i + 1) % points.len].y,
			c)
	}
}

// https://stackoverflow.com/questions/34794720/filling-a-polygon-in-c-with-point-in-polygon-algorithm
// http://alienryderflex.com/polygon_fill/
pub fn (mut ctx Context) draw_polygon_filled(points []Point, c TColor) {
	// draw the outline since the filling algorith does not draw the outline
	// ctx.draw_polygon(points, c)

	num_coreners := points.len
	mut vx := []f32{}
	mut vy := []f32{}
	for p in points {
		vx << p.x // int(p.x)
		vy << p.y // int(p.y)
	}
	bot := arrays.max(vy) or { 0 }
	top := arrays.min(vy) or { 0 }
	right := arrays.max(vx) or { 0 }
	left := arrays.min(vx) or { 0 }

	// println("bot ${bot}, top ${top}, right ${right}, left ${left}")

	mut nodes := 0
	mut j := 0
	mut nodes_x := [20]f32{}
	// for py in int(top) .. int(bot) {
	for py := top; py < bot; py += 1 {
		// println("py ${py}")
		nodes = 0
		j = num_coreners - 1
		for i in 0 .. num_coreners {
			if (points[i].y < py && points[j].y >= py) || (points[j].y < py && points[i].y >= py) {
				nodes_x[nodes] = (points[i].x +
					(py - points[i].y) / (points[j].y - points[i].y) * (points[j].x - points[i].x))
				nodes += 1
			}
			j = i
		}
		// if py == 1 {
		// println("py ${py}, nodes ${nodes}, nodes_x ${nodes_x}")
		// }
		// bubble sort, smallest to largest
		mut i := 0
		for i < nodes - 1 {
			if nodes_x[i] > nodes_x[i + 1] {
				tmp := nodes_x[i]
				nodes_x[i] = nodes_x[i + 1]
				nodes_x[i + 1] = tmp
				if i > 0 {
					i -= 1
				}
			} else {
				i += 1
			}
		}
		// println("py ${py}, nodes ${nodes}, nodes_x ${nodes_x}")
		// filling pixels between nodes
		for i = 0; i < nodes; i += 2 {
			if nodes_x[i] >= right {
				break
			}
			if nodes_x[i + 1] > left {
				if nodes_x[i] < left {
					nodes_x[i] = left
				}
				if nodes_x[i + 1] > right {
					nodes_x[i + 1] = right
				}
				for xx in int(nodes_x[i]) .. int(nodes_x[i + 1]) {
					if c is bool {
						ctx.draw_pixel_inv(xx, py)
					} else if c is gx.Color {
						ctx.draw_pixel(xx, py, c)
					}
					// ctx.draw_pixel(xx, py, c)
				}
			}
		}
	}
}

// pub struct Image {
// mut:
// 	width int
// 	height int
// 	data []u8
// }

pub struct Font {
mut:
	glyph_coord_x []int
	glyph_coord_y []int
	glyph_width   int
	glyph_height  int
	first_char    u8
	colorkey      u32
	bitmap        stbi.Image
}

pub fn default_font() &Font {
	mut embedded_font_file := $embed_file('thirdparty/fbg/examples/bbmode1_8x8.png')
	glyph_width := 8
	glyph_height := 8
	first_char := u8(33) // u8
	// data := embedded_font_file.to_bytes()
	data := embedded_font_file.data()
	mut img := stbi.load_from_memory(data, embedded_font_file.len, stbi.LoadParams{
		desired_channels: 1
	}) or { panic('failed to load image') }
	// d := arrays.carray_to_varray[u8](img.data, img.width * img.height * img.nr_channels)
	// println("image ${d}")

	mut font := &Font{
		glyph_coord_x: []int{len: 256, cap: 256, init: 0}
		glyph_coord_y: []int{len: 256, cap: 256, init: 0}
		glyph_width: glyph_width
		glyph_height: glyph_height
		first_char: first_char // u8
		colorkey: 0
		bitmap: img
	}

	glyph_count := (img.width / glyph_width) * (img.height / glyph_height)
	for i in 0 .. glyph_count {
		gcoord := i * glyph_width
		gcoordx := gcoord % img.width
		gcoordy := (gcoord / img.width) * glyph_height

		font.glyph_coord_x[i] = gcoordx
		font.glyph_coord_y[i] = gcoordy
	}

	return font
}

pub fn (mut ctx Context) draw_text(x int, y int, text string, color gx.Color) {
	mut c := 0
	mut y_ := y

	data := unsafe {
		arrays.carray_to_varray[u8](ctx.font.bitmap.data, ctx.font.bitmap.width * ctx.font.bitmap.height * ctx.font.bitmap.nr_channels)
	}

	for i in 0 .. text.len {
		glyph := text[i]

		if glyph == ' '.bytes()[0] {
			// fbg_recta(fbg, x + c * fnt->glyph_width, y, fnt->glyph_width, fnt->glyph_height, fbg->text_background.r, fbg->text_background.g, fbg->text_background.b, fbg->text_alpha)
			c += 1
			continue
		}

		if glyph == '\n'.bytes()[0] {
			c = 0
			y_ += ctx.font.glyph_height
			continue
		}

		font_glyph := glyph - ctx.font.first_char

		gcoordx := ctx.font.glyph_coord_x[font_glyph]
		gcoordy := ctx.font.glyph_coord_y[font_glyph]
		// println("font_glyph ${glyph.ascii_str()} ${font_glyph} ${gcoordx} ${gcoordy}")

		for gy in 0 .. ctx.font.glyph_height {
			ly := gcoordy + gy
			fly := ly * ctx.font.bitmap.width
			py := y_ + gy

			for gx in 0 .. ctx.font.glyph_width {
				lx := gcoordx + gx
				// println("lx ${lx}, ly ${ly}, fly ${fly}, gx ${gx}, gy ${gy}, ly ${ly} = i ${(fly + lx) * ctx.font.bitmap.nr_channels}")
				fl := data[(fly + lx) * ctx.font.bitmap.nr_channels]
				// println("fl ${fl}")

				if fl == ctx.font.colorkey {
					// fbg_pixela(fbg, x + gx + c * font.glyph_width, py, fbg.text_background.r, fbg.text_background.g, fbg.text_background.b, fbg.text_alpha)
				} else {
					// fbg_pixel(fbg, x + gx + c * font.glyph_width, py, r, g, b)
					ctx.draw_pixel(x + gx + c * ctx.font.glyph_width, py, color)
				}
			}
		}

		c += 1
	}
}
