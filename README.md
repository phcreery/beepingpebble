# BEEPINGPEBBLE

![Screenshot](doc/image.png)

## About

A launcher for the beepy (formerly beepberry) with a pebble watch PebbleUI inspiration

The launcher is written in V, a transpiled-to-C-then-compiled language to increase dev productivity, minimize battery usage, and increase application speed.

Features:

- [ ] load app config from text file
- [ ] launch apps
- [ ] Battery status
- [ ] WIFI status
- [ ] Light/Dark mode
- [x] custom graphics library
- [x] rasterized text to avoid anti-aliased "soft" text
- [ ] 30/60fps (currently ~10fps with hight cpu usage on rpi zero 2)
- [ ] vsync (untested)
- [x] direct framebuffer writing
- [x] framebuffer emulation for development on windows & linux
