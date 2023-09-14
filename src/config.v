module main

import toml
import os

// TOML Template
const default_location := '~/.beepingpebble/config.toml'
const default_config_text = '
[theme]
bg_color="black"
statusbar_bg_color="black"

[apps]
de_location="~/.beepingpebble/apps"
'

struct ThemeConfig {
	bg_color string
	statusbar_bg_color string
}

struct AppsConfig {
	de_location string
}

struct AppConfig {
	theme ThemeConfig
	apps AppsConfig
}

pub fn init_config_file() {
	println("Creating config file at ${default_location}")
	os.write_file(default_location, default_config_text) or {
		panic("Failed to create config file")
	}
}

pub fn get_config() AppConfig {
	mut config_text := ''
	$if emu ? {
		println("Running in emulator, using local config")
		config_text = os.read_file('.beepingpebble/config.toml') or {
			panic("Failed to open config file")
		}
	} $else {
		config_text = os.read_file(default_location) or {
			init_config_file()
			// panic("Failed to open config file")
			default_config_text
		}
	}
	config_toml := toml.parse_text(config_text) or {
		panic("Failed to parse config")
	}

	config := AppConfig {
		theme: ThemeConfig {
			bg_color: config_toml.value("theme.bg_color").default_to("white").string(),
			statusbar_bg_color: config_toml.value("theme.statusbar_bg_color").default_to("white").string(),
		}
		apps: AppsConfig {
			de_location: config_toml.value("apps.de_location").default_to("~/.beepingpebble/apps").string(),
		}
	}

	println("Config: ${config}")
	return config
}
