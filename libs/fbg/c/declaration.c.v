module c

pub const (
	used_import = 1
)

// #flag -D WITHOUT_STB_IMAGE
// #flag -D WITHOUT_JPEG

$if windows {
	// #include "sys/time.h"
	// gcc libs path
	// #include <stdarg.h>
	// #include <stdint.h>
	// #flag -I C:\msys64\mingw64\include
	// #flag -I @VEXEROOT/thirdparty/tcc/include
	// #flag -L C:\msys64\mingw64\lib
}

// ----- fbgraphics.h -----
#flag -I @VMODROOT/thirdparty/fbg/src

#flag @VMODROOT/thirdparty/fbg/src/lodepng.o
// #flag @VMODROOT/thirdparty/fbg/src/nanojpeg.o
#flag @VMODROOT/thirdparty/fbg/src/fbgraphics.o

#include "fbgraphics.h"
// insert any backends from ../custom_backend/backend_name folder
