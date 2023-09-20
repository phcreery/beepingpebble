import readline
import time

fn C.getchar() int
fn C.ungetc(int, voidptr) int

fn peekchar(mut r readline.Readline) int {
	// c := C.getchar()

	r.enable_raw_mode_nosig()
	c := r.read_char() or { panic('cant readchar') }
	r.disable_raw_mode()

	println('peeked ${c}')
	if (c != C.EOF) {
		C.ungetc(c, C.stdin)
	}
	// puts it back
	return c
}

mut r := readline.Readline{}
println('running...')
for {
	r.enable_raw_mode_nosig()
	c := r.read_char() or { panic('cant readchar') }
	r.disable_raw_mode()
	println('key ${c}')
	if c == 27 {
		println('esc?? (${c})')
		// actual_c := kbesc()
		// println('actually: ${actual_c}')

		peekedc := peekchar(mut r)
		println('peekedc: ${peekedc}')
	} else {
		println(c)
	}
	time.sleep(100000000)
}
