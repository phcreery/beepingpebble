module main

import gx
import math.vec
import time
import math
import stbi
import hw

pub struct Vertex {
pub mut:
	p         vec.Vec2[f32]
	v         vec.Vec2[f32]
	in_motion bool
	sw        time.Time     = time.now()
	last_err  vec.Vec2[f32] = vec.Vec2[f32]{0, 0}
	err_sum   vec.Vec2[f32] = vec.Vec2[f32]{0, 0}
}

fn new_vertex(p vec.Vec2[f32]) Vertex {
	return Vertex{
		p: p
		v: vec.Vec2[f32]{0, 0}
		in_motion: false
		sw: time.now()
		last_err: vec.Vec2[f32]{0, 0}
		err_sum: vec.Vec2[f32]{0, 0}
	}
}

pub struct Selector {
pub mut:
	verts        [4]Vertex
	target_verts [4]Vertex
}

pub struct MenuItem {
	name    string
	icon    string
	desc    string
	command string
}

pub struct Menu {
pub mut:
	items               []MenuItem
	page                int
	page_size           int
	item_width          int
	item_height         int
	item_padding        int
	selector            Selector
	current_item_index  int
	need_update         bool
	selection_change_sw time.Time = time.now()
	cached_icons        map[string]stbi.Image
}

fn (mut menu Menu) loc_from_index(index int) vec.Vec2[int] {
	y_origin := 20
	x_i := index % 4
	y_i := index / 4
	return vec.Vec2[int]{
		x: x_i * (menu.item_width + menu.item_padding + 1) + menu.item_padding / 2
		y: y_i * (menu.item_height + menu.item_padding + 1) + menu.item_padding / 2 + y_origin
	}
}

fn create_menu(dwg DrawContext) &Menu {
	padding := 2
	mut menu := &Menu{
		items: []
		page: 0
		page_size: 8
		item_width: 100 - padding - 1
		item_height: 100 - padding - 1
		item_padding: padding
		current_item_index: 0
		selection_change_sw: time.now()
		need_update: true
		cached_icons: load_internal_icons()
	}

	menu.items << MenuItem{'Beeper', 'icons/beeper-icon.png', '', ''}
	// menu.items << MenuItem{'Settings', 'icons/settings-icon.png', '', ''}
	menu.items << MenuItem{
		name: 'ls'
		icon: 'icons/terminal-icon.png'
		desc: 'list files in current directory'
		command: 'ls'
	}

	init := menu.loc_from_index(0)
	init_x := init.x
	init_y := init.y
	init_w := menu.item_width
	init_h := menu.item_height

	menu.selector.verts[0] = new_vertex(vec.Vec2[f32]{init_x, init_y})
	menu.selector.verts[1] = new_vertex(vec.Vec2[f32]{init_x + init_w, init_y})
	menu.selector.verts[2] = new_vertex(vec.Vec2[f32]{init_x + init_w, init_y + init_h})
	menu.selector.verts[3] = new_vertex(vec.Vec2[f32]{init_x, init_y + init_h})
	return menu
}

