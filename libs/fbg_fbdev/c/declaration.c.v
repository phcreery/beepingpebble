module c

pub const (
	used_import = 1
)

// ----- fbg_fbdev.h ------
#flag -I @VMODROOT/thirdparty/fbg/custom_backend/fbdev
#flag @VMODROOT/thirdparty/fbg/src/fbg_fbdev.o
#include "fbg_fbdev.h"
