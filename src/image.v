module main

import stbi
import os

// wrapper withe pre-converted data
pub struct STBIImageWrapper {
mut:
	stbiimg &stbi.Image
	data    []u8
}

pub fn load_internal_icons() map[string]stbi.Image {
	mut icon_array := [
		$embed_file('icons/beeper-icon.png'),
		$embed_file('icons/cal-icon.png'),
		$embed_file('icons/cloud-icon.png'),
		$embed_file('icons/download-icon.png'),
		$embed_file('icons/settings-icon.png'),
		$embed_file('icons/terminal-icon.png'),
	]

	mut icons := map[string]stbi.Image{}

	for mut icon in icon_array {
		data := icon.data()
		mut img := stbi.load_from_memory(data, icon.len, stbi.LoadParams{
			desired_channels: 4
		}) or { panic('failed to load image') }
		icons[icon.path] = img
	}

	// println("icons ${icons}")
	// d := arrays.carray_to_varray[u8](img.data, img.width * img.height * img.nr_channels)
	// println("image ${img}")

	return icons
}

pub fn load_image(image_path string) stbi.Image {
	// mut icon := os.open('icons/beeper-icon.png') or { panic('failed to open image') }
	// data := icon.read_bytes()
	buffer := os.read_bytes(image_path) or { panic('failed to read image') }
	// buffer.data is a pointer to the heap memory
	mut img := stbi.load_from_memory(buffer.data, buffer.len, stbi.LoadParams{
		desired_channels: 4
	}) or { panic('failed to load image') }
	return img
}