fn (mut menu Menu) draw(mut app App) {
	if !menu.need_update {
		return
	}

	// Background
	app.dwg.draw_rect_filled(0, 20, 400, 240 - 20, app.theme.bg_color)

	menu.update_target_verts()

	// Description Background
	// app.dwg.draw_rect_filled(0, 240 - 20, 400, 20, false)
	app.dwg.draw_line_pattern(30, 240 - 20, 360, 240 - 20, false)

	for i in 0 .. menu.page_size {
		index := menu.page * menu.page_size + i
		if index >= menu.items.len {
			break
		}
		item := menu.items[index]
		pos := menu.loc_from_index(i)
		name := item.name.limit(int(400 / 4 / 8))
		name_w := app.dwg.get_draw_text_width(name)
		icon := menu.cached_icons[item.icon]
		app.dwg.draw_text(pos.x + menu.item_width / 2 - int(name_w / 2), pos.y + menu.item_height - 16,
			name, false)
		app.dwg.draw_image(pos.x + menu.item_width / 2 - int(icon.width / 2), pos.y + 15,
			menu.cached_icons[item.icon], false)
		if index == menu.current_item_index {
			desc := item.desc.limit(int(370 / 8))
			// app.dwg.draw_rect_empty(pos.x, pos.y, menu.item_width, menu.item_height, gx.white)
			desc_w := app.dwg.get_draw_text_width(desc)
			app.dwg.draw_text(400 / 2 - int(desc_w / 2), 240 - 20 / 2 - int(app.dwg.font.info.size / 2),
				desc, false)
		}
	}
	// draw page indicators
	// for i in 0 .. 2 {
	// 	if i == menu.page {
	// 		app.dwg.draw_text(400 / 2 - 8, 240 - 20 / 2 - int(app.dwg.font.info.size / 2), '\uf111', false) // circle
	// 	} else {
	// 		app.dwg.draw_text(400 / 2 - 8, 240 - 20 / 2 - int(app.dwg.font.info.size / 2), '\uf10c', false) // circle-o
	// 	}
	// }
	if menu.page < menu.items.len / menu.page_size {
		app.dwg.draw_text(400 - 5 - 8, 240 - 20 / 2 - int(app.dwg.font.info.size / 2),
			'\uf054', false) // >
	}
	if menu.page > 0 {
		app.dwg.draw_text(5, 240 - 20 / 2 - int(app.dwg.font.info.size / 2), '\uf053',
			false) // <
	}

	// draw the shape where the selector should go
	mut points := []Point{len: 4}
	for j in 0 .. menu.selector.target_verts.len {
		points[j] = Point{menu.selector.target_verts[j].p.x, menu.selector.target_verts[j].p.y}
	}
	// app.dwg.draw_polygon(points, gx.orange) // debug

	// draw the selector
	// sw := time.new_stopwatch()
	menu.update_selector_verts()
	// println('update_selector_verts took: ${f32(sw.elapsed().nanoseconds())/ 1_000_000}ms')
	for j in 0 .. menu.selector.verts.len {
		points[j] = Point{menu.selector.verts[j].p.x, menu.selector.verts[j].p.y}
	}
	app.dwg.draw_polygon_filled(points, false)
	app.dwg.draw_polygon(points, gx.black) // draw border since draw_polygon_filled does not fill the top, right, and bottom edges

}

fn (mut menu Menu) update_selector_verts() {
	kp := f32(1)
	ki := f32(0.2)
	kd := f32(10)
	m := f32(0.5)

	mut resting_verts := 0
	for i in 0 .. menu.selector.verts.len {
		// PID CALCULATIONS
		// http://brettbeauregard.com/blog/2011/04/improving-the-beginners-pid-introduction/
		mut vert := &menu.selector.verts[i]
		mut vert_target := &menu.selector.target_verts[i]

		current_pos := menu.loc_from_index(menu.current_item_index)
		// give it some ferrofluid feel by delaying the motion of the furthest vertices
		if vert.in_motion == false {
			dt := f32(time.since(menu.selection_change_sw).nanoseconds()) / 1000000000
			dist := vert.p.distance(vec.Vec2[f32]{current_pos.x + menu.item_width / 2,
				current_pos.y + menu.item_height / 2})
			// println("dist: ${int(dist)}, dt: ${dt}")
			if dt * 2000 > dist {
				vert.in_motion = true
			} else if dist > menu.item_width * f32(2.5) {
				// if its too far away, put it in motion
				vert.in_motion = true
			} else {
				continue
			}
		}
		// if its already at the target, snap it into place, and skip calculations
		if vert.p.distance(vert_target.p) < 5 {
			vert.p.x = f32(math.round(vert_target.p.x))
			vert.p.y = f32(math.round(vert_target.p.y))
			vert.v = vec.Vec2[f32]{0, 0}
			vert.last_err = vec.Vec2[f32]{0, 0}
			vert.err_sum = vec.Vec2[f32]{0, 0}
			vert.in_motion = false
			resting_verts += 1
			continue
		}

		vert.sw = time.now()
		// dt := f32(time.since(vert.sw).nanoseconds()) / 1000000000 // ~ 0.015 s
		// println("dt: ${dt}")
		dt := f32(0.015) // 60 fps
		dt_v := vec.Vec2{dt, dt}

		kp_v := vec.Vec2{kp, kp}
		ki_v := vec.Vec2{ki, ki}
		kd_v := vec.Vec2{kd, kd}

		last_err := vert.last_err
		mut err_sum := vert.err_sum

		err := vert_target.p - vert.p
		err_sum = (err * dt_v) + err_sum
		d_err := (err - last_err) / dt_v
		output := kp_v * err + ki_v * err_sum + kd_v * d_err

		// re-assign
		vert.last_err = err
		vert.err_sum = err_sum

		// FORCE/ACCEL CALCULATIONS
		// https://en.wikipedia.org/wiki/Equations_of_motion
		f := output
		a := f / vec.Vec2{m, m}
		v0 := vert.v
		p0 := vert.p
		vert.v = a * dt_v + v0
		vert.p = p0 + v0 * dt_v + vec.Vec2[f32]{0.5, 0.5} * a * dt_v * dt_v
	}
	if resting_verts >= menu.selector.verts.len {
		menu.need_update = false
	}
}

