module main

import math
import time
import arrays
import stbi
import gx
import bmfont

import hw

// NOTE: in order to simulate the pixelated screen of 400x240, you need to
// change line 472 of hw.c.v to `high_dpi: false`

// these should be automatically determined from the framebuffer device
// see: https://github.com/grz0zrg/fbg/blob/master/src/fbgraphics.c for example
// TODO: remove these globals
const (
	width       = 400
	height      = 240
	components  = 4
	line_length = width * components
)

pub struct DrawContext {
mut:
	pixel_buffer  []u8
	width         int
	height        int
	components    int
	fps_stopwatch time.Time
	frames        int
	fps           int
	img_id        int
	hw_ctx        &hw.Context = unsafe { nil }
	font 		&bmfont.Font = unsafe { nil }
	icons 		map[string]stbi.Image
}

pub fn create_context(user_data voidptr, frame_fn fn (voidptr), event_fn fn (voidptr, voidptr)) &DrawContext { //, event_fn fn (&hw.Event, voidptr)

	mut dwg := &DrawContext{
		pixel_buffer: []u8{len: line_length * height * components, cap: line_length * height * components, init: 0}
		width: width
		height: height
		hw_ctx: &hw.Context{}
	}


	// ---- genaric ----
	dwg.hw_ctx = hw.new_context(
		bg_color: gx.white
		width: width
		height: height

		frame_fn: frame_fn
		event_fn: event_fn
		user_data: user_data
	)

	dwg.fps_stopwatch = time.now()
	// dwg.font = default_font()
	dwg.font = bmfont.load_fnt('test')
	dwg.icons = load_icons()

	return dwg
}

pub fn (mut dwg DrawContext) compute_fps() {
	dwg.frames += 1
	elapsed := time.since(dwg.fps_stopwatch)
	if elapsed.nanoseconds() > 1_000_000_000 {
		dwg.fps = int(dwg.frames)
		// println('fps ${dwg.fps}')
		dwg.frames = 0
		dwg.fps_stopwatch = time.now()
	}
}

pub fn (dwg &DrawContext) begin() {
	dwg.hw_ctx.begin()
}

pub fn (mut dwg DrawContext) end() {
	dwg.compute_fps()
	dwg.blit()
	dwg.hw_ctx.end()
}

pub fn (mut dwg DrawContext) run() {
	dwg.hw_ctx.run()
}

pub fn (mut dwg DrawContext) quit() {
	dwg.hw_ctx.quit()
}


[direct_array_access]
pub fn (mut dwg DrawContext) clear(c gx.Color) {
	for y in 0 .. height {
		for x in 0 .. width {
			dwg.draw_pixel(x, y, c)
		}
	}
}

pub fn (mut dwg DrawContext) blit() {
	dwg.hw_ctx.blit(dwg.pixel_buffer)
}

[inline]
[direct_array_access]
pub fn (mut dwg DrawContext) draw_pixel(x_ f32, y_ f32, c gx.Color) {
	x := int(x_)
	y := int(y_)

	if x < 0 || x >= width || y < 0 || y >= height {
		return
	}
	pos := u64(y * line_length + x * components)
	dwg.pixel_buffer[pos] = u8(c.b)
	dwg.pixel_buffer[pos + 1] = u8(c.g)
	dwg.pixel_buffer[pos + 2] = u8(c.r)
	dwg.pixel_buffer[pos + 3] = u8(255)
}

[inline]
[direct_array_access]
pub fn (mut dwg DrawContext) draw_pixel_inv(x_ f32, y_ f32) {
	x := int(x_)
	y := int(y_)
	if x < 0 || x >= width || y < 0 || y >= height {
		return
	}
	pos := u64(y * line_length + x * components)
	dwg.pixel_buffer[pos] = dwg.pixel_buffer[pos] ^ 0xFF
	dwg.pixel_buffer[pos + 1] = dwg.pixel_buffer[pos + 1] ^ 0xFF
	dwg.pixel_buffer[pos + 2] = dwg.pixel_buffer[pos + 2] ^ 0xFF
	dwg.pixel_buffer[pos + 3] = u8(255)
}

// https://github.com/miloyip/line
// https://github.com/miloyip/line/blob/master/line_bresenham.c
pub fn (mut dwg DrawContext) draw_line(x_0 f32, y_0 f32, x_1 f32, y_1 f32, c TColor) {
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
			dwg.draw_pixel_inv(x0, y0)
		} else if c is gx.Color {
			dwg.draw_pixel(x0, y0, c)
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

pub fn (mut dwg DrawContext) draw_rect_filled(x f32, y f32, w f32, h f32, c TColor) {
	ix := int(x)
	iy := int(y)
	iw := int(w)
	ih := int(h)

	for yy in iy .. iy + ih + 1 {
		for xx in ix .. ix + iw + 1 {
			if c is bool {
				dwg.draw_pixel_inv(xx, yy)
			} else if c is gx.Color {
				dwg.draw_pixel(xx, yy, c)
			}
		}
	}
}

pub fn (mut dwg DrawContext) draw_rect_empty(x f32, y f32, w f32, h f32, c TColor) {
	dwg.draw_line(x, y, x + w, y, c)
	dwg.draw_line(x + w, y, x + w, y + h, c)
	dwg.draw_line(x + w, y + h, x, y + h, c)
	dwg.draw_line(x, y + h, x, y, c)
}

pub fn (mut dwg DrawContext) draw_polygon(points []Point, c TColor) {
	for i in 0 .. points.len {
		dwg.draw_line(points[i].x, points[i].y, points[(i + 1) % points.len].x, points[(i + 1) % points.len].y,
			c)
	}
}

// https://stackoverflow.com/questions/34794720/filling-a-polygon-in-c-with-point-in-polygon-algorithm
// http://alienryderflex.com/polygon_fill/
[direct_array_access]
pub fn (mut dwg DrawContext) draw_polygon_filled(points []Point, c TColor) {
	// draw the outline since the filling algorith does not draw the outline
	// dwg.draw_polygon(points, c)
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
						dwg.draw_pixel_inv(xx, py)
					} else if c is gx.Color {
						dwg.draw_pixel(xx, py, c)
					}
				}
			}
		}
	}
}

