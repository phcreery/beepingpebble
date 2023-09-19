module hw

import os
import term.termios

#include <signal.h>

const termios_at_startup = get_termios()

[inline]
fn get_termios() termios.Termios {
	mut t := termios.Termios{}
	termios.tcgetattr(C.STDIN_FILENO, mut t)
	return t
}

fn termios_reset() {
	// C.TCSANOW ??
	mut startup := termios_at_startup
	termios.tcsetattr(C.STDIN_FILENO, C.TCSAFLUSH, mut startup)
	// print('\x1b[?1003l\x1b[?1006l\x1b[?25h')
	print('\x1b[?25h') // restore hidden cursor
	flush_stdout()
	// c := ctx_ptr
	// if unsafe { c != 0 } && c.cfg.use_alternate_buffer {
	// 	print('\x1b[?1049l')
	// }
	os.flush()
}

fn restore_terminal_state_signal(_ os.Signal) {
	restore_terminal_state()
}

fn restore_terminal_state() {
	termios_reset()
	// os.system('tput cnorm') // blinking cursor
	os.flush()
}

fn (mut ctx Context) termios_setup() ! {
	// println('termios_setup')

	if !ctx.config.skip_init_checks && !(os.is_atty(C.STDIN_FILENO) != 0
		&& os.is_atty(C.STDOUT_FILENO) != 0) {
		return error('not running under a TTY')
	}

	mut tios := get_termios()

	if ctx.config.capture_events {
		// Set raw input mode by unsetting ICANON and ECHO,
		// as well as disable e.g. ctrl+c and ctrl.z
		tios.c_iflag &= termios.invert(C.IGNBRK | C.BRKINT | C.PARMRK | C.IXON)
		tios.c_lflag &= termios.invert(C.ICANON | C.ISIG | C.ECHO | C.IEXTEN | C.TOSTOP)
	} else {
		// Set raw input mode by unsetting ICANON and ECHO
		tios.c_lflag &= termios.invert(C.ICANON | C.ECHO)
	}

	if ctx.config.hide_cursor {
		// ctx.hide_cursor()
		// ctx.flush()
		print('\x1b[?25l') // hide
		// print('\033[?12l') // stop blinking
		// os.system('tput civis') // stop blinking
		flush_stdout()
	}

	// println('Prevent stdin from blocking by making its read time 0')
	// Prevent stdin from blocking by making its read time 0
	tios.c_cc[C.VTIME] = 0
	tios.c_cc[C.VMIN] = 0
	termios.tcsetattr(C.STDIN_FILENO, C.TCSAFLUSH, mut tios)
	flush_stdout()
	// println('tios ${tios.c_cc[C.VTIME]} ${tios.c_cc[C.VMIN]}')


	// Reset console on exit
	// C.atexit(restore_terminal_state)
	// os.signal_opt(.tstp, restore_terminal_state_signal) or {}
	

}

///////////////////////////////////////////
// TODO: do multiple sleep/read cycles, rather than one big one
// fn (mut ctx Context) termios_loop() {
// 	frame_time := 1_000_000 / ctx.cfg.frame_rate
// 	mut init_called := false
// 	mut sw := time.new_stopwatch(auto_start: false)
// 	mut sleep_len := 0
// 	for {
// 		if !init_called {
// 			ctx.init()
// 			init_called = true
// 		}
// 		// println('SLEEPING: $sleep_len')
// 		if sleep_len > 0 {
// 			time.sleep(sleep_len * time.microsecond)
// 		}
// 		if !ctx.paused {
// 			sw.restart()
// 			if ctx.cfg.event_fn != unsafe { nil } {
// 				unsafe {
// 					len := C.read(C.STDIN_FILENO, &u8(ctx.read_buf.data) + ctx.read_buf.len,
// 						ctx.read_buf.cap - ctx.read_buf.len)
// 					ctx.resize_arr(ctx.read_buf.len + len)
// 				}
// 				if ctx.read_buf.len > 0 {
// 					ctx.parse_events()
// 				}
// 			}
// 			ctx.frame()
// 			sw.pause()
// 			e := sw.elapsed().microseconds()
// 			sleep_len = frame_time - int(e)

