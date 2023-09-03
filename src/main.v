module main

import gx
import gg

struct App {
pub mut:
	ctx  Context
	menu Menu
}

fn draw(mut app App) {
	app.ctx.begin()
	app.ctx.clear()
	// app.ctx.draw_text_def(200, 20, 'hello world!')
	debug_draw_menu_outline(mut app.ctx)
	app.menu.draw(mut app.ctx)
	app.ctx.draw_line_inv(0, 0, 20, 60)
	app.ctx.draw_line(20, 60, 20, 160, gx.red)
	app.ctx.draw_polygon_filled([Point{10, 10}, Point{20, 20}, Point{30, 10}], gx.green)
	app.ctx.draw_polygon([Point{10, 100}, Point{20, 200}, Point{30, 100}], gx.red)
	// app.ctx.draw_line_inv(0, 10, 20, 30)
	// app.ctx.draw_test_image()

	app.ctx.end()
}

fn event_manager(mut ev gg.Event, mut app App) {
	if ev.typ == .key_down {
		match ev.key_code {
			.escape {
				// app.ctx.quit()
				println('escape')
			}
			.right {
				app.menu.next()
			}
			.left {
				app.menu.prev()
			}
			.up {
				app.menu.up()
			}
			.down {
				app.menu.down()
			}
			else {
				println('key: ')
			}
		}
	}
}

fn main() {
	mut app := App{}
	app.menu = create_menu(app.ctx)
	app.ctx = create_context(app, draw, event_manager)
	app.ctx.run()
}
