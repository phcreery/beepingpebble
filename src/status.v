module main

import gx
import math.vec
import time

pub struct StatusBarTextItem {
pub mut:
	text string
	pos  vec.Vec2[int]
}

pub struct StatusBar {
pub mut:
	pos   vec.Vec2[int]
	items []StatusBarTextItem
}

pub fn create_statusbar() &StatusBar {
	mut sb := &StatusBar{
		pos: vec.Vec2[int]{
			x: 0
			y: 0
		}
	}
	sb.update()
	return sb
}

fn (mut sb StatusBar) update() {
	text_array := [
		// time.now().hhmm12(),
		time.now().custom_format('M/D/YY hh:mm')
		'100%',
		'4.2V',
		'-***',
		// '(((*'
		get_loading_status_text()
	]
	mut items := []StatusBarTextItem
	mut x := width
	for text_item in text_array {
		x -= 8 // padding
		x -= text_item.len * 8 // 8 = font width
		item := StatusBarTextItem{
			text: text_item
			pos: vec.Vec2[int]{
				x: x
				y: 40 / 2 - 8 / 2
			}
		}
		items << item
	}
	sb.items = items
}

fn (mut sb StatusBar) draw(mut dwg DrawContext) {
	sb.update()
	dwg.draw_rect_filled(sb.pos.x, sb.pos.y, width, 40, gx.black)
	for item in sb.items {
		dwg.draw_text(item.pos.x, item.pos.y, item.text, gx.white)
	}
}

fn get_loading_status_text() string {
	t := time.now().unix_time()
	if t % 4 == 0 {
		return '-'
	} else if t % 4 == 1 {
		return '\\'
	} else if t % 4 == 2 {
		return '|'
	} else {
		return '/'
	}
}
