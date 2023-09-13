module bmfont

import stbi
import arrays
import math

// info face="CozetteVector" size=-13 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1 outline=0
// common lineHeight=13 base=10 scaleW=256 scaleH=256 pages=1 packed=0 alphaChnl=0 redChnl=0 greenChnl=0 blueChnl=0
// page id=0 file="cozette_bmfont_0.png"
// chars count=1150
// char id=0    x=0     y=0     width=7     height=13    xoffset=0     yoffset=0     xadvance=6     page=0  chnl=15
// char id=1    x=162   y=184   width=5     height=6     xoffset=1     yoffset=3     xadvance=6     page=0  chnl=15
// ...

struct FontInfo {
pub mut:
	face string
	size int
	// bold bool
	// italic bool
	// charset string
	// unicode bool
	// stretchH int
	// smooth bool
	// aa bool
	padding []int // (left, right, top, bottom) ??
	spacing []int // (horizontal, vertical) ??
	// outline int
}

struct FontCommon {
	base       int
	scale_w    int
	scale_h    int
	pages      int
	packed     bool
	alpha_chnl int
	red_chnl   int
	green_chnl int
	blue_chnl  int
pub:
	line_height int
}

struct FontPage {
	id     int
	file   string
	bitmap &stbi.Image
	data   []u8
}

struct FontChar {
pub:
	id       int
	x        int // where the character is on the page
	y        int // where the character is on the page
	width    int // how wide the character is on the page
	height   int // how tall the character is on the page
	xoffset  int // RENDERING: how far in px the character is from the left edge relative to the cursor
	yoffset  int // RENDERING: how far in px the character is from the top edge relative to the cursor
	xadvance int // RENDERING: how far in px the next character should be from the cursor
	page     int // which page the character is on
	chnl     int
}

pub struct Font {
pub:
	info   FontInfo
	common FontCommon
	pages  map[int]FontPage // OR []FontPage
	chars  map[int]FontChar // = []map[int]FontChar{} OR []FontChar
}

