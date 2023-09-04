module main

import gx
import math.vec

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
	time_item := StatusBarTextItem{
		text: '00:00'
		pos: vec.Vec2[int]{
			x: width - 8 * 6
			y: height - 40 / 2 - 8 / 2
		}
	}
	batt_item := StatusBarTextItem{
		text: '100%'
		pos: vec.Vec2[int]{
			x: width - 8 * 6 - 8 * 5
			y: height - 40 / 2 - 8 / 2
		}
	}
	volt_item := StatusBarTextItem{
		text: '4.2V'
		pos: vec.Vec2[int]{
			x: width - 8 * 6 - 8 * 5 - 8 * 5
			y: height - 40 / 2 - 8 / 2
		}
	}
	wifi_item := StatusBarTextItem{
		text: '-***'
		pos: vec.Vec2[int]{
			x: width - 8 * 6 - 8 * 5 - 8 * 5 - 8 * 5
			y: height - 40 / 2 - 8 / 2
		}
	}
	sb := &StatusBar{
		pos: vec.Vec2[int]{
			x: 0
			y: height - 40
		}
		items: [time_item, batt_item, volt_item, wifi_item]
	}
	return sb
}

fn (mut sb StatusBar) draw(mut dwg DrawContext) {
	dwg.draw_rect_filled(sb.pos.x, sb.pos.y, width, 40, gx.black)
	for item in sb.items {
		dwg.draw_text(item.pos.x, item.pos.y, item.text, gx.white)
	}
}
