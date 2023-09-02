[translated]
module fbg

// import time
import libs.fbg.c

const (
	used_import = c.used_import
)

// fn C.time(__timer &Time_t) Time_t

// pub fn time(__timer &Time_t) Time_t {
// 	return C.time(__timer)
// }

// enum __itimer_which {
// 	itimer_real = 0	itimer_virtual = 1	itimer_prof = 2}

// struct Itimer_which_t {
// 	it_interval Timeval
// 	it_value Timeval
// }

// const ( // empty enum
// 	fp_nan = 0	fp_infinite = 1	fp_zero = 2	fp_subnormal = 3	fp_normal = 4)

struct Fbg_rgb {
pub mut:
	r u8
	g u8
	b u8
	a u8
}
// struct Fbg_hsl {
// 	h int
// 	s f32
// 	l f32
// }
struct Fbg_img {
pub mut:
	data &u8
	width u32
	height u32
}
struct Fbg_font {
pub mut:
	glyph_coord_x &int
	glyph_coord_y &int
	glyph_width int
	glyph_height int
	first_char u8
	bitmap &Fbg_img
}
pub struct Fbg {
pub mut:
	size int
	disp_buffer &u8
	back_buffer &u8
	temp_buffer &u8
	allow_resizing int
	initialize_buffers int
	fill_color Fbg_rgb
	text_color Fbg_rgb
	text_background Fbg_rgb
	text_colorkey u8
	text_alpha int
	current_font Fbg_font
	width int
	height int
	width_n_height int
	components int
	comp_offset int
	line_length int
	new_width int
	new_height int
	fps i16
	fps_char [10]i8
	fps_start C.timeval
	fps_stop C.timeval
	frame int
	bgr int
	backend_resize fn (&Fbg, u32, u32)
	user_resize fn (&Fbg, u32, u32)
	user_flip fn (&Fbg)
	user_draw fn (&Fbg)
	user_free fn (&Fbg)
	user_context voidptr
}
fn C.fbg_customSetup(width int, height int, components int, initialize_buffers int, allow_resizing int, user_context voidptr, user_draw fn (&Fbg), user_flip fn (&Fbg), backend_resize fn (&Fbg, u32, u32), user_free fn (&Fbg)) &Fbg

pub fn fbg_customsetup(width int, height int, components int, initialize_buffers int, allow_resizing int, user_context voidptr, user_draw fn (&Fbg), user_flip fn (&Fbg), backend_resize fn (&Fbg, u32, u32), user_free fn (&Fbg)) &Fbg {
	return C.fbg_customSetup(width, height, components, initialize_buffers, allow_resizing, user_context, user_draw, user_flip, backend_resize, user_free)
}

// fn C.fbg_close(fbg &fbg)

// pub fn fbg_close(fbg &fbg)  {
// 	C.fbg_close(fbg)
// }

// fn C.fbg_setResizeCallback(fbg &fbg, user_resize fn (&fbg, u32, u32))

// pub fn fbg_setresizecallback(fbg &fbg, user_resize fn (&fbg, u32, u32))  {
// 	C.fbg_setResizeCallback(fbg, user_resize)
// }

// fn C.fbg_resize(fbg &fbg, new_width int, new_height int)

// pub fn fbg_resize(fbg &fbg, new_width int, new_height int)  {
// 	C.fbg_resize(fbg, new_width, new_height)
// }

// fn C.fbg_pushResize(fbg &fbg, new_width int, new_height int)

// pub fn fbg_pushresize(fbg &fbg, new_width int, new_height int)  {
// 	C.fbg_pushResize(fbg, new_width, new_height)
// }

// fn C.fbg_fadeDown(fbg &fbg, rgb_fade_amount u8)

// pub fn fbg_fadedown(fbg &fbg, rgb_fade_amount u8)  {
// 	C.fbg_fadeDown(fbg, rgb_fade_amount)
// }

