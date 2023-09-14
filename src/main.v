module main

import gx
import hw

struct Theme {
pub mut:
	bg_color           gx.Color
	statusbar_bg_color gx.Color
}

struct App {
pub mut:
	theme Theme
	dwg   DrawContext
	menu  Menu
	sb    StatusBar
}

fn draw(mut app App) {
	app.dwg.begin()
	// app.dwg.clear(app.theme.bg_color)
	// app.dwg.draw_text_def(200, 20, 'hello world!')
	// menu_draw_debug_outline(mut app.dwg)
	// app.dwg.draw_text(10, 10, '! " # $ ${int(char(0x0f57a))} _ \u00b0 \xb0 \xa1 ${int(0xa1)} ', gx.white)
	// app.dwg.draw_text(10, 10, 'helloworld', gx.black)
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
	// app.dwg.draw_image(25, 25, app.dwg.icons['icons/beeper-icon.png'], gx.white)
	// app.dwg.draw_image(25, 25 + 100, app.dwg.icons['icons/settings-icon.png'], gx.white)
	// app.dwg.draw_image(35, 25 + 100, app.dwg.icons['icons/settings-icon.png'], gx.white)
	// app.dwg.draw_image(45, 25 + 100, app.dwg.icons['icons/settings-icon.png'], gx.white)
	// app.dwg.draw_image(55, 25 + 100, app.dwg.icons['icons/settings-icon.png'], gx.white)
	// app.dwg.draw_image(65, 25 + 100, app.dwg.icons['icons/settings-icon.png'], gx.white)
	// app.dwg.draw_image(75, 25 + 100, app.dwg.icons['icons/settings-icon.png'], gx.white)
	// app.dwg.draw_image(85, 25 + 100, app.dwg.icons['icons/settings-icon.png'], gx.white)

	// app.dwg.draw_bmfont_text(10, 10, '! " # $ 06:38', app.font, false)
	// app.dwg.draw_text(10, 20, '! " # $ 06:38', false)
	// app.dwg.draw_text(10, 20, 'a\nb', false)
	// app.dwg.draw_bmfont_text(10, 30, '\uf242', app.font, false)

	// sw := time.new_stopwatch()
	app.menu.draw(mut app)
	// println('app.menu.draw took: ${f32(sw.elapsed().nanoseconds())/ 1_000_000}ms')
	app.sb.draw(mut app)

	app.dwg.end()
}

fn event_manager(mut ev hw.Event, mut app App) {
	// println('event_manager called with event: ${ev}')
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
			.y {
				app.menu.goto_index(0)
			}
			.u {
				app.menu.goto_index(1)
			}
			.i {
				app.menu.goto_index(2)
			}
			.o {
				app.menu.goto_index(3)
			}
			.h {
				app.menu.goto_index(4)
			}
			.j {
				app.menu.goto_index(5)
			}
			.k {
				app.menu.goto_index(6)
			}
			.l {
				app.menu.goto_index(7)
			}
			.enter {
				item := app.menu.get_selected()
				println(item.command)
				app.dwg.quit()
				exit(0)
			}
			else {
				println('unused key: ${ev} ${ev.key_code} ${ev.key_code}')
			}
		}
	}
}

fn main() {
	// config initialize
	conf := get_config()

	mut app := App{}
	app.theme = Theme{
		bg_color: gx.color_from_string(conf.theme.bg_color)
		statusbar_bg_color: gx.color_from_string(conf.theme.statusbar_bg_color)
	}
	app.menu = create_menu(app.dwg)
	apps := get_desktop_entries(conf.apps.de_location)
	app.menu.add_desktop_entries_to_menu(apps)

	app.sb = create_statusbar()
	app.dwg = create_context(app, draw, event_manager)
	app.dwg.run()
}
