import gx

// enum Color {
// 	black
// 	white
// 	inv
// }

type TColor = gx.Color | bool

pub struct Point {
mut:
	x f32
	y f32
}
