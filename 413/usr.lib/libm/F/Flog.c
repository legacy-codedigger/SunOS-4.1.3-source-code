#ifndef lint
static	char sccsid[] = "@(#)Flog.c 1.1 92/07/30 SMI";
#endif

/*
 * Copyright (c) 1987 by Sun Microsystems, Inc.
 */

# include <math.h>

#define func log

FLOATFUNCTIONTYPE F/**/func/**/(x)
FLOATPARAMETER x;
{
	return r_/**/func/**/_(&x);
}