// fn C.fbg_fadeUp(fbg &fbg, rgb_fade_amount u8)

// pub fn fbg_fadeup(fbg &fbg, rgb_fade_amount u8)  {
// 	C.fbg_fadeUp(fbg, rgb_fade_amount)
// }

fn C.fbg_clear(fbg &Fbg, brightness u8)

pub fn fbg_clear(fbg &Fbg, brightness u8)  {
	C.fbg_clear(fbg, brightness)
}

// fn C.fbg_fill(fbg &fbg, r u8, g u8, b u8)

// pub fn fbg_fill(fbg &fbg, r u8, g u8, b u8)  {
// 	C.fbg_fill(fbg, r, g, b)
// }

// fn C.fbg_getPixel(fbg &fbg, x int, y int, color &fbg_rgb)

// pub fn fbg_getpixel(fbg &fbg, x int, y int, color &fbg_rgb)  {
// 	C.fbg_getPixel(fbg, x, y, color)
// }

fn C.fbg_pixel(fbg &Fbg, x int, y int, r u8, g u8, b u8)

pub fn fbg_pixel(fbg &Fbg, x int, y int, r u8, g u8, b u8)  {
	C.fbg_pixel(fbg, x, y, r, g, b)
}

// fn C.fbg_pixela(fbg &fbg, x int, y int, r u8, g u8, b u8, a u8)

// pub fn fbg_pixela(fbg &fbg, x int, y int, r u8, g u8, b u8, a u8)  {
// 	C.fbg_pixela(fbg, x, y, r, g, b, a)
// }

// fn C.fbg_fpixel(fbg &fbg, x int, y int)

// pub fn fbg_fpixel(fbg &fbg, x int, y int)  {
// 	C.fbg_fpixel(fbg, x, y)
// }

// fn C.fbg_plot(fbg &fbg, index int, value u8)

// pub fn fbg_plot(fbg &fbg, index int, value u8)  {
// 	C.fbg_plot(fbg, index, value)
// }

fn C.fbg_rect(fbg &Fbg, x int, y int, w int, h int, r u8, g u8, b u8)

pub fn fbg_rect(fbg &Fbg, x int, y int, w int, h int, r u8, g u8, b u8)  {
	C.fbg_rect(fbg, x, y, w, h, r, g, b)
}

// fn C.fbg_recta(fbg &fbg, x int, y int, w int, h int, r u8, g u8, b u8, a u8)

// pub fn fbg_recta(fbg &fbg, x int, y int, w int, h int, r u8, g u8, b u8, a u8)  {
// 	C.fbg_recta(fbg, x, y, w, h, r, g, b, a)
// }

// fn C.fbg_frect(fbg &fbg, x int, y int, w int, h int)

// pub fn fbg_frect(fbg &fbg, x int, y int, w int, h int)  {
// 	C.fbg_frect(fbg, x, y, w, h)
// }

// fn C.fbg_hline(fbg &fbg, x int, y int, w int, r u8, g u8, b u8)

// pub fn fbg_hline(fbg &fbg, x int, y int, w int, r u8, g u8, b u8)  {
// 	C.fbg_hline(fbg, x, y, w, r, g, b)
// }

// fn C.fbg_vline(fbg &fbg, x int, y int, h int, r u8, g u8, b u8)

// pub fn fbg_vline(fbg &fbg, x int, y int, h int, r u8, g u8, b u8)  {
// 	C.fbg_vline(fbg, x, y, h, r, g, b)
// }

// fn C.fbg_line(fbg &fbg, x1 int, y1 int, x2 int, y2 int, r u8, g u8, b u8)

// pub fn fbg_line(fbg &fbg, x1 int, y1 int, x2 int, y2 int, r u8, g u8, b u8)  {
// 	C.fbg_line(fbg, x1, y1, x2, y2, r, g, b)
// }

// fn C.fbg_polygon(fbg &fbg, num_vertices int, vertices &int, r u8, g u8, b u8)

