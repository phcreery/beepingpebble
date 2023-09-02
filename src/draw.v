module main

import gx
// import draw_gg
// import gg
import libs.fbg

// pub struct Color {
// pub mut:
// 	a u8 = 255
// }

pub enum Color {
	black
	write
}

// pub interface IBPApp {
// 	ctx IBPContext
// 	create_context(fn (voidptr)) IBPContext
// 	run()
// }

// TODO: remove img_id, gg_ctx, draw_test_image

pub interface IBPContext {
	// draw_text(x int, y int, text string, c gx.Color)
mut:
	fbg_ctx &fbg.Fbg
	clear()
	// draw_test_image()
	// draw_rect_empty(x f32, y f32, w f32, h f32, c gx.Color)
	draw_rect_filled(x f32, y f32, w f32, h f32, c gx.Color)
	// draw_rect_filled_inv(x f32, y f32, w f32, h f32)
	// draw_line(x f32, y f32, x2 f32, y2 f32, c gx.Color)
	// draw_line_inv(x f32, y f32, x2 f32, y2 f32)
	run()
}