fn (mut menu Menu) update_target_verts() {
	pos := menu.loc_from_index(menu.current_item_index)
	target_x := pos.x
	target_y := pos.y
	target_w := menu.item_width
	target_h := menu.item_height
	menu.selector.target_verts[0] = new_vertex(vec.Vec2[f32]{target_x, target_y})
	menu.selector.target_verts[1] = new_vertex(vec.Vec2[f32]{target_x + target_w, target_y})
	menu.selector.target_verts[2] = new_vertex(vec.Vec2[f32]{target_x + target_w, target_y +
		target_h})
	menu.selector.target_verts[3] = new_vertex(vec.Vec2[f32]{target_x, target_y + target_h})
}

fn menu_item_from_desktop_entry(entry DesktopEntry) MenuItem {
	mut command := ''
	if !entry.terminal {
		panic('Only terminal apps are supported')
	}
	if entry.type_ == 'Application' {
		command = entry.exec
	} else if entry.type_ == 'Link' {
		command = 'open ' + entry.url
	} else if entry.type_ == 'Directory' {
		command = 'cd ' + entry.path
	} else {
		panic('Unknown Desktop Entry type: ' + entry.type_)
	}
	return MenuItem{
		name: entry.name
		icon: entry.icon
		desc: entry.comment
		command: command
	}
}

fn menu_items_from_desktop_entries(entries []DesktopEntry) []MenuItem {
	mut items := []MenuItem{len: entries.len}
	for i in 0 .. entries.len {
		items[i] = menu_item_from_desktop_entry(entries[i])
	}
	return items
}

fn (mut menu Menu) add_desktop_entries_to_menu(entries []DesktopEntry) {
	items := menu_items_from_desktop_entries(entries)
	for item in items {
		if item.icon !in menu.cached_icons {
			icon := load_image(item.icon)
			menu.cached_icons[item.icon] = icon
		}
		menu.items << item
	}
}

fn (mut menu Menu) next() {
	menu.current_item_index = (menu.current_item_index + 1)
	if menu.current_item_index % (8 / 2) == 0 {
		menu.current_item_index = menu.current_item_index - 1
		menu.page += 1
		if menu.page * menu.page_size >= menu.items.len {
			menu.page -= 1
		}
	}
	menu.need_update = true
	menu.selection_change_sw = time.now()
}

fn (mut menu Menu) prev() {
	menu.current_item_index = (menu.current_item_index - 1)
	if menu.current_item_index % (8 / 2) == 3 || menu.current_item_index < 0 {
		menu.current_item_index = menu.current_item_index + 1
		menu.page -= 1
		if menu.page < 0 {
			menu.page = 0
		}
	}
	menu.need_update = true
	menu.selection_change_sw = time.now()
}

fn (mut menu Menu) down() {
	menu.current_item_index = (menu.current_item_index + 4)
	if menu.current_item_index >= menu.page_size {
		menu.current_item_index -= 4
	}
	menu.need_update = true
	menu.selection_change_sw = time.now()
}

fn (mut menu Menu) up() {
	menu.current_item_index = (menu.current_item_index - 4)
	if menu.current_item_index < 0 {
		menu.current_item_index += 4
	}
	menu.need_update = true
	menu.selection_change_sw = time.now()
}

fn (mut menu Menu) goto_index_on_page(i int) {
	menu.current_item_index = i + menu.page * menu.page_size
	menu.need_update = true
	// menu.selection_change_sw = time.now() // disabled to prevent the fluid animation
}

fn (mut menu Menu) get_selected() MenuItem {
	return menu.items[menu.current_item_index + menu.page * menu.page_size]
}

fn (mut menu Menu) handle_key_event(mut ev hw.Event) {
	match ev.key_code {
		.right, .d {
			menu.next()
		}
		.left, .w {
			menu.prev()
		}
		.up, .e {
			menu.up()
		}
		.down, .s {
			menu.down()
		}
		.y {
			menu.goto_index_on_page(0)
		}
		.u {
			menu.goto_index_on_page(1)
		}
		.i {
			menu.goto_index_on_page(2)
		}
		.o {
			menu.goto_index_on_page(3)
		}
		.h {
			menu.goto_index_on_page(4)
		}
		.j {
			menu.goto_index_on_page(5)
		}
		.k {
			menu.goto_index_on_page(6)
		}
		.l {
			menu.goto_index_on_page(7)
		}
		else {
			println('unused key: ${ev} ${ev.key_code} ${ev.key_code}')
		}
	}
}
