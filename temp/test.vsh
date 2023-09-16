import term.termios

const tiocsti := 0x5412
file := open('/dev/tty1') or { panic('cant open tty') }
println(is_atty(file.fd))
command := 'ls -la'
chars := command.bytes()
println(chars)
for character in chars {
    termios.ioctl(file.fd, termios.flag(tiocsti), character)
}