module main

import math.vec
import time
import hw

pub struct StatusBarTextItem {
pub mut:
	text string
	pos  vec.Vec2[int]
}

pub struct StatusBar {
pub mut:
	pos    vec.Vec2[int]
	items  []StatusBarTextItem
	sw     time.Time
	config StatusBarConfig
}

pub fn create_statusbar(config StatusBarConfig) &StatusBar {
	mut sb := &StatusBar{
		pos: vec.Vec2[int]{
			x: 0
			y: 0
		}
		items: []
		config: config
	}
	return sb
}

fn (mut sb StatusBar) update(dwg &DrawContext) {
	mut text_array := []string{}
	if sb.config.show_time {
		text_array << time.now().custom_format('h:mm')
	}
	if sb.config.show_date {
		text_array << time.now().custom_format('M/D')
	}
	if sb.config.show_battery_percent {
		text_array << '${hw.get_batt_percent()}%' // \uf578  battery icon
	}
	if sb.config.show_battery_voltage {
		text_array << '${hw.get_batt_volts()}V'
	}
	text_array << '\ufaa8 ${hw.get_wifi_strength()}' // \ufaa8 and \ufaa9 for wifi
	$if emu ? {
		text_array << get_fps(dwg)
	}

	mut items := []StatusBarTextItem{}
	mut x := width
	for text_item in text_array {
		x -= 8 // padding
		x -= text_item.runes().len * 8 // 8 = font width
		// println('${text_item}, ${text_item.runes().len}')
		item := StatusBarTextItem{
			text: text_item
			pos: vec.Vec2[int]{
				x: x
				y: 20 / 2 - int(dwg.font.info.size / 2) - 1
			}
		}
		items << item
	}
	sb.items = items
}

fn (mut sb StatusBar) draw(mut app App) {
	sb_height := 20
	if time.since(sb.sw).seconds() > 1 {
		sb.sw = time.now()
		sb.update(&app.dwg)
		app.dwg.draw_rect_filled(sb.pos.x, sb.pos.y, width, sb_height - 1, app.theme.statusbar_bg_color)
		if app.theme.bg_color == app.theme.statusbar_bg_color {
			app.dwg.draw_line(sb.pos.x - 1, sb.pos.y + sb_height - 1, width, sb.pos.y + sb_height - 1,
				false)
		}
		for item in sb.items {
			app.dwg.draw_text(item.pos.x, item.pos.y, item.text, false)
		}
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

fn get_fps(dwg &DrawContext) string {
	return '${dwg.fps}fps'
}
