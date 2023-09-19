module hw

import os
import term.termios

pub fn get_batt_percent() string {
	percent := os.read_file('/sys/firmware/beepy/battery_percent') or { '0' }
	return percent
}

pub fn get_batt_volts() string {
	volts := os.read_file('/sys/firmware/beepy/battery_volts') or { '0' }
	return volts
}

pub fn get_wifi_strength() string {
	$if emu ? {
		return '\u2022\u2022\u2022\u2027'
	}
	info := os.read_file('/proc/net/wireless') or { return 'xxxx' }
	lines := info.split_into_lines()
	percent_s := lines[2][14..18].replace('.', '').replace(' ', '')
	percent := percent_s.parse_int(10, 8) or { return '????' }
	if percent > 75 {
		return '\u2022\u2022\u2022\u2022' // '▁▃▅▇' // ▁ ▂ ▃ ▄ ▅ ▆ ▇ █ ▉
	} else if percent > 50 && percent <= 75 {
		return '\u2022\u2022\u2022\u2027'
	} else if percent > 25 && percent <= 50 {
		return '\u2022\u2022\u2027\u2027'
	} else if percent > 0 && percent <= 25 {
		return '\u2022\u2027\u2027\u2027'
	} else {
		return '\u2027\u2027\u2027\u2027'
	}
}

pub fn send_command(cmd string, tty string) {
	$if emu ? {
		println('sending command: ttyecho -n ${tty} ${cmd}')
		return
	}
	// os.execute('ttyecho -n ${tty} ${cmd}')

	tiocsti := 0x5412
	file := os.open('/dev/tty1') or { panic('cant open tty') }
	println(os.is_atty(file.fd))
	if os.is_atty(file.fd) != 1 {
		return
	}
	command := cmd + '\n'
	chars := command.bytes()
	println(chars)
	for character in chars {
		termios.ioctl(file.fd, termios.flag(tiocsti), character)
	}
}