// 			ctx.frame_count++
// 		}
// 	}
// }

fn (mut ctx Context) fetch_events() {
	// println('fetch_events')
	if ctx.config.event_fn != unsafe { nil } {
		unsafe {
			len := C.read(C.STDIN_FILENO, &u8(ctx.read_buf.data) + ctx.read_buf.len,
				ctx.read_buf.cap - ctx.read_buf.len)
			ctx.resize_arr(ctx.read_buf.len + len)
		}
		if ctx.read_buf.len > 0 {
			ctx.parse_events()
		}
	}
}

fn (mut ctx Context) parse_events() {
	// Stop this from getting stuck in rare cases where something isn't parsed correctly
	mut nr_iters := 0
	for ctx.read_buf.len > 0 {
		nr_iters++
		if nr_iters > 100 {
			ctx.shift(1)
		}
		mut event := &Event(unsafe { nil })
		if ctx.read_buf[0] == 0x1b {
			e, len := escape_sequence(ctx.read_buf.bytestr())
			event = e
			ctx.shift(len)
		} else {
			if ctx.read_all_bytes {
				e, len := multi_char(ctx.read_buf.bytestr())
				event = e
				ctx.shift(len)
			} else {
				event = single_char(ctx.read_buf.bytestr())
				ctx.shift(1)
			}
		}
		if unsafe { event != 0 } {
			ctx.config.event_fn(event, ctx.config.user_data)
			nr_iters = 0
		}
	}
}

fn single_char(buf string) &Event {
	ch := buf[0]

	mut event := &Event{
		typ: .key_down
		ascii: ch
		key_code: unsafe { KeyCode(ch) }
		utf8: ch.ascii_str()
	}

	match ch {
		// special handling for `ctrl + letter`
		// TODO: Fix assoc in V and remove this workaround :/
		// 1  ... 26 { event = Event{ ...event, code: KeyCode(96 | ch), modifiers: .ctrl  } }
		// 65 ... 90 { event = Event{ ...event, code: KeyCode(32 | ch), modifiers: .shift } }
		// The bit `or`s here are really just `+`'s, just written in this way for a tiny performance improvement
		// don't treat tab, enter as ctrl+i, ctrl+j
		1...8, 11...26 {
			event = &Event{
				typ: event.typ
				ascii: event.ascii
				utf8: event.utf8
				key_code: unsafe { KeyCode(96 | ch) }
				modifiers: .ctrl
			}
		}
		65...90 {
			event = &Event{
				typ: event.typ
				ascii: event.ascii
				utf8: event.utf8
				key_code: unsafe { KeyCode(32 | ch) }
				modifiers: .shift
			}
		}
		else {}
	}

	return event
}

fn multi_char(buf string) (&Event, int) {
	ch := buf[0]

	mut event := &Event{
		typ: .key_down
		ascii: ch
		key_code: unsafe { KeyCode(ch) }
		utf8: buf
	}

	match ch {
		// special handling for `ctrl + letter`
		// TODO: Fix assoc in V and remove this workaround :/
		// 1  ... 26 { event = Event{ ...event, code: KeyCode(96 | ch), modifiers: .ctrl  } }
		// 65 ... 90 { event = Event{ ...event, code: KeyCode(32 | ch), modifiers: .shift } }
		// The bit `or`s here are really just `+`'s, just written in this way for a tiny performance improvement
		// don't treat tab, enter as ctrl+i, ctrl+j
		1...8, 11...26 {
			event = &Event{
				typ: event.typ
				ascii: event.ascii
				utf8: event.utf8
				key_code: unsafe { KeyCode(96 | ch) }
				modifiers: .ctrl
			}
		}
		65...90 {
			event = &Event{
				typ: event.typ
				ascii: event.ascii
				utf8: event.utf8
				key_code: unsafe { KeyCode(32 | ch) }
				modifiers: .shift
			}
		}
		else {}
	}

	return event, buf.len
}