// pub fn fbg_polygon(fbg &fbg, num_vertices int, vertices &int, r u8, g u8, b u8)  {
// 	C.fbg_polygon(fbg, num_vertices, vertices, r, g, b)
// }

fn C.fbg_background(fbg &Fbg, r u8, g u8, b u8)

pub fn fbg_background(fbg &Fbg, r u8, g u8, b u8)  {
	C.fbg_background(fbg, r, g, b)
}

// fn C.fbg_hslToRGB(color &fbg_rgb, h f32, s f32, l f32)

// pub fn fbg_hsltorgb(color &fbg_rgb, h f32, s f32, l f32)  {
// 	C.fbg_hslToRGB(color, h, s, l)
// }

// fn C.fbg_rgbToHsl(color &fbg_hsl, r f32, g f32, b f32)

// pub fn fbg_rgbtohsl(color &fbg_hsl, r f32, g f32, b f32)  {
// 	C.fbg_rgbToHsl(color, r, g, b)
// }

fn C.fbg_draw(fbg &Fbg)

pub fn fbg_draw(fbg &Fbg)  {
	C.fbg_draw(fbg)
}

fn C.fbg_flip(fbg &Fbg)

pub fn fbg_flip(fbg &Fbg)  {
	C.fbg_flip(fbg)
}

// fn C.fbg_createImage(fbg &fbg, width u32, height u32) &fbg_img

// pub fn fbg_createimage(fbg &fbg, width u32, height u32) &fbg_img {
// 	return C.fbg_createImage(fbg, width, height)
// }

// fn C.fbg_loadPNG(fbg &fbg, filename &i8) &fbg_img

// pub fn fbg_loadpng(fbg &fbg, filename &i8) &fbg_img {
// 	return C.fbg_loadPNG(fbg, filename)
// }

// fn C.fbg_loadJPEG(fbg &fbg, filename &i8) &fbg_img

// pub fn fbg_loadjpeg(fbg &fbg, filename &i8) &fbg_img {
// 	return C.fbg_loadJPEG(fbg, filename)
// }

// fn C.fbg_loadSTBImage(fbg &fbg, filename &i8) &fbg_img

// pub fn fbg_loadstbimage(fbg &fbg, filename &i8) &fbg_img {
// 	return C.fbg_loadSTBImage(fbg, filename)
// }

// fn C.fbg_loadImage(fbg &fbg, filename &i8) &fbg_img

// pub fn fbg_loadimage(fbg &fbg, filename &i8) &fbg_img {
// 	return C.fbg_loadImage(fbg, filename)
// }

// fn C.fbg_loadSTBImageFromMemory(fbg &fbg, data &u8, size int) &fbg_img

// pub fn fbg_loadstbimagefrommemory(fbg &fbg, data &u8, size int) &fbg_img {
// 	return C.fbg_loadSTBImageFromMemory(fbg, data, size)
// }

// fn C.fbg_loadImageFromMemory(fbg &fbg, data &u8, size int) &fbg_img

// pub fn fbg_loadimagefrommemory(fbg &fbg, data &u8, size int) &fbg_img {
// 	return C.fbg_loadImageFromMemory(fbg, data, size)
// }

// fn C.fbg_image(fbg &fbg, img &fbg_img, x int, y int)

// pub fn fbg_image(fbg &fbg, img &fbg_img, x int, y int)  {
// 	C.fbg_image(fbg, img, x, y)
// }

// fn C.fbg_imageColorkey(fbg &fbg, img &fbg_img, x int, y int, cr int, cg int, cb int)

// pub fn fbg_imagecolorkey(fbg &fbg, img &fbg_img, x int, y int, cr int, cg int, cb int)  {
// 	C.fbg_imageColorkey(fbg, img, x, y, cr, cg, cb)
// }

// fn C.fbg_imageClip(fbg &fbg, img &fbg_img, x int, y int, cx int, cy int, cw int, ch int)

