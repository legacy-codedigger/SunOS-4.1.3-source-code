#include <sys/types.h>
#include <sys/dir.h>

direct
./{d_ino,X}{d_name,s}
.+({*d_reclen,.})>a
<a,<9-1$<dir.nxt
