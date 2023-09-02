module main

import libs.fbg

fn main() {
	println('asdf')
	fbg_ctx := fbg.fbg_customsetup(400, 200, 3, 1, 0, unsafe { nil }, unsafe { nil },
		unsafe { nil }, unsafe { nil }, unsafe { nil })

	for {
		fbg.fbg_clear(fbg_ctx, 0) // can also be replaced by fbg_background(fbg, 0, 0, 0)

		fbg.fbg_draw(fbg_ctx)

		// you can also use fbg_image(fbg, texture, 0, 0)
		// but you must be sure that your image size fit on the display
		// fbg_imageClip(fbg, texture, 0, 0, 0, 0, fbg->width, fbg->height)

		// fbg_write(fbg, "Quickstart example\nFPS:", 4, 2)
		// fbg_write(fbg, fbg->fps_char, 32 + 8, 2 + 8)
		println('FPS: ${fbg_ctx.fps}')

		// fbg_rect(fbg, fbg->width / 2 - 32, fbg->height / 2 - 32, 16, 16, 0, 255, 0)

		fbg.fbg_pixel(fbg_ctx, fbg_ctx.width / 2, fbg_ctx.height / 2, 255, 0, 0)

		fbg.fbg_flip(fbg_ctx)
	}
}
