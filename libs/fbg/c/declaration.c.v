module c

pub const (
	used_import = 1
)

// #flag -D WITHOUT_STB_IMAGE
// #flag -D WITHOUT_JPEG
#flag -O0

// ----- fbgraphics.h -----
#flag -I @VMODROOT/thirdparty/fbg/src

#flag @VMODROOT/thirdparty/fbg/src/lodepng.o
// #flag @VMODROOT/thirdparty/fbg/src/nanojpeg.o
#flag @VMODROOT/thirdparty/fbg/src/fbgraphics.o

#include "fbgraphics.h"
// insert any backends from ../custom_backend/backend_name folder