// pub fn fbg_imageclip(fbg &fbg, img &fbg_img, x int, y int, cx int, cy int, cw int, ch int)  {
// 	C.fbg_imageClip(fbg, img, x, y, cx, cy, cw, ch)
// }

// fn C.fbg_imageFlip(img &fbg_img)

// pub fn fbg_imageflip(img &fbg_img)  {
// 	C.fbg_imageFlip(img)
// }

// fn C.fbg_imageEx(fbg &fbg, img &fbg_img, x int, y int, sx f32, sy f32, cx int, cy int, cw int, ch int)

// pub fn fbg_imageex(fbg &fbg, img &fbg_img, x int, y int, sx f32, sy f32, cx int, cy int, cw int, ch int)  {
// 	C.fbg_imageEx(fbg, img, x, y, sx, sy, cx, cy, cw, ch)
// }

// fn C.fbg_freeImage(img &fbg_img)

// pub fn fbg_freeimage(img &fbg_img)  {
// 	C.fbg_freeImage(img)
// }

// fn C.fbg_createFont(fbg &fbg, img &fbg_img, glyph_width int, glyph_height int, first_char u8) &fbg_font

// pub fn fbg_createfont(fbg &fbg, img &fbg_img, glyph_width int, glyph_height int, first_char u8) &fbg_font {
// 	return C.fbg_createFont(fbg, img, glyph_width, glyph_height, first_char)
// }

// fn C.fbg_textFont(fbg &fbg, font &fbg_font)

// pub fn fbg_textfont(fbg &fbg, font &fbg_font)  {
// 	C.fbg_textFont(fbg, font)
// }

// fn C.fbg_textColor(fbg &fbg, r u8, g u8, b u8)

// pub fn fbg_textcolor(fbg &fbg, r u8, g u8, b u8)  {
// 	C.fbg_textColor(fbg, r, g, b)
// }

// fn C.fbg_textBackground(fbg &fbg, r int, g int, b int, a int)

// pub fn fbg_textbackground(fbg &fbg, r int, g int, b int, a int)  {
// 	C.fbg_textBackground(fbg, r, g, b, a)
// }

// fn C.fbg_textColorKey(fbg &fbg, v u8)

// pub fn fbg_textcolorkey(fbg &fbg, v u8)  {
// 	C.fbg_textColorKey(fbg, v)
// }

// fn C.fbg_text(fbg &fbg, fnt &fbg_font, text &i8, x int, y int, r int, g int, b int)

// pub fn fbg_text(fbg &fbg, fnt &fbg_font, text &i8, x int, y int, r int, g int, b int)  {
// 	C.fbg_text(fbg, fnt, text, x, y, r, g, b)
// }

// fn C.fbg_freeFont(font &fbg_font)

// pub fn fbg_freefont(font &fbg_font)  {
// 	C.fbg_freeFont(font)
// }

// fn C.fbg_drawFramerate(fbg &fbg, fnt &fbg_font, task int, x int, y int, r int, g int, b int)

// pub fn fbg_drawframerate(fbg &fbg, fnt &fbg_font, task int, x int, y int, r int, g int, b int)  {
// 	C.fbg_drawFramerate(fbg, fnt, task, x, y, r, g, b)
// }

// fn C.fbg_getFramerate(fbg &fbg, task int) int

// pub fn fbg_getframerate(fbg &fbg, task int) int {
// 	return C.fbg_getFramerate(fbg, task)
// }

// fn C.fbg_drawInto(fbg &fbg, buffer &u8)

// pub fn fbg_drawinto(fbg &fbg, buffer &u8)  {
// 	C.fbg_drawInto(fbg, buffer)
// }

// fn C.fbg_randf(min f32, max f32) f32

// pub fn fbg_randf(min f32, max f32) f32 {
// 	return C.fbg_randf(min, max)
// }