// [deprecated: 'use draw_bmfont_text() instead']
// [direct_array_access]
// pub fn (mut dwg DrawContext) draw_text(x int, y int, text string, color TColor) {
// 	mut c := 0
// 	mut y_ := y


// 	for i in 0 .. text.len {
// 		glyph := text[i]

// 		if glyph == ' '.bytes()[0] {
// 			// draw a backdrop rectangle
// 			// fbg_recta(fbg, x + c * fnt->glyph_width, y, fnt->glyph_width, fnt->glyph_height, fbg->text_background.r, fbg->text_background.g, fbg->text_background.b, fbg->text_alpha)
// 			c += 1
// 			continue
// 		}

// 		if glyph == '\n'.bytes()[0] {
// 			c = 0
// 			y_ += dwg.font.glyph_height
// 			continue
// 		}

// 		font_glyph := glyph - dwg.font.first_char

// 		gcoordx := dwg.font.glyph_coord_x[font_glyph]
// 		gcoordy := dwg.font.glyph_coord_y[font_glyph]
// 		// println("font_glyph ${glyph.ascii_str()} ${font_glyph} ${gcoordx} ${gcoordy}")

// 		for gy in 0 .. dwg.font.glyph_height {
// 			ly := gcoordy + gy
// 			fly := ly * dwg.font.bitmap.stbiimg.width
// 			py := y_ + gy

// 			for gx in 0 .. dwg.font.glyph_width {
// 				lx := gcoordx + gx
// 				fl := dwg.font.bitmap.data[(fly + lx) * dwg.font.bitmap.stbiimg.nr_channels]

// 				if fl == dwg.font.colorkey {
// 					// draw a backdrop pixel
// 					// fbg_pixela(fbg, x + gx + c * font.glyph_width, py, fbg.text_background.r, fbg.text_background.g, fbg.text_background.b, fbg.text_alpha)
// 				} else {
// 					// fbg_pixel(fbg, x + gx + c * font.glyph_width, py, r, g, b)
// 					if color is bool {
// 						dwg.draw_pixel_inv(x + gx + c * dwg.font.glyph_width, py)
// 					} else if color is gx.Color {
// 						dwg.draw_pixel(x + gx + c * dwg.font.glyph_width, py, color)
// 					}
// 				}
// 			}
// 		}

// 		c += 1
// 	}
// }

[direct_array_access]
pub fn (mut dwg DrawContext) draw_text(x int, y int, text string, color TColor) int {
	mut xadvance_tracker := 0

	// println('asdf'.bytes().bytestr())
	// for ch in text.bytes() {
	for ru in text.runes() {
		ch := int(ru.bytes().utf8_to_utf32() or { 0 })
		character := dwg.font.chars[ch]
		for local_y in 0..character.height {
			for local_x in 0..character.width {
				if dwg.font.get_pixel(0, local_x + character.x, local_y + character.y) > 127 {
					if color is bool {
						dwg.draw_pixel_inv(x + local_x + character.xoffset + xadvance_tracker, y + local_y + character.yoffset)
					} else if color is gx.Color {
						dwg.draw_pixel(x + local_x + character.xoffset + xadvance_tracker, y + local_y + character.yoffset, color)
					}
				} else {
					// print(' ')
				}
			}
			// println('')
		}
		xadvance_tracker += character.xadvance
	}
	return xadvance_tracker
}


// [direct_array_access]
pub fn (mut dwg DrawContext) draw_image(x int, y int, img &stbi.Image, color TColor) {
	// TODO: make it faster with a memcpy?
	// See https://github.com/grz0zrg/fbg/blob/master/src/fbgraphics.c#L1520C11-L1520C11
	data := unsafe {
		arrays.carray_to_varray[u8](img.data, img.width * img.height * img.nr_channels)
	}
	img_line_length := img.width * img.nr_channels
	mut greyscale:=f32(0)
	mut pos:=u64(0)
	mut blue:=u8(0)
	mut green:=u8(0)
	mut red:=u8(0)
	mut alpha:=u8(0)
	for yy in 0 .. img.height {
		for xx in 0 .. img.width {
			pos = u64(yy * img_line_length + xx * img.nr_channels)
			blue = data[pos + 0]
			green = data[pos + 1]
			red = data[pos + 2]
			alpha = data[pos + 3]
			if alpha < 225 / 2 {
				continue
			}
			greyscale = 0.3 * f32(red) + 0.59 * f32(green) + 0.11 * f32(blue)
			if greyscale < 255 / 2 {
				if color is bool {
					dwg.draw_pixel_inv(x + xx, y + yy)
				} else if color is gx.Color {
					dwg.draw_pixel(x + xx, y + yy, color)
				}
			} else {
				// background
				// dwg.draw_pixel(x + xx, y + yy, gx.white)
			}
		}
	}
}