// Gets an entire, independent escape sequence from the buffer
// Normally, this just means reading until the first letter, but there are some exceptions...
fn escape_end(buf string) int {
	mut i := 0
	for {
		if i + 1 == buf.len {
			return buf.len
		}

		if buf[i].is_letter() || buf[i] == `~` {
			if buf[i] == `O` && i + 2 <= buf.len {
				n := buf[i + 1]
				if (n >= `A` && n <= `D`) || (n >= `P` && n <= `S`) || n == `F` || n == `H` {
					return i + 2
				}
			}
			return i + 1
			// escape hatch to avoid potential issues/crashes, although ideally this should never eval to true
		} else if buf[i + 1] == 0x1b {
			return i + 1
		}
		i++
	}
	// this point should be unreachable
	assert false
	return 0
}

fn escape_sequence(buf_ string) (&Event, int) {
	end := escape_end(buf_)
	single := buf_[..end] // read until the end of the sequence
	buf := single[1..] // skip the escape character

	if buf.len == 0 {
		return &Event{
			typ: .key_down
			ascii: 27
			key_code: .escape
			utf8: single
		}, 1
	}

	if buf.len == 1 {
		c := single_char(buf)
		mut modifiers := c.modifiers
		modifiers.set(.alt)
		return &Event{
			typ: c.typ
			ascii: c.ascii
			key_code: c.key_code
			utf8: single
			modifiers: modifiers
		}, 2
	}
	
	// ----------------------------
	//   Special key combinations
	// ----------------------------

	mut code := KeyCode.null
	mut modifiers := Modifiers.ctrl
	match buf {
		'[A', 'OA' { code = .up }
		'[B', 'OB' { code = .down }
		'[C', 'OC' { code = .right }
		'[D', 'OD' { code = .left }
		'[5~', '[[5~' { code = .page_up }
		'[6~', '[[6~' { code = .page_down }
		'[F', 'OF', '[4~', '[[8~' { code = .end }
		'[H', 'OH', '[1~', '[[7~' { code = .home }
		'[2~' { code = .insert }
		'[3~' { code = .delete }
		'OP', '[11~' { code = .f1 }
		'OQ', '[12~' { code = .f2 }
		'OR', '[13~' { code = .f3 }
		'OS', '[14~' { code = .f4 }
		'[15~' { code = .f5 }
		'[17~' { code = .f6 }
		'[18~' { code = .f7 }
		'[19~' { code = .f8 }
		'[20~' { code = .f9 }
		'[21~' { code = .f10 }
		'[23~' { code = .f11 }
		'[24~' { code = .f12 }
		else {}
	}

	if buf == '[Z' {
		code = .tab
		modifiers.set(.shift)
	}

	if buf.len == 5 && buf[0] == `[` && buf[1].is_digit() && buf[2] == `;` {
		match buf[3] {
			`2` { modifiers = .shift }
			`3` { modifiers = .alt }
			`4` { modifiers = .shift | .alt }
			`5` { modifiers = .ctrl }
			`6` { modifiers = .ctrl | .shift }
			`7` { modifiers = .ctrl | .alt }
			`8` { modifiers = .ctrl | .alt | .shift }
			else {}
		}

		if buf[1] == `1` {
			match buf[4] {
				`A` { code = KeyCode.up }
				`B` { code = KeyCode.down }
				`C` { code = KeyCode.right }
				`D` { code = KeyCode.left }
				`F` { code = KeyCode.end }
				`H` { code = KeyCode.home }
				`P` { code = KeyCode.f1 }
				`Q` { code = KeyCode.f2 }
				`R` { code = KeyCode.f3 }
				`S` { code = KeyCode.f4 }
				else {}
			}
		} else if buf[1] == `5` {
			code = KeyCode.page_up
		} else if buf[1] == `6` {
			code = KeyCode.page_down
		}
	}

	return &Event{
		typ: .key_down
		key_code: code
		utf8: single
		modifiers: modifiers
	}, end
}