pub fn load_fnt(font_file string) &Font {
	mut embedded_font_file := $embed_file('thirdparty/CozetteFonts-v-1-22-2/CozetteFonts/cozette_bmfont.fnt')
	// mut embedded_bitmap_file := $embed_file('thirdparty/CozetteFonts-v-1-22-2/CozetteFonts/cozette_bmfont_0.png')

	path := embedded_font_file.path.rsplit_nth('/', 2)[1]
	fnt := embedded_font_file.to_string()

	// get lines
	lines := fnt.split('\n')

	// parse info line
	info_line := lines[0]
	info := FontInfo{
		face: info_line.split('face=')[1].split(' ')[0].trim('"')
		size: math.abs(info_line.split('size=')[1].split(' ')[0].int())
		// bold: info_line.split('bold=')[1].split(' ')[0].int() == 1,
		// italic: info_line.split('italic=')[1].split(' ')[0].int() == 1,
		// charset: info_line.split('charset=')[1].split(' ')[0].trim('"'),
		// unicode: info_line.split('unicode=')[1].split(' ')[0].int() == 1,
		// stretchH: info_line.split('stretchH=')[1].split(' ')[0].int(),
		// smooth: info_line.split('smooth=')[1].split(' ')[0].int() == 1,
		// aa: info_line.split('aa=')[1].split(' ')[0].int() == 1,
		padding: info_line.split('padding=')[1].split(' ')[0].split(',').map(fn (s string) int {
			return s.int()
		})
		spacing: info_line.split('spacing=')[1].split(' ')[0].split(',').map(fn (s string) int {
			return s.int()
		})
		// outline: info_line.split('outline=')[1].split(' ')[0].int(),
	}
	// TODO: parse other info fields

	// parse common line
	common_line := lines[1]
	common := FontCommon{
		line_height: common_line.split('lineHeight=')[1].split(' ')[0].int()
		base: common_line.split('base=')[1].split(' ')[0].int()
		scale_w: common_line.split('scaleW=')[1].split(' ')[0].int()
		scale_h: common_line.split('scaleH=')[1].split(' ')[0].int()
		pages: common_line.split('pages=')[1].split(' ')[0].int()
		packed: common_line.split('packed=')[1].split(' ')[0].int() == 1
		alpha_chnl: common_line.split('alphaChnl=')[1].split(' ')[0].int()
		red_chnl: common_line.split('redChnl=')[1].split(' ')[0].int()
		green_chnl: common_line.split('greenChnl=')[1].split(' ')[0].int()
		blue_chnl: common_line.split('blueChnl=')[1].split(' ')[0].int()
	}

	// parse page line
	page_line := lines[2].trim('\r')
	mut pages := map[int]FontPage{}
	page_file := page_line.split('file=')[1].split(' ')[0].trim('"')
	mut img := stbi.load('${path}/${page_file}', stbi.LoadParams{
		desired_channels: 1
	}) or { panic('failed to load image') }
	// println('img.width:  ${img.width}')
	// println('img.height: ${img.height}')
	// println('img.nr_channels: ${img.nr_channels}')
	d := unsafe {
		arrays.carray_to_varray[u8](img.data, img.width * img.height * img.nr_channels)
	}
	page := FontPage{
		id: page_line.split('id=')[1].split(' ')[0].int()
		file: page_file
		bitmap: &img
		data: d
	}
	// TODO: parse multiple pages
	pages[page.id] = page
	mut next_line := 3

	// parse chars (chars_count)
	chars_line := lines[next_line]
	chars_count := chars_line.split('count=')[1].split(' ')[0].int()
	next_line += 1

	// read rest of lines
	mut font_chars := map[int]FontChar{}
	for l in 0 .. chars_count {
		char_line := lines[l + next_line]

		// parse char line
		mut font_char := FontChar{
			id: char_line.split('id=')[1].split(' ')[0].int()
			x: char_line.split('x=')[1].split(' ')[0].int()
			y: char_line.split('y=')[1].split(' ')[0].int()
			width: char_line.split('width=')[1].split(' ')[0].int()
			height: char_line.split('height=')[1].split(' ')[0].int()
			xoffset: char_line.split('xoffset=')[1].split(' ')[0].int()
			yoffset: char_line.split('yoffset=')[1].split(' ')[0].int()
			xadvance: char_line.split('xadvance=')[1].split(' ')[0].int()
			page: char_line.split('page=')[1].split(' ')[0].int()
			chnl: char_line.split('chnl=')[1].split(' ')[0].int()
		}

		font_chars[font_char.id] = font_char
		// println("font_chars: ${font_chars}")
		// exit(0)
	}

	// build font
	mut font := &Font{
		info: info
		common: common
		pages: pages
		chars: font_chars
	}

	return font
}

pub fn (f Font) get_pixel(pagei int, x int, y int) u8 {
	// println("pagei: ${pagei}, x: ${x}, y: ${y}")
	// println("f.pages[pagei].bitmap.width: ${f.pages[pagei].bitmap.width}")
	// println("f.pages[pagei].bitmap.nr_channels: ${f.pages[pagei].bitmap.nr_channels}")
	index := (y * f.pages[pagei].bitmap.width + x) * f.pages[pagei].bitmap.nr_channels
	return f.pages[pagei].data[index]
}

// derived from https://larsee.com/blog/2014/05/converting-fonts-to-c-source-using-bmfont2c/
// pub fn (f Font) get_char_bitmap(ch u8) [][]u8 {
// 	character := f.chars[ch]
// 	println("character: ${character}")

// 	for y in 0..character.height {
// 		for x in 0..character.width {
// 			use_x := x //- character.xoffset + crop_x
// 			use_y := y //- character.yoffset + crop_y
// 			mut pixel := u8(0)
// 			// println("use_x: ${use_x}, use_y: ${use_y}, character.width: ${character.width}, character.height: ${character.height}")
// 			// if (use_x >= 0) && (use_x < character.width) && (use_y >= 0) && (use_y < character.height){
// 				if f.get_pixel(0, use_x + character.x, use_y + character.y) > 127 {
// 					pixel = 1
// 					print('#')
// 				} else {
// 					print(' ')
// 				}
// 			// } else {
// 				// print('.')
// 			// }
// 			pixels[y][x] = pixel
// 		}
// 		println('')
// 	}
// 	return [][]u8{}
// }
