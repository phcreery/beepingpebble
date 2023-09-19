module main

struct App {
mut:
	tui &Context = unsafe { nil }
}

fn event(e &Event, x voidptr) {
	println('event ${e}')
	if e.typ == .key_down && e.code == .escape {
		termios_reset()
		exit(0)
	}
}

fn frame(x voidptr) {
	// mut app := unsafe { &App(x) }

	// app.tui.clear()
	// app.tui.set_bg_color(r: 63, g: 81, b: 181)
	// app.tui.draw_rect(20, 6, 41, 10)
	// app.tui.draw_text(24, 8, 'Hello from V!')
	// app.tui.set_cursor_position(0, 0)

	// app.tui.reset()
	// app.tui.flush()
}

fn main() {
	println('running...')
	mut app := &App{}
	app.tui = init(
		user_data: app
		event_fn: event
		frame_fn: frame
		hide_cursor: true
	)
	app.tui.run()!
}
