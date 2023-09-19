import term
import term.termios
import os
import time

fn C.getchar() int
// fn C.getch() int
fn C.ungetc(int, voidptr) int

pub fn optimise_term() {
	os.system('/bin/stty -ignbrk -brkint -ignpar -parmrk -inpck -istrip -inlcr -igncr -icrnl -ixon -ixoff -icanon -opost -isig -iuclc -ixany -imaxbel -xcase -echo')
	os.system('tput civis')
}

fn peekchar() int {
	mut state := termios.Termios{}
	termios.tcgetattr(0, mut state)
	state.c_cc[C.VMIN] = u8(0)
	termios.tcsetattr(0, C.TCSANOW, mut state)

	c := C.getchar()
	
	mut restate := termios.Termios{}
	termios.tcgetattr(0, mut restate)
	restate.c_cc[C.VMIN] = u8(1)
	termios.tcsetattr(0, C.TCSANOW, mut restate)

	println('peeked ${c}')
	println('c eof ${c}, ${C.EOF}')
    if(c != C.EOF) { 
		println('ungetc')
		C.ungetc(c, C.stdin) }      /* puts it back */
	return c
}

// fn kbhit () bool {
// 	mut c := 0
// 	mut old_state := termios.Termios{}
// 	if termios.tcgetattr(0, mut old_state) != 0 {
// 		println('err')
// 		return false // os.last_error()
// 	}
// 	// println('old_state.c_cc ${old_state.c_cc}, ${old_state.c_cc[C.VMIN]}, ${old_state.c_cc[C.VTIME]}')
// 	// defer {
// 	// 	// restore the old terminal state:
// 	// 	termios.tcsetattr(0, C.TCSANOW, mut old_state)
// 	// }

	
// 	// vmemcpy(&state, &old_state, sizeof(state))
// 	// termios.tcgetattr(0, mut state)
// 	mut state := old_state

// 	state.c_lflag &= termios.invert(u32(C.ICANON) | u32(C.ECHO))
// 	state.c_cc[C.VMIN] = u8(1) // control chars (MIN value) = 1
//     state.c_cc[C.VTIME] = u8(0) // control chars (TIME value) = 0 (No time)
// 	if termios.tcsetattr(0, C.TCSANOW, mut state) != 0 {
// 		println('err')
// 		return false // os.last_error()
// 	}

// 	c = unsafe { C.getchar() }
// 	println('kbhit ${c}')
// 	old_state.c_lflag |= (u32(C.ICANON) | u32(C.ECHO))
// 	termios.tcsetattr(0, C.TCSANOW, mut old_state)

	
// 	if (c != C.EOF) { C.ungetc(c, C.stdin) }
// 	if (c != -1) {
// 		println('not -1')
// 		return true
// 	}
// 	return false
// }

// fn kbhit() bool {
//     byteswaiting := u32(0)
	
// 	// mut state := termios.Termios{}
// 	// termios.tcgetattr(0, mut state)
// 	// state.c_lflag &= termios.invert(u32(C.ICANON) | u32(C.ECHO))
// 	// termios.tcsetattr(0, C.TCSANOW, mut state)

//     termios.ioctl(0, termios.flag(C.FIONREAD), byteswaiting)
	
// 	// mut restate := termios.Termios{}
// 	// termios.tcgetattr(0, mut restate)
// 	// restate.c_lflag |= u32(C.ICANON) | u32(C.ECHO)
// 	// termios.tcsetattr(0, C.TCSANOW, mut restate)

// 	println('byteswaiting ${byteswaiting}')
//     if byteswaiting > 0 { 
// 		println('kbd still going')
// 		return true }
// 	return false
// }


// https://stackoverflow.com/questions/34474627/linux-equivalent-for-conio-h-getch
// fn kbhit() bool {
//     // flush_stdout()
//     mut state := termios.Termios{}
// 	if termios.tcgetattr(0, mut state) != 0 {
// 		println('err')
// 		return false // os.last_error()
// 	}
// 	state.c_lflag &= termios.invert(u32(C.ICANON) | u32(C.ECHO))
//     state.c_cc[C.VMIN]  = u8(1)         // control chars (MIN value) = 1
//     state.c_cc[C.VTIME] = u8(0)         // control chars (TIME value) = 0 (No time)
//     if termios.tcsetattr(0, C.TCSANOW, mut state) != 0 {
// 		println('err')
// 		return false // os.last_error()
// 	}
//     println('reading buf...')
// 	buf, len := os.fd_read(0, 1)
// 	println('buf ${buf}')
//     state.c_lflag |= (u32(C.ICANON) | u32(C.ECHO))    // local modes = Canonical mode // local modes = Enable echo. 
//     if termios.tcsetattr(0, C.TCSADRAIN, mut state) != 0 {
// 		println('err')
// 		return false // os.last_error()
// 	}
//     // return buf
// 	return false
// }

fn kbesc() int {
	// dumpc := C.getchar()
	peekedc := peekchar()
	println('peekedc: ${peekedc}')
	// if (!kbhit()) {return 27} // 27 == esc
	// if (!kbhit()) {return 27} // 27 == esc
	// if peekchar() == C.EOF { return 27 }
	// if dumpc == C.EOF { return 27 }
	// if dumpc == 27 { return 27 }
	c := C.getchar()
	println('more data incoming (${c})')
	if (c == '['.bytes()[0]) { // 91 = [
		println('nah, just escape seq')
	}
	return c

}

println('running...')
// optimise_term()

// set input to raw (don't with for enter key on getchar())
mut state := termios.Termios{}
termios.tcgetattr(0, mut state)
// state.c_lflag &= termios.invert(u32(C.ICANON))
state.c_iflag &= termios.invert(C.BRKINT | C.ICRNL | C.INPCK | C.ISTRIP | C.IXON)
state.c_cflag |= termios.flag(C.CS8)
state.c_lflag &= termios.invert(C.ECHO | C.ICANON | C.IEXTEN)
state.c_cc[C.VMIN] = u8(1)
state.c_cc[C.VTIME] = u8(0)
termios.tcsetattr(0, C.TCSADRAIN, mut state)

for {
	flush_stdout()
	c := C.getchar()
	println('key ${c}')
	if c == 27 {
		println('esc??')
		actual_c := kbesc()
		println('actually: ${actual_c}')
		
	} else {
		println(c)
	}
	time.sleep(100000000)

}