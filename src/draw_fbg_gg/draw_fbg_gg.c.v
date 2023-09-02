module draw_fbg_gg

import gg
import gx
import libs.fbg

const (
	width  = 400
	height = 240
)

struct Context_fbg_gg {
mut:
	pixel_buffer [height][width]u32
	img_id       int
	gg_ctx       &gg.Context = unsafe { nil }
	fbg_ctx      &fbg.Fbg    = unsafe { nil }
}

pub fn fbg_gg_setup(user_data voidptr, frame_fn fn (voidptr), event_fn fn (&gg.Event, voidptr)) &Context_fbg_gg {
	mut ctx := &Context_fbg_gg{
		img_id: 1
		gg_ctx: &gg.Context{}
		fbg_ctx: &fbg.Fbg{}
	}

	ctx.fbg_ctx = fbg.fbg_customsetup(draw_fbg_gg.width, draw_fbg_gg.height, 3, 1, 0,
		ctx, fbg_gg_draw, unsafe { nil }, unsafe { nil }, unsafe { nil })

	gg_frame_fn := fn [user_data, ctx, frame_fn] (_ voidptr) {
		fbg.fbg_clear(ctx.fbg_ctx, 0)
		fbg.fbg_draw(ctx.fbg_ctx) // basically fbg_gg_draw()

		// ctx.pixel_buffer[0][0] = 0xFF000000
		frame_fn(user_data)

		fbg.fbg_flip(ctx.fbg_ctx)
	}

	println('2')

	ctx.gg_ctx = gg.new_context(
		bg_color: gx.white
		width: draw_fbg_gg.width
		height: draw_fbg_gg.height
		create_window: true
		window_title: 'BEEPINGPEBBLE'
		// init_fn: init_fn
		// init_fn: graphics_init
		init_fn: fn [mut ctx] (_ voidptr) {
			ctx.img_id = ctx.gg_ctx.new_streaming_image(draw_fbg_gg.width, draw_fbg_gg.height,
				4,
				pixel_format: .rgba8
			)
		}
		frame_fn: gg_frame_fn
		// frame_fn
		event_fn: event_fn
		user_data: user_data
	)

	return ctx
}

pub fn (mut ctx Context_fbg_gg) run() {
	ctx.gg_ctx.run()
}

pub fn fbg_gg_draw(fbg_ctx &fbg.Fbg) {
	mut ctx := unsafe { &Context_fbg_gg(fbg_ctx.user_context) }
	// println('0x${ctx.pixel_buffer[0][0]:X}')

	// first, copy the fbg buffer to pixel_buffer
	for y in 0 .. draw_fbg_gg.height {
		for x in 0 .. draw_fbg_gg.width {
			index := x + y * draw_fbg_gg.width

			red := unsafe { fbg_ctx.disp_buffer[index * fbg_ctx.components] }
			green := unsafe { fbg_ctx.disp_buffer[index * fbg_ctx.components + 1] }
			blue := unsafe { fbg_ctx.disp_buffer[index * fbg_ctx.components + 2] }
			ctx.pixel_buffer[y][x] = (red | (u32(green) << 8) | (u32(blue) << 16) | (0xFF << 24))
		}
	}

	// then update the image with pixel_buffer
	ctx.gg_ctx.begin()
	mut img := ctx.gg_ctx.get_cached_image_by_idx(ctx.img_id)
	img.update_pixel_data(unsafe { &u8(&ctx.pixel_buffer) })

	// then draw the image
	ctx.gg_ctx.draw_image(0, 0, draw_fbg_gg.width, draw_fbg_gg.height, img)

	ctx.gg_ctx.end()
}

pub fn fbg_gg_flip(fbg_ctx &fbg.Fbg) {
	// ctx.gg_ctx.flip()
}

pub fn (mut ctx Context_fbg_gg) clear() {
	fbg.fbg_clear(ctx.fbg_ctx, 0)
}

pub fn (mut ctx Context_fbg_gg) draw_rect_filled(x int, y int, width int, height int, color gx.Color) {
	fbg.fbg_rect(ctx.fbg_ctx, x, y, width, height, color)
}
