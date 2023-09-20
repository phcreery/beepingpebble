module main

import stbi
import os

// wrapper withe pre-converted data
pub struct STBIImageWrapper {
mut:
	stbiimg &stbi.Image
	data    []u8
}

// -a----         9/12/2023   8:42 PM            596 announcement.png
// -a----         9/12/2023   8:41 PM            431 archive.png
// -a----         9/12/2023   8:41 PM            338 arrow-down.png
// -a----         9/12/2023   8:41 PM            264 arrow-left.png
// -a----         9/12/2023   8:41 PM            337 arrow-up.png
// -a----         9/12/2023   8:41 PM            864 at-symbol.png
// -a----         5/28/2023   8:25 PM            952 beeper-icon.png
// -a----         9/12/2023   8:41 PM            424 book.png
// -a----         9/12/2023   8:41 PM            387 bookmark.png
// -a----         9/12/2023   8:41 PM            428 briefcase.png
// -a----         9/12/2023   8:42 PM            472 building.png
// -a----         5/28/2023   8:25 PM            392 cal-icon.png
// -a----         9/12/2023   8:41 PM            437 calander.png
// -a----         9/12/2023   8:41 PM            824 call-incoming.png
// -a----         9/12/2023   8:42 PM            716 call.png
// -a----         9/12/2023   8:42 PM            673 camera.png
// -a----         9/12/2023   8:41 PM            618 cart.png
// -a----         9/12/2023   8:42 PM            495 chat.png
// -a----         9/12/2023   8:42 PM            760 check-circle.png
// -a----         9/12/2023   8:41 PM            225 cheveron-down.png
// -a----         9/12/2023   8:41 PM            209 cheveron-right.png
// -a----         9/12/2023   8:42 PM            221 cheveron-up.png
// -a----         9/12/2023   8:41 PM            663 clip.png
// -a----         9/12/2023   8:41 PM            436 clipboard.png
// -a----         9/12/2023   8:42 PM            725 clock.png
// -a----         5/28/2023   8:25 PM            489 cloud-icon.png
// -a----         9/12/2023   8:41 PM            493 code.png
// -a----         9/12/2023   8:41 PM            859 cog.png
// -a----         9/12/2023   8:42 PM            849 compass.png
// -a----         9/12/2023   8:42 PM            946 currency-dollar.png
// -a----         9/12/2023   8:41 PM            408 desktop.png
// -a----         9/12/2023   8:42 PM            830 discount.png
// -a----         5/28/2023   8:25 PM            513 download-icon.png
// -a----         9/12/2023   8:42 PM            453 duplicate.png
// -a----         9/12/2023   8:42 PM            574 edit.png
// -a----         9/12/2023   8:42 PM            724 exclamation.png
// -a----         9/12/2023   8:42 PM            522 external-link.png
// -a----         9/12/2023   8:43 PM            390 file-blank.png
// -a----         9/12/2023   8:41 PM            504 file-plus.png
// -a----         9/12/2023   8:42 PM            503 flag.png
// -a----         9/12/2023   8:42 PM            416 graph-bar.png
// -a----         9/12/2023   8:42 PM            545 hashtag.png
// -a----         9/12/2023   8:42 PM            529 image.png
// -a----         9/12/2023   8:42 PM            450 inbox.png
// -a----         9/12/2023   8:42 PM            743 link.png
// -a----         9/12/2023   8:42 PM            502 lock-closed.png
// -a----         9/12/2023   8:42 PM            421 mail.png
// -a----         9/12/2023   8:42 PM            329 minus-square.png
// -a----         9/12/2023   8:42 PM            676 moon.png
// -a----         9/12/2023   8:42 PM            442 more-horiz.png
// -a----         9/12/2023   8:43 PM            653 music.png
// -a----         9/12/2023   8:42 PM            561 news.png
// -a----         9/12/2023   8:42 PM            726 plus-circle.png
// -a----         9/12/2023   8:42 PM            391 plus-square.png
// -a----         9/12/2023   8:42 PM            507 print.png
// -a----         9/12/2023   8:42 PM            768 refresh.png
// -a----         9/12/2023   8:42 PM            540 repeat.png
// -a----         9/12/2023   8:41 PM            789 rocket.png
// -a----         9/12/2023   8:42 PM            631 search.png
// -a----         9/12/2023   8:42 PM            425 server.png
// -a----         5/28/2023   8:25 PM            615 settings-icon.png
// -a----         9/12/2023   8:42 PM            613 speaker.png
// -a----         9/12/2023   8:42 PM            655 star.png
// -a----         9/12/2023   8:42 PM            515 tag.png
// -a----         5/28/2023   8:25 PM            366 terminal-icon.png
// -a----         9/12/2023   8:42 PM            429 video.png
// -a----         9/12/2023   8:43 PM            459 x-square.png
// -a----         9/12/2023   8:42 PM            271 x.png
// -a----         9/12/2023   8:42 PM            686 zoom-out.png

pub fn load_internal_icons() map[string]stbi.Image {
	mut icon_array := [
		$embed_file('icons/beeper-icon.png'),
		$embed_file('icons/cal-icon.png'),
		$embed_file('icons/cloud-icon.png'),
		$embed_file('icons/download-icon.png'),
		$embed_file('icons/settings-icon.png'),
		$embed_file('icons/terminal-icon.png'),

		$embed_file('icons/rocket.png'),
	]

	mut icons := map[string]stbi.Image{}

	for mut icon in icon_array {
		data := icon.data()
		mut img := stbi.load_from_memory(data, icon.len, stbi.LoadParams{
			desired_channels: 4
		}) or { panic('failed to load image') }
		icons[icon.path] = img
	}

	// println("icons ${icons}")
	// d := arrays.carray_to_varray[u8](img.data, img.width * img.height * img.nr_channels)
	// println("image ${img}")

	return icons
}

pub fn load_image(image_path string) stbi.Image {
	// mut icon := os.open('icons/beeper-icon.png') or { panic('failed to open image') }
	// data := icon.read_bytes()
	buffer := os.read_bytes(image_path) or { panic('failed to read image') }
	// buffer.data is a pointer to the heap memory
	mut img := stbi.load_from_memory(buffer.data, buffer.len, stbi.LoadParams{
		desired_channels: 4
	}) or { panic('failed to load image') }
	return img
}
