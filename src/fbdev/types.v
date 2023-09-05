module fbdev

// import os
// import gx
import keyboard


pub type FNCb = fn (data voidptr)
pub type FNEvent = fn (e &Event, data voidptr)
pub type FNMove = fn (x f32, y f32, data voidptr)
// pub type FNUnClick = fn (x f32, y f32, button MouseButton, data voidptr)
// pub type FNClick = fn (x f32, y f32, button MouseButton, data voidptr)
pub type FNKeyDown = fn (c KeyCode, m Modifier, data voidptr)
pub type FNChar = fn (c u32, data voidptr)


pub type KeyCode = keyboard.KeyCode
// pub type Image = vpng.PngFile

// pub struct Config {
// 	bg_color		gx.Color
// 	user_data		voidptr
// 	frame_fn		FNCb	= unsafe { nil }
// 	init_fn			FNCb	= unsafe { nil }
// 	event_fn		FNEvent = unsafe { nil }
	
// 	click_fn		FNClick   = unsafe { nil }
// 	move_fn			FNMove    = unsafe { nil }
// 	unclick_fn		FNUnClick = unsafe { nil }
// 	leave_fn		FNEvent   = unsafe { nil } // compability only (not used)
// 	enter_fn		FNEvent   = unsafe { nil } // compability only (not used)
// 	resized_fn		FNEvent   = unsafe { nil } // compability only (not used)
// 	scroll_fn		FNEvent   = unsafe { nil } // compability only (not used)
// 	char_fn			FNChar    = unsafe { nil }
// 	keydown_fn		FNKeyDown = unsafe { nil }

// 	// compability only (not used)
// 	width			int
// 	height			int
// 	create_window		bool
// 	window_title		string
// 	font_path		string
// 	sample_count		int
// 	custom_bold_font_path string
// 	enable_dragndrop bool
// 	max_dropped_file_path_length int
// }


// pub struct Context {
// pub mut:
// 	user_data		voidptr
// 	frame_fn		FNCb	= unsafe { nil }
// 	init_fn			FNCb	= unsafe { nil }
// 	event_fn		FNEvent	= unsafe { nil }
// 	click_fn		FNClick = unsafe { nil }
// 	keydown_fn		FNKeyDown = unsafe { nil }
// 	char_fn			FNChar    = unsafe { nil }
// 	move_fn			FNMove    = unsafe { nil }
// 	unclick_fn		FNUnClick = unsafe { nil }
// 	width			int
// 	height			int
// 	width_extended		int

// 	// extends gg api
// 	bg_color		gx.Color
// 	framebuffer		os.File
// 	virtualbuffer		[]u8
// 	mouse_manager		&mouse.Manager = unsafe { nil }
// 	keyboard_manager	&keyboard.Manager = unsafe { nil }
// 	max_buffer_size		u64 = u64 (0)
// 	text_config		gx.TextCfg = gx.TextCfg {size: 16}
// 	allowed_area		Rect = Rect{x:0, y:0, width: -1, height: -1}
// 	active_cursor		Image
	
// 	// compability only (not used)
// 	frame u64
// 	scale f32 = 1.0
// 	key_modifiers Modifier
// }


pub struct Size {
pub mut:
	width	int
	height	int
}

pub struct Rect {
pub mut:
	x	int
	y	int
	width	int
	height	int
}

pub enum EventType {
	key_down
	// mouse_up
	// mouse_down
	// mouse_scroll //
	// touches_began // compability only (not used)
	// touches_moved // compability only (not used)
	// touches_end // compability only (not used)
	// touches_ended // compability only (not used)
	// resized // compability only (not used)
	// restored // compability only (not used)
	// resumed // compability only (not used)
	// iconified // compability only (not used)
	// quit_requested // compability only (not used)
	// files_droped // compability only (not used)
	// files_dropped // compability only (not used)
}

pub struct Event {
pub mut:
	frame_count        u64
	typ                EventType
	key_code           KeyCode
	char_code          u32
	key_repeat         bool
	modifiers          u32
//	mouse_button       MouseButton
	mouse_x            f32
	mouse_y            f32
	mouse_dx           f32
	mouse_dy           f32
	scroll_x           f32
	scroll_y           f32
	num_touches        int
	// touches            [8]TouchPoint
	window_width       int
	window_height      int
	framebuffer_width  int
	framebuffer_height int
}

// pub struct TouchPoint { // compability only (not used)
// pub mut:
// 	pos_x	int
// 	pos_y	int
// }

// pub enum MouseButton {
// 	left = 0
// 	right = 1
// 	middle = 2
// 	invalid = 256
// }

pub enum Modifier {
	shift // (1<<0)
	ctrl // (1<<1)
	alt // (1<<2)
	super // (1<<3)
}