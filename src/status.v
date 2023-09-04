module main

import gx

pub struct StatusBarTextItem {
pub mut:
	text string
}

pub struct StatusBar {
pub mut:
	items []StatusBarTextItem
}


pub fn create_statusbar(dwg DrawContext) &StatusBar {
	time_item := StatusBarTextItem {
		text: "00:00"
	}
	sb := &StatusBar{
		items: [time_item]
	}
	return sb
}

fn (mut sb StatusBar) draw(mut dwg DrawContext) {
	for item in sb.items {
		dwg.draw_text(0, 0,item.text,  gx.black)
	}
}
