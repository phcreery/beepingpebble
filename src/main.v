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
	tty   string
}

fn draw_frame(mut app App) {
	app.dwg.begin()

	// sw := time.new_stopwatch()
	app.menu.draw(mut app)
	// println('app.menu.draw took: ${f32(sw.elapsed().nanoseconds())/ 1_000_000}ms')
	app.sb.draw(mut app)

	app.dwg.end()
}

fn event_manager(mut ev hw.Event, mut app App) {
	if ev.typ == .key_down {
		match ev.key_code {
			.escape, .q {
				app.dwg.quit()
				println('escape')
				exit(0)
			}
			.enter {
				item := app.menu.get_selected()
				app.dwg.quit()
				hw.send_command(item.command, app.tty)
				exit(0)
			}
			else {
				app.menu.handle_key_event(mut ev)
			}
		}
	}
}

fn main() {
	conf := get_config()

	mut app := App{}
	app.theme = Theme{
		bg_color: gx.color_from_string(conf.theme.bg_color)
		statusbar_bg_color: gx.color_from_string(conf.theme.statusbar_bg_color)
	}
	app.menu = create_menu(app.dwg)
	apps := get_desktop_entries(conf.apps.de_location)
	app.menu.add_desktop_entries_to_menu(apps)
	app.tty = conf.general.tty
	app.sb = create_statusbar(conf.statusbar)
	app.dwg = create_context(app, draw_frame, event_manager)
	app.dwg.run()
}
