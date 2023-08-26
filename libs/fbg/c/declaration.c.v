module c

import math

pub const (
	used_import = 1
)



#include "sys/stat.h"
// #include "sys/time.h"
#include "signal.h"

// from fbgraphics.h
#include <time.h>
#include <sys/time.h>
#include <stdint.h>
#include <math.h>


// ----- fbgraphics.h -----
#flag -I @VMODROOT/thirdparty/fbg/src
// ----- fbg_fbdev.h ------
#flag -I @VMODROOT/thirdparty/fbg/custom_backend/fbdev

// ../src/lodepng/lodepng.c ../src/nanojpeg/nanojpeg.c
#flag @VMODROOT/thirdparty/fbg/src/lodepng.o
#flag @VMODROOT/thirdparty/fbg/src/nanojpeg.o
#flag @VMODROOT/thirdparty/fbg/src/fbgraphics.o
#flag @VMODROOT/thirdparty/fbg/src/fbg_fbdev.o

#include "fbgraphics.h"
// insert any backends from ../custom_backend/backend_name folder
#include "fbg_fbdev.h" 