// v run .\utils\convert_heroicons.vsh

fn task(command string) {
	println("Running '${command}'")
	execute(command) // result :=
}

icons_dir := './thirdparty/heroicons-ui/svg'
dest_dir := './icons'

println('Copying icons from ${icons_dir} to ${dest_dir}')

files := ls(icons_dir)!

println('Found ${files.len} icons')

mut commands := []string{}
for file in files {
	name := file.split('.')[0].replace('icon-', '')
	commands << [
		'svgexport ${icons_dir}/${file} ${dest_dir}/${name}.png 50:50',
	]
}

mut threads := []thread{}
for command in commands {
	threads << spawn task(command)
}
threads.wait()
println('done')
