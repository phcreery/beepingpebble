module main

import os

// https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html#recognized-keys

struct DesktopEntry {
	type_        string // This specification defines 3 types of desktop entries: Application (type 1), Link (type 2) and Directory (type 3). To allow the addition of new types in the future, implementations should ignore desktop entries with an unknown type.
	version      string
	name         string
	generic_name string
	// no_display bool
	comment string
	icon    string
	// hidden bool
	// only_show_in []string
	// not_show_in []string
	// d_bus_activatable bool
	// try_exec string
	exec     string
	path     string
	terminal bool
	// actions []string
	// mime_types []string
	categories []string
	// implements []string
	// keywords []string
	// startup_notify bool
	// startup_wm_class string
	// url string
	// prefers_non_default_gpu bool
	// single_main_window bool
}

fn get_value(key string, file_contents string) string {
	lines := file_contents.trim('\r').split('\n')
	for line in lines {
		if line.starts_with(key) {
			return line.split('=')[1]
		}
	}
	return ''
}

fn parse_desktop_file(file string) &DesktopEntry {
	file_contents := os.read_file(file) or { panic('Could not read app file') }
	de := &DesktopEntry{
		type_: get_value('Type', file_contents)
		version: get_value('Version', file_contents)
		name: get_value('Name', file_contents)
		generic_name: get_value('GenericName', file_contents)
		comment: get_value('Comment', file_contents)
		icon: get_value('Icon', file_contents)
		exec: get_value('Exec', file_contents)
		path: get_value('Path', file_contents)
		terminal: get_value('Terminal', file_contents) == 'true'
		categories: get_value('Categories', file_contents).split(';')
	}
	return de
	// find line that starts with Type=
}

pub fn get_desktop_entries() []DesktopEntry {
	apps_folder := './.beepingpebble/apps'
	files := os.ls(apps_folder) or { panic('Could not read apps directory') }
	// println(files)
	mut entries := []DesktopEntry{}
	for file in files {
		entry := parse_desktop_file(apps_folder + '/' + file)
		entries << entry
	}
	return entries
}
