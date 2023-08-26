[translated]
module fbg_fbdev

import libs.fbg

// struct Fb_bitfield { 
// 	offset u32
// 	length u32
// 	msb_right u32
// }
// struct Fb_var_screeninfo { 
// 	xres u32
// 	yres u32
// 	xres_virtual u32
// 	yres_virtual u32
// 	xoffset u32
// 	yoffset u32
// 	bits_per_pixel u32
// 	grayscale u32
// 	red Fb_bitfield
// 	green Fb_bitfield
// 	blue Fb_bitfield
// 	transp Fb_bitfield
// 	nonstd u32
// 	activate u32
// 	height u32
// 	width u32
// 	accel_flags u32
// 	pixclock u32
// 	left_margin u32
// 	right_margin u32
// 	upper_margin u32
// 	lower_margin u32
// 	hsync_len u32
// 	vsync_len u32
// 	sync u32
// 	vmode u32
// 	rotate u32
// 	colorspace u32
// 	reserved [4]u32
// }
// struct Fb_cmap { 
// 	start u32
// 	len u32
// 	red &u16
// 	green &u16
// 	blue &u16
// 	transp &u16
// }
// struct Fb_con2fbmap { 
// 	console u32
// 	framebuffer u32
// }

// const ( // empty enum
// 	fb_blank_unblank = 0	fb_blank_normal = 0 + 1	fb_blank_vsync_suspend = 1 + 1	fb_blank_hsync_suspend = 2 + 1	fb_blank_powerdown = 3 + 1)

// struct Fb_vblank { 
// 	flags u32
// 	count u32
// 	vcount u32
// 	hcount u32
// 	reserved [4]u32
// }
// struct Fb_copyarea { 
// 	dx u32
// 	dy u32
// 	width u32
// 	height u32
// 	sx u32
// 	sy u32
// }
// struct Fb_dmacopy { 
// 	dst voidptr
// 	src u32
// 	length u32
// }
// struct Fb_fillrect { 
// 	dx u32
// 	dy u32
// 	width u32
// 	height u32
// 	color u32
// 	rop u32
// }
// struct Fb_image { 
// 	dx u32
// 	dy u32
// 	width u32
// 	height u32
// 	fg_color u32
// 	bg_color u32
// 	depth u8
// 	data &i8
// 	cmap Fb_cmap
// }
// struct Fbcurpos { 
// 	x u16
// 	y u16
// }
// struct Size_t { 
// 	set u16
// 	enable u16
// 	rop u16
// 	mask &i8
// 	hot Fbcurpos
// 	image Fb_image
// }
// enum __itimer_which {
// 	itimer_real = 0	itimer_virtual = 1	itimer_prof = 2}

// struct Itimer_which_t { 
// 	it_interval Timeval
// 	it_value Timeval
// }

// const ( // empty enum
// 	fp_nan = 0	fp_infinite = 1	fp_zero = 2	fp_subnormal = 3	fp_normal = 4)

// struct Fbg_rgb { 
// 	r u8
// 	g u8
// 	b u8
// 	a u8
// }
// struct Fbg_hsl { 
// 	h int
// 	s f32
// 	l f32
// }
// struct Fbg_img { 
// 	data &u8
// 	width u32
// 	height u32
// }
// struct Fbg_font { 
// 	glyph_coord_x &int
// 	glyph_coord_y &int
// 	glyph_width int
// 	glyph_height int
// 	first_char u8
// 	bitmap &fbg_img
// }
// struct Fbg { 
// 	size int
// 	disp_buffer &u8
// 	back_buffer &u8
// 	temp_buffer &u8
// 	allow_resizing int
// 	initialize_buffers int
// 	fill_color fbg_rgb
// 	text_color fbg_rgb
// 	text_background fbg_rgb
// 	text_colorkey u8
// 	text_alpha int
// 	current_font fbg_font
// 	width int
// 	height int
// 	width_n_height int
// 	components int
// 	comp_offset int
// 	line_length int
// 	new_width int
// 	new_height int
// 	fps i16
// 	fps_char [10]i8
// 	fps_start Timeval
// 	fps_stop Timeval
// 	frame int
// 	bgr int
// 	backend_resize fn (&fbg, u32, u32)
// 	user_resize fn (&fbg, u32, u32)
// 	user_flip fn (&fbg)
// 	user_draw fn (&fbg)
// 	user_free fn (&fbg)
// 	user_context voidptr
// }
// struct Fbg_fbdev_context { 
// 	fd int
// 	buffer &u8
// 	vinfo Fb_var_screeninfo
// 	finfo Fb_fix_screeninfo
// 	page_flipping int
// }

fn C.fbg_fbdevSetup(fb_device &char, page_flipping int) &fbg.Fbg

pub fn fbg_fbdevsetup(fb_device &char, page_flipping int) &fbg.Fbg {
	return C.fbg_fbdevSetup(fb_device, page_flipping)
}

