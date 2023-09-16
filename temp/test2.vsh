import term

fn C.getchar() u8

println('running...')
for {
	// mut output := term.utf8_getchar() or {
	// 	''.runes()[0]
	// }
	mut output := C.getchar()
	println('rune ${output}')
}