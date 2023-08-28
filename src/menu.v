module main

import gx

pub struct MenuItem {
	name string
	x    int
	y    int
	w    int
	h    int
}

pub struct Menu {
pub mut:
	items              []MenuItem
	current_item_index int
}

fn debug_draw_menu_outline(mut ctx IBPContext) {
	item_width := 100
	item_height := 100

	for j in 0 .. 2 {
		for i in 0 .. 4 {
			x := i * item_width
			y := j * item_height
			ctx.draw_rect_empty(x + 1, y + 1, item_width - 1, item_height - 1, gx.black)
		}
	}
}

fn create_menu(ctx IBPContext) &Menu {
	mut menu := Menu{
		items: []
		current_item_index: 0
	}

	item_width := 100
	item_height := 100

	for j in 0 .. 2 {
		for i in 0 .. 4 {
			x := i * item_width
			y := j * item_height
			menu.items << MenuItem{'a', x + 1, y + 1, item_width - 1, item_height - 1}
		}
	}
	return &menu
}

fn (menu &Menu) draw(mut ctx IBPContext) {
	for i in 0 .. menu.items.len {
		item := menu.items[i]
		if i == menu.current_item_index {
			ctx.draw_rect_filled_inv(item.x, item.y, item.w, item.h)
			// ctx.draw_rect_empty(item.x, item.y, item.w, item.h, gx.green)
		}
		ctx.draw_text(item.x + 10, item.y + 10, item.name, gx.black)
	}
}

fn (mut menu Menu) next() {
	menu.current_item_index = (menu.current_item_index + 1) % menu.items.len
}

fn (mut menu Menu) prev() {
	menu.current_item_index = (menu.current_item_index - 1)
	if menu.current_item_index < 0 {
		menu.current_item_index = menu.items.len - 1
	}
}

fn (mut menu Menu) down() {
	menu.current_item_index = (menu.current_item_index + 4) % menu.items.len
}

fn (mut menu Menu) up() {
	menu.current_item_index = (menu.current_item_index - 4)
	if menu.current_item_index < 0 {
		menu.current_item_index += menu.items.len
	}
}
