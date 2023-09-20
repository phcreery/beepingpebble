module hw

pub type FNCb = fn (data voidptr)

pub type FNEvent = fn (e &Event, data voidptr)

pub enum KeyCode {
	null = 0
	tab = 9
	enter = 10
	escape = 27
	space = 32
	backspace = 127
	exclamation = 33
	double_quote = 34
	hashtag = 35
	dollar = 36
	percent = 37
	ampersand = 38
	single_quote = 39
	left_paren = 40
	right_paren = 41
	asterisk = 42
	plus = 43
	comma = 44
	minus = 45
	period = 46
	slash = 47
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
	colon = 58
	semicolon = 59
	less_than = 60
	equal = 61
	greater_than = 62
	question_mark = 63
	at = 64
	a = 97
	b = 98
	c = 99
	d = 100
	e = 101
	f = 102
	g = 103
	h = 104
	i = 105
	j = 106
	k = 107
	l = 108
	m = 109
	n = 110
	o = 111
	p = 112
	q = 113
	r = 114
	s = 115
	t = 116
	u = 117
	v = 118
	w = 119
	x = 120
	y = 121
	z = 122
	left_square_bracket = 91
	backslash = 92
	right_square_bracket = 93
	caret = 94
	underscore = 95
	backtick = 96
	left_curly_bracket = 123
	vertical_bar = 124
	right_curly_bracket = 125
	tilde = 126
	insert = 260
	delete = 261
	up = 262
	down = 263
	right = 264
	left = 265
	page_up = 266
	page_down = 267
	home = 268
	end = 269
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
}

pub enum Direction {
	unknown
	up
	down
	left
	right
}

pub enum MouseButton {
	unknown
	left
	middle
	right
}

pub enum EventType {
	unknown
	mouse_down
	mouse_up
	mouse_move
	mouse_drag
	mouse_scroll
	key_down
	resized
}

[flag]
pub enum Modifiers {
	ctrl
	shift
	alt
}

pub struct Event {
pub:
	typ EventType
	// Mouse event info
	// x         int
	// y         int
	// button    MouseButton
	// Keyboard event info
	key_code  KeyCode
	modifiers Modifiers
	ascii     u8
	utf8      string
	direction Direction
}

// shifts the array left, to remove any data that was just read, and updates its len
// TODO: remove
[inline]
fn (mut ctx Context) shift(len int) {
	unsafe {
		C.memmove(ctx.read_buf.data, &u8(ctx.read_buf.data) + len, ctx.read_buf.cap - len)
		ctx.resize_arr(ctx.read_buf.len - len)
	}
}

// TODO: don't actually do this, lmao
[inline]
fn (mut ctx Context) resize_arr(size int) {
	mut l := unsafe { &ctx.read_buf.len }
	unsafe {
		*l = size
		_ = l
	}
}
