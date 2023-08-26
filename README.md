```
~/v/beepingpebble/thirdparty/fbg/src $ gcc -c -I. -I.. -I../.. -I../../src ../src/lodepng/lodepng.c ../src/nanojpeg/nanojpeg.c ../
custom_backend/fbdev/fbg_fbdev.c fbgraphics.c 
~/v/beepingpebble/thirdparty/fbg/src $ v translate wrapper fbgraphics.h
~/v/beepingpebble/thirdparty/fbg/custom_backend/fbdev $ v translate wrapper ./fbg_fbdev.h
```

move the *.v files to `libs/fbg/c`

```
v -showcc -keepc run ./src/
```




## Other
```
fbset -fb /dev/fb1 -g 400 240 400 240 24 -vsync high
cat /dev/urandom >/dev/fb1
```