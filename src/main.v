module main

import gx
// $if rpi ? {
// 	import fbdev as gg
// } $else {
import gg
// }

struct App {
pub mut:
	dwg  DrawContext
	menu Menu
	sb   StatusBar
}

fn draw(mut app App) {
	app.dwg.begin()
	app.dwg.clear()
	// app.dwg.draw_text_def(200, 20, 'hello world!')
	// menu_draw_debug_outline(mut app.dwg)
	// app.dwg.draw_text(10, 10, '!"#', gx.black)
	app.dwg.draw_text(10, 10, 'helloworld', gx.black)
	// app.dwg.draw_line_inv(0, 0, 20, 60)
	// app.dwg.draw_line(20, 60, 20, 160, gx.red)
	// app.dwg.draw_polygon_filled([Point{10, 10}, Point{20, 20},
	// 	Point{30, 10}], gx.green)
	// app.dwg.draw_polygon_filled([Point{110, 110}, Point{120, 110},
	// 	Point{120, 120}, Point{110, 120}], gx.green)
	// app.dwg.draw_polygon([Point{10, 100}, Point{20, 200}, Point{30, 100}], gx.red)
	// app.dwg.draw_line_inv(0, 10, 20, 30)
	// app.dwg.draw_test_image()
	// icons := load_icons()
	// app.dwg.draw_image(25, 25, app.dwg.icons['icons/beeper-icon.png'])
	// app.dwg.draw_image(25, 25 + 100, app.dwg.icons['icons/settings-icon.png'])

	app.menu.draw(mut app.dwg)
	app.sb.draw(mut app.dwg)

	app.dwg.end()
}

fn event_manager(mut ev gg.Event, mut app App) {
	if ev.typ == .key_down {
		match ev.key_code {
			.escape, .q {
				app.dwg.quit()
				println('escape')
			}
			.right, .d {
				app.menu.next()
			}
			.left, .a {
				app.menu.prev()
			}
			.up, .w {
				app.menu.up()
			}
			.down, .s {
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
	app.menu = create_menu(app.dwg)
	app.sb = create_statusbar(app.dwg)
	app.dwg = create_context(app, draw, event_manager)
	app.dwg.run()
}
