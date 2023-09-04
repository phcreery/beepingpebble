module main

import gx
import math.vec
import time
import math

pub struct Vertex {
pub mut:
	p        vec.Vec2[f32]
	v        vec.Vec2[f32]
	in_motion bool = false
	sw       time.Time = time.now()
	last_err vec.Vec2[f32] = vec.Vec2[f32]{0, 0}
	err_sum  vec.Vec2[f32] = vec.Vec2[f32]{0, 0}
}

fn new_vertex(p vec.Vec2[f32]) Vertex {
	return Vertex{
		p: p
		v: vec.Vec2[f32]{0, 0}
		in_motion: false
		sw: time.now()
		last_err: vec.Vec2[f32]{0, 0}
		err_sum: vec.Vec2[f32]{0, 0}}
}

pub struct Selector {
pub mut:
	verts        [4]Vertex
	target_verts [4]Vertex
}

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
	selector           Selector
	current_item_index int
	selection_change_sw time.Time = time.now()
}

fn debug_draw_menu_outline(mut ctx Context) {
	item_width := 100
	item_height := 100

	for j in 0 .. 2 {
		for i in 0 .. 4 {
			x := i * item_width
			y := j * item_height
			ctx.draw_rect_empty(x, y, item_width - 1, item_height - 1, gx.red)
			// OR
			// ctx.draw_pixel_inv(x, y)
			// ctx.draw_pixel_inv(x + item_width - 1, y)
			// ctx.draw_pixel_inv(x, y + item_height - 1)
			// ctx.draw_pixel_inv(x + item_width - 1, y + item_height - 1)
			// OR
			// ctx.draw_line(x-2, y, x + 2, y, gx.black)
			// ctx.draw_line(x, y-2, x, y + 2, gx.black)
			// ctx.draw_line(x + item_width-1 - 2, y, x + item_width-1 + 2, y, gx.black)
			// ctx.draw_line(x + item_width-1, y-2, x + item_width-1, y + 2, gx.black)
			// ctx.draw_line(x-2, y + item_height-1, x + 2, y + item_height-1, gx.black)
			// ctx.draw_line(x, y + item_height-1 - 2, x, y + item_height-1 + 2, gx.black)
		}
	}
}

fn create_menu(ctx Context) &Menu {
	mut menu := &Menu{
		items: []
		current_item_index: 0
		selection_change_sw: time.now()
	}

	item_width := 100
	item_height := 100

	for j in 0 .. 2 {
		for i in 0 .. 4 {
			x := i * item_width
			y := j * item_height
			menu.items << MenuItem{'App Name', x + 1, y + 1, item_width - 3, item_height - 3}
		}
	}

	init := menu.items[0]

	menu.selector.verts[0] = new_vertex(vec.Vec2[f32]{init.x, init.y})
	menu.selector.verts[1] = new_vertex(vec.Vec2[f32]{init.x + init.w, init.y})
	menu.selector.verts[2] = new_vertex(vec.Vec2[f32]{init.x + init.w, init.y + init.h})
	menu.selector.verts[3] = new_vertex(vec.Vec2[f32]{init.x, init.y + init.h})
	return menu
}

fn (mut menu Menu) draw(mut ctx Context) {

	menu.update_target_verts()

	for i in 0 .. menu.items.len {
		item := menu.items[i]
		ctx.draw_text(item.x + 10, item.y + item.h - 16, item.name, gx.black)
		// app.ctx.draw_text(10, 10, '!"#', gx.black)
		if i == menu.current_item_index {
			// ctx.draw_rect_filled_inv(item.x, item.y, item.w, item.h)

			// draw the shape where the selector should go
			// ctx.draw_rect_empty(item.x, item.y, item.w, item.h, gx.blue)

			mut points := []Point{len: 4}
			// draw the selector target
			for j in 0 .. menu.selector.target_verts.len {
				points[j] = Point{menu.selector.target_verts[j].p.x, menu.selector.target_verts[j].p.y}
			}
			ctx.draw_polygon(points, gx.orange)

			// draw the selector
			menu.update_selector_verts()
			for j in 0 .. menu.selector.verts.len {
				points[j] = Point{menu.selector.verts[j].p.x, menu.selector.verts[j].p.y}
			}
			// println(points)
			// ctx.draw_polygon(points, gx.green)
			ctx.draw_polygon_filled(points, false)
			// println("drawn")
		}
	}
}

fn (mut menu Menu) update_selector_verts() {
	kp := f32(1)
	ki := f32(0.2)
	kd := f32(10)
	m:=f32(0.5)


	for i in 0 .. menu.selector.verts.len {
		// PID CALCULATIONS
		// http://brettbeauregard.com/blog/2011/04/improving-the-beginners-pid-introduction/
		mut vert := &menu.selector.verts[i]
		mut vert_target := &menu.selector.target_verts[i]

		// give it some ferrofluid feel by delaying the motion of the furthest vertices
		if vert.in_motion == false {
			dt := f32(time.since(menu.selection_change_sw).nanoseconds()) / 1000000000
			dist := vert.p.distance(vec.Vec2[f32]{menu.items[menu.current_item_index].x + menu.items[menu.current_item_index].w/2 , menu.items[menu.current_item_index].y+menu.items[menu.current_item_index].h/2})
			// println("dist: ${int(dist)}, dt: ${dt}")
			if dt*4000 > dist {
				vert.in_motion = true
			} else if dist > menu.items[menu.current_item_index].w * f32(2.5) {
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
			continue
		}
		vert.sw = time.now()
		// dt := f32(time.since(vert.sw).nanoseconds()) / 1000000000 // ~ 0.015 s
		// println("dt: ${dt}")
		dt:=f32(0.015) // 60 fps
		dt_v := vec.Vec2{dt,dt}

		kp_v := vec.Vec2{kp,kp}
		ki_v := vec.Vec2{ki,ki}
		kd_v := vec.Vec2{kd,kd}

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
		f:= output
		a:= f / vec.Vec2{m,m}
		v0 := vert.v
		p0 := vert.p
		vert.v= a * dt_v + v0
		vert.p= p0 + v0 * dt_v + vec.Vec2[f32]{0.5, 0.5} * a * dt_v * dt_v


	}
}

fn (mut menu Menu) update_target_verts() {
	target := menu.items[menu.current_item_index]
	menu.selector.target_verts[0] = new_vertex(vec.Vec2[f32]{target.x, target.y})
	menu.selector.target_verts[1] = new_vertex(vec.Vec2[f32]{target.x + target.w, target.y})
	menu.selector.target_verts[2] = new_vertex(vec.Vec2[f32]{target.x + target.w, target.y + target.h})
	menu.selector.target_verts[3] = new_vertex(vec.Vec2[f32]{target.x, target.y + target.h})
}

fn (mut menu Menu) next() {
	menu.current_item_index = (menu.current_item_index + 1) % menu.items.len
	menu.selection_change_sw = time.now()
}

fn (mut menu Menu) prev() {
	menu.current_item_index = (menu.current_item_index - 1)
	if menu.current_item_index < 0 {
		menu.current_item_index = menu.items.len - 1
	}
	menu.selection_change_sw = time.now()
}

fn (mut menu Menu) down() {
	menu.current_item_index = (menu.current_item_index + 4) % menu.items.len
	menu.selection_change_sw = time.now()
}

fn (mut menu Menu) up() {
	menu.current_item_index = (menu.current_item_index - 4)
	if menu.current_item_index < 0 {
		menu.current_item_index += menu.items.len
	}
	menu.selection_change_sw = time.now()
}
