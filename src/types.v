import gx

// enum Color {
// 	black
// 	white
// 	inv
// }

type TColor = bool | gx.Color

pub struct Point {
mut:
	x f32
	y f32
}
