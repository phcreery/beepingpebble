import term

fn C.getchar() u8

// https://modules.vlang.io/gg.html#KeyCode
pub enum KeyCode {
	invalid = 0
	// enter	= 13 // from mfb
	space = 32
	apostrophe = 39 //'
	comma = 44 //,
	minus = 45 //-
	period = 46 //.
	slash = 47 ///
	_0 = 48
	_1 = 49
	_2 = 50
	_3 = 51
	_4 = 52
	_5 = 53
	_6 = 54
	_7 = 55
	_8 = 56
	_9 = 57
	semicolon = 59 //;
	equal = 61 //=
	a = 65
	b = 66
	c = 67
	d = 68
	e = 69
	f = 70
	g = 71
	h = 72
	i = 73
	j = 74
	k = 75
	l = 76
	m = 77
	n = 78
	o = 79
	p = 80
	q = 81
	r = 82
	s = 83
	t = 84
	u = 85
	v = 86
	w = 87
	x = 88
	y = 89
	z = 90
	left_bracket = 91 //[
	backslash = 92 //\
	right_bracket = 93 //]
	grave_accent = 96 //`
	// backspace = 127 // from mfb
	world_1 = 161 // non-us #1
	world_2 = 162 // non-us #2
	escape = 256
	enter = 257
	tab = 258
	backspace = 259
	insert = 260
	delete = 261
	right = 262
	left = 263
	down = 264
	up = 265
	page_up = 266
	page_down = 267
	home = 268
	end = 269
	caps_lock = 280
	scroll_lock = 281
	num_lock = 282
	print_screen = 283
	pause = 284
	f1 = 290
	f2 = 291
	f3 = 292
	f4 = 293
	f5 = 294
	f6 = 295
	f7 = 296
	f8 = 297
	f9 = 298
	f10 = 299
	f11 = 300
	f12 = 301
	f13 = 302
	f14 = 303
	f15 = 304
	f16 = 305
	f17 = 306
	f18 = 307
	f19 = 308
	f20 = 309
	f21 = 310
	f22 = 311
	f23 = 312
	f24 = 313
	f25 = 314
	kp_0 = 320
	kp_1 = 321
	kp_2 = 322
	kp_3 = 323
	kp_4 = 324
	kp_5 = 325
	kp_6 = 326
	kp_7 = 327
	kp_8 = 328
	kp_9 = 329
	kp_decimal = 330
	kp_divide = 331
	kp_multiply = 332
	kp_subtract = 333
	kp_add = 334
	kp_enter = 335
	kp_equal = 336
	left_shift = 340
	left_control = 341
	left_alt = 342
	left_super = 343
	right_shift = 344
	right_control = 345
	right_alt = 346
	right_super = 347
	menu = 348
}

fn translate_alternate_keys(key u8) int {
	// The ASCII value of A is 65 and Z is 90
	println('-${key}-')
	match int(key) {
		10, 13 {
			return 257
		} // enter
		// 27 { return 256 } // esc
		27 {
			// ANSI escape code https://en.wikipedia.org/wiki/ANSI_escape_code
			seq1 := C.getchar() // left_bracket = 91
			if seq1 == 10 {
				return 256
			}
			// escape
			// if seq1 == 27 { return 256 } // escape
			seq2 := C.getchar()
			x_key := unsafe {
				{
					65: 265 // up
					66: 264 // down
					67: 262 // right
					68: 263 // left
				}[seq2]
			}
			println('seq1 ${seq1}, seq2 ${seq2} = xkey ${x_key}')
			return x_key
		}
		// 65...90 { return key + 32 } // A-Z to a-z
		97...122 {
			return key - 32
		} // a-z to A-Z
		else {
			return key
		}
	}
}

println('running...')
for {
	mut output := term.utf8_getchar() or { ''.runes()[0] }
	// mut output := C.getchar()

	output2 := translate_alternate_keys(output)
	println('rune ${output2}')
	code := unsafe {
		KeyCode(output2)
	}
	println('KeyCode ${code}')
}
