module main

import toml
import os

// TOML Template
const config_dir := os.config_dir() or { '' }

const bp_config_dir := config_dir + '/beepingpebble'
const bp_config_location := bp_config_dir + '/config.toml'
const bp_apps_location := bp_config_dir + '/apps'

const default_config_text = '
[theme]
bg_color="white"
statusbar_bg_color="black"

[apps]

[general]
tty="/dev/tty1"

[statusbar]
time=true
date=false
battery_percent=true
battery_voltage=false
'

default_apps := {
		'welcome.desktop': $embed_file('.beepingpebble/apps/welcome.desktop')
		'beepy-config.desktop': $embed_file('.beepingpebble/apps/beepy-config.desktop')
	}


struct ThemeConfig {
	bg_color           string
	statusbar_bg_color string
}

struct AppsConfig {
	de_location string
}

struct GeneralConfig {
	tty string
}

pub struct StatusBarConfig {
	show_time            bool
	show_date            bool
	show_battery_percent bool
	show_battery_voltage bool
}

struct AppConfig {
	theme     ThemeConfig
	apps      AppsConfig
	general   GeneralConfig
	statusbar StatusBarConfig
}

pub fn init_config_file() {
	println('Creating config file at ${bp_config_dir}')
	os.mkdir_all(bp_config_dir) or {
		panic('Failed to create ${bp_config_dir} folder')
	}
	os.mkdir_all(bp_apps_location) or {
		panic('Failed to create ${bp_apps_location} folder')
	}
	os.write_file(bp_config_location, default_config_text) or {
		panic('Failed to create config file')
	}
	// copy apps
	// os.cp_all('.beepingpebble/apps/', bp_apps_location, false) or {
	// 	panic('Failed to copy default apps')
	// }
	for app_name, app_content in default_apps {
		os.write_file(bp_apps_location + '/' + app_name, app_content) or {
			panic('Failed to create default app ${app_name}')
		}
	}
}

pub fn get_config() AppConfig {
	mut config_text := ''
	$if emu ? {
		println('Running in emulator, using local config at .beepingpebble/config.toml')
		config_text = os.read_file('.beepingpebble/config.toml') or {
			panic('Failed to open config file')
		}
	} $else {
		config_text = os.read_file(bp_config_location) or {
			init_config_file()
			// panic("Failed to open config file")
			default_config_text
		}
	}
	config_toml := toml.parse_text(config_text) or { panic('Failed to parse config') }

	config := AppConfig{
		theme: ThemeConfig{
			bg_color: config_toml.value('theme.bg_color').default_to('white').string()
			statusbar_bg_color: config_toml.value('theme.statusbar_bg_color').default_to('white').string()
		}
		apps: AppsConfig{
			de_location: config_toml.value('apps.de_location').default_to(bp_apps_location).string()
		}
		general: GeneralConfig{
			tty: config_toml.value('general.tty').default_to('/dev/tty1').string()
		}
		statusbar: StatusBarConfig{
			show_time: config_toml.value('statusbar.time').default_to(true).bool()
			show_date: config_toml.value('statusbar.date').default_to(true).bool()
			show_battery_percent: config_toml.value('statusbar.battery_percent').default_to(true).bool()
			show_battery_voltage: config_toml.value('statusbar.battery_voltage').default_to(true).bool()
		}
	}

	println('Config: ${config}')
	return config
}
