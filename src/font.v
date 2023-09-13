module main

import stbi
import arrays

// https://damieng.com/blog/2011/02/20/typography-in-8-bits-system-fonts/

pub struct Font {
mut:
	glyph_coord_x []int
	glyph_coord_y []int
	glyph_width   int
	glyph_height  int
	first_char    u8
	colorkey      u32
	bitmap        &STBIImageWrapper // &stbi.Image
}

[deprecated: 'use bmfont.load_fnt() instead']
pub fn default_font() &Font {
	mut embedded_font_file := $embed_file('thirdparty/bbmode1_8x8.png')
	data := embedded_font_file.data()
	mut stbiimg := stbi.load_from_memory(data, embedded_font_file.len, stbi.LoadParams{
		desired_channels: 1
	}) or { panic('failed to load image') }
	d := unsafe {
		arrays.carray_to_varray[u8](stbiimg.data, stbiimg.width * stbiimg.height * stbiimg.nr_channels)
	}
	img := &STBIImageWrapper{
		stbiimg: &stbiimg
		data: d
	}

	mut font := &Font{
		glyph_coord_x: []int{len: 256, cap: 256, init: 0}
		glyph_coord_y: []int{len: 256, cap: 256, init: 0}
		glyph_width: 8
		glyph_height: 8
		first_char: u8(33)
		colorkey: 0
		bitmap: img
	}

	glyph_count := (img.stbiimg.width / font.glyph_width) * (img.stbiimg.height / font.glyph_height)
	for i in 0 .. glyph_count {
		gcoord := i * font.glyph_width
		gcoordx := gcoord % img.stbiimg.width
		gcoordy := (gcoord / img.stbiimg.width) * font.glyph_height

		font.glyph_coord_x[i] = gcoordx
		font.glyph_coord_y[i] = gcoordy
	}

	return font
}
