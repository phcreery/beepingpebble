module keyboard

fn C.getchar() u8

pub struct Config {
pub mut:
	keyboard_fn	fn (KeyCode) = unsafe { nil }
}

pub struct Manager {
pub mut:
	keyboard_fn	fn (KeyCode) = unsafe { nil }
}

fn (mut manager Manager) controller () {
	for ;; {
		key := wait_key()
		if key == 27 {
			unsafe {
				wait_key()
				x_key := {65:KeyCode(265),66:.down,67:.right,68:.left}[wait_key()]
				manager.keyboard_fn(x_key)
			}
		} else {
			unsafe {
				manager.keyboard_fn(KeyCode(key))
			}
		}
	}
}

pub fn new_manager (args Config) &Manager {
	mut manager := &Manager{
		keyboard_fn: args.keyboard_fn
	}
	go manager.controller()
	return manager
}

pub enum KeyCode {
	right	= 262
	left	= 263
	down	= 264
	up		= 265
	a		= 97
	b
	c
	d
	e
	f
	g
	h
	i
	j
	k
	l
	m
	n
	o
	p
	q
	r
	s
	t
	u
	v
	w
	y
	z
	enter	= 13
	backspace = 127
	space   = 32
	escape	= 27
	tab		= 9
	menu	= -99
	delete
}

fn wait_key() u8 {
	keyboard.optimise_term()
	output := C.getchar()
	if output == 3 {
		keyboard.restore_term()
		exit(0)
	}
	return output
}
