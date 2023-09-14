module hw

import os

pub fn get_batt_percent() string {
	percent := os.read_file('/sys/firmware/beepy/battery_percent') or { '0' }
	return percent
}

pub fn get_batt_volts() string {
	volts := os.read_file('/sys/firmware/beepy/battery_volts') or { '0' }
	return volts
}

pub fn get_wifi_strength() string {
	info := os.read_file('/proc/net/wireless') or { return 'xxxx' }
	lines := info.split_into_lines()
	// println(lines[2])
	percent_s := lines[2][14..18].replace('.', '').replace(' ', '')
	// println('-${percent_s}-')
	percent := percent_s.parse_int(10, 8) or { return '????' }
	// println(percent)
	if percent > 75 {
		return '****'
	} else if percent > 50 && percent <= 75 {
		return '-***'
	} else if percent > 25 && percent <= 50 {
		return '--**'
	} else if percent > 0 && percent <= 25 {
		return '---*'
	} else {
		return '----'
	}
}

pub fn send_command(cmd string, tty string) {
	$if emu ? {
		println('sending command: ttyecho -n ${tty} ${cmd}')
		return
	}
	os.execute('ttyecho -n ${tty} ${cmd}')
}
