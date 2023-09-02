module main

import gx
import gg
// import draw_gg
import libs.fbg
import draw_fbg_gg

struct App {
pub mut:
	ctx IBPContext
	// ctx  &fbg.Fbg
	menu Menu
}

fn draw(mut app App) {
	// app.ctx.begin()
	// app.ctx.clear()
	// app.ctx.draw_text_def(200, 20, 'hello world!')
	// debug_draw_menu_outline(mut app.ctx)
	// app.ctx.draw_line(0, 0, 20, 30, gx.black)
	// app.menu.draw(mut app.ctx)
	// app.ctx.draw_line_inv(0, 10, 20, 30)
	// app.ctx.draw_test_image()
	// app.ctx.end()

	println('draw')
	fbg.fbg_rect(app.ctx.fbg_ctx, 0, 0, 100, 100, 100, 0, 0)
	println(app.ctx.fbg_ctx.fps)
}

fn event_manager(mut ev gg.Event, mut app App) {
	// if ev.typ == .key_down {
	// 	match ev.key_code {
	// 		.escape {
	// 			// app.ctx.quit()
	// 			println('escape')
	// 		}
	// 		.right {
	// 			app.menu.next()
	// 		}
	// 		.left {
	// 			app.menu.prev()
	// 		}
	// 		.up {
	// 			app.menu.up()
	// 		}
	// 		.down {
	// 			app.menu.down()
	// 		}
	// 		else {
	// 			println('key: ')
	// 		}
	// 	}
	// }
}

fn main() {
	mut app := App{}
	// app.menu = create_menu(app.ctx)
	app.ctx = draw_fbg_gg.fbg_gg_setup(app.ctx, draw, event_manager)
	app.ctx.run()
}
