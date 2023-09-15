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
	// text_array := [
	// 	// time.now().hhmm12(),
	// 	time.now().custom_format('M/D/YY hh:mm'),
	// 	'${hw.get_batt_percent()}%', //'100%',
	// 	'${hw.get_batt_volts()}V', //'4.2V',
	// 	'${hw.get_wifi_strength()}', //'-***',
	// 	// get_loading_status_text(),
	// 	get_fps(dwg),
	// ]
	mut text_array := []string{}
	if sb.config.show_time {
		text_array << time.now().custom_format('h:mm')
	}
	if sb.config.show_date {
		text_array << time.now().custom_format('M/D')
	}
	if sb.config.show_battery_percent {
		text_array << '${hw.get_batt_percent()}%'
	}
	if sb.config.show_battery_voltage {
		text_array << '${hw.get_batt_volts()}V'
	}
	text_array << '${hw.get_wifi_strength()}'
	$if emu ? {
		text_array << get_fps(dwg)
	}

	mut items := []StatusBarTextItem{}
	mut x := width
	for text_item in text_array {
		x -= 8 // padding
		x -= text_item.len * 8 // 8 = font width
		item := StatusBarTextItem{
			text: text_item
			pos: vec.Vec2[int]{
				x: x
				y: 20 / 2 - int(dwg.font.info.size / 2)
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
		app.dwg.draw_rect_filled(sb.pos.x, sb.pos.y, width, sb_height, app.theme.statusbar_bg_color)
		if app.theme.bg_color == app.theme.statusbar_bg_color {
			app.dwg.draw_line(sb.pos.x - 1, sb.pos.y + sb_height, width, sb.pos.y + sb_height,
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
