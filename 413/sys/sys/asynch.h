/*	@(#) asynch.h 1.1 92/07/30 SMI	*/

/*
 * Copyright (c) 1988 by Sun Microsystems, Inc.
 */

#ifndef _sys_asynch_h
#define _sys_asynch_h

#include <lwp/lwp.h>

#define	AIO_INPROGRESS	-2	/* values not set by the system */
#define ALL_AIO -1		/* used by exec and exit to kill all aio */
#define	MAXASYNCHIO	200	/* maximum number of system asynch IO's at once */

typedef struct aio_result_t {
	int aio_return;	/* return value of read or write */
	int aio_errno;	/* errno generated by the IO */
} aio_result_t;

/*
 * The aiodone structure is only used by the kernel
 */
typedef struct aiodone {
	struct aiodone *aiod_next;
	struct aio_result_t *aiod_result;
	thread_t aiod_thread;
	int aiod_state;
	int aiod_fd;
} aiodone_t;

#endif  /*!_sys_asynch_h*/

