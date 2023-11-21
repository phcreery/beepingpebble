## Dev notes

## Beepy Apps and Configuration

https://github.com/k5njm/beepy-hacks

https://github.com/TheMediocritist/beepy_setup/

https://github.com/nwithan8/beepy-config


### Hardware

- 100nF hack
- 2.2uF hack

### System Tweak

- There are many different ways to check the battery. Stats are stored at:

```
/sys/firmware/beepy/battery_percent
/sys/firmware/beepy/battery_raw
/sys/firmware/beepy/battery_volts
```

So you can do (for example):
`cat /sys/firmware/beepy/battery_percent ; echo "%"`

- CPU Temp

`cat /sys/class/thermal/thermal_zone0/temp`

Divide it by 1000 to get the ARM CPU temperature in deg celcius more human readable format:

- CPU Throttling
 - `task-laptop`, `cpufreqd`, `cpufreq-utils` set to conservative or ondemand


5. run TheMediocritist installer script (works! fixes current keyboard issues as of 2023-08ish) `curl -s https://raw.githubusercontent.com/TheMediocritist/beepy_setup/main/temp_beepy_setup.sh | bash`
6. optional, restrict cpu cores to 2 [link](https://beepy.sqfmi.com/docs/software/os-image#pi-zero-2w-settings)
7. update system `sudo apt-get update`
8. optional, install pyenv ` curl https://pyenv.run | bash `
9. optional, install `jrnl` [link](https://jrnl.sh/en/stable/installation/)
10. optional, install `beepy` [link](https://beeper.notion.site/Beepy-Beeper-Client-Setup-Tutorial-a2200b76f8764813bf7a70e9f69f46b3)
11. optional, install `obsdian-cli` [link](https://gist.github.com/knickish/a3bc718340b81134a7096283ad94db74)

### framebuffer

```
fbset -fb /dev/fb1 -g 400 240 400 240 24 -vsync high
setterm -cursor off > /dev/tty0
cat /dev/urandom >/dev/fb1
```

### using fbd

```
thirdparty/fbg/src $ find . -name "*.o" -type f -delete

ON RPI
thirdparty/fbg/src $ gcc -c -I. -I.. -I../.. -I../../src ../src/lodepng/lodepng.c ../src/nanojpeg/nanojpeg.c ../custom_backend/fbdev/fbg_fbdev.c fbgraphics.c

ON WINDOWS
thirdparty/fbg/src $ gcc -DWITHOUT_JPEG -DWITHOUT_STB_IMAGE -c -I. -I.. -I../.. -I../../src ../src/lodepng/lodepng.c fbgraphics.c

TO CREATE V LIB HEADERS
thirdparty/fbg/src $ v translate wrapper fbgraphics.h
thirdparty/fbg/custom_backend/fbdev $ v translate wrapper ./fbg_fbdev.h
```

testing quickstart example `gcc ../src/lodepng/lodepng.c ../src/nanojpeg/nanojpeg.c ../src/fbgraphics.c .\quickstart.c -I ../src/ -I.`

move the \*.v files to `libs/fbg/c`

## Using SDL

https://gamedev.stackexchange.com/questions/157604/how-to-get-access-to-framebuffer-as-a-uint32-t-in-sdl2
https://wiki.libsdl.org/SDL2/MigrationGuide
https://stackoverflow.com/questions/55084655/how-to-draw-a-framebuffer-object-to-the-default-framebuffer
https://stackoverflow.com/questions/30599636/8-bit-surfaces-in-sdl-2

https://github.com/mobius3/KiWi

## RamTex 

https://www.ramtex.dk/products/genericbw.htm

## raylib

raygui does not have any means of keyboard navigation

https://www.raylib.com/index.html
https://github.com/raysan5/raylib/issues/1370
https://avikdas.com/2019/01/23/writing-gui-applications-on-raspberry-pi-without-x.html

