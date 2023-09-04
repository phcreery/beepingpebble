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

pub fn create_statusbar(dwg &DrawContext) &StatusBar {
	// padding := 8
	text_array := [
		time.now().hhmm12(),
		'100%',
		'4.2V',
		'-***'
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
	sb := &StatusBar{
		pos: vec.Vec2[int]{
			x: 0
			y: 0
		}
		items: items
	}
	return sb
}

fn (mut sb StatusBar) draw(mut dwg DrawContext) {
	dwg.draw_rect_filled(sb.pos.x, sb.pos.y, width, 40-1, gx.black)
	for item in sb.items {
		dwg.draw_text(item.pos.x, item.pos.y, item.text, gx.white)
	}
}
