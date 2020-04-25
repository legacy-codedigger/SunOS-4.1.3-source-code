/*
 * srt0.s - standalone startup code
 *	.seg	"data"
 *	.asciz	"@(#)srt0.s 1.1 92/07/30"
 *	Copyright (c) 1986 by Sun Microsystems, Inc.
 */
 	.seg	"text"
 	.align	4

#include <machine/asm_linkage.h>
#include <machine/param.h>
#include <machine/reg.h>
#include <machine/psl.h>
#include <machine/trap.h>
#include <machine/mmu.h>
#include <mon/idprom.h>

/* 
 * param.h defines VAC, DELAY, and CDELAY
 * if we are compiling for the bootblock undef VAC
 * to save on code size
 */

#ifdef BOOTBLOCK
#undef VAC
#endif

/*
 * Initial interrupt priority and how to get there.
 */
#define PSR_PIL_SHIFT	8
#define PSR_PIL_INIT	(13 << PSR_PIL_SHIFT)

/*
 * The following variables are machine-dependent and are set in fiximp.
 */
	.seg	"data"
	.global	_Cpudelay
/*
 * This variable is used in usec_delay().  See the chart in lib/sparc/misc.s.
 * Srt0.s sets this value based on the actual runtime environment encountered.
 * It's critical that the value be no SMALLER than required, e.g. the
 * DELAY macro guarantees a MINIMUM delay, not a maximum.
 */
_Cpudelay:				! count down counter initial value
#define CPUDELAY_DEFAULT	7
	.word	CPUDELAY_DEFAULT	! worst case value (33 Mhz)
	.global	_nwindows
_nwindows:
#define NWINDOWS_DEFAULT	8
	.word	NWINDOWS_DEFAULT	! max # windows...mustn't be too small
	.global	_npmgrps
_npmgrps:
#define NPMGRPS_DEFAULT		512
	.word	NPMGRPS_DEFAULT		! max # pmegs
	.global	_vac
_vac:
#define VAC_DEFAULT		1
	.word	VAC_DEFAULT		! vac is there by default
	.global	_vac_size
_vac_size:
#define VACSIZE_DEFAULT		0x20000
	.word	VACSIZE_DEFAULT		! 128K
	.global	_vac_linesize
_vac_linesize:
#define VACLINESIZE_DEFAULT	16
	.word	VACLINESIZE_DEFAULT
	.global	_segmask
_segmask:
#define	SEGMASK_DEFAULT		0x1ff
	.word	SEGMASK_DEFAULT		! segmask is 511 by default
	.global _romp
/*
 * The following variables are more or less machine-independent
 * (or are set outside of fiximp).
 */
_romp:
	.word	0
	.global	_cpudelay		! old macros:
_cpudelay:				! shift right amount to scale (n << 4)
	.word	0			! worst case value (25 Mhz)
idp:
	.word	0			! room for idprom format & mach type
	.word	0
	.global	_environ
_environ:
	.word	0			! satisfy references from libc
exitbuf:
	.skip	5*4			! (jump_buf)exitbuf for _exit routine

	.seg	"text"
	.align	8
	.global	_end
	.global	_edata
	.global	__setjmp
	.global	__longjmp
	.global	_main
	.global	__exit
	.global	__exitto
	.global	_start
_start:

#ifdef BOOTBLOCK
	.global _begin, _bootb, _bbsize, _bbchecksum
	b,a	_begin
_bootb:
! should be NBLKENTRIES	(64), see installboot.c
	.skip	64*4			! room for boot_tab
_bbsize:	.word 0
_bbchecksum:	.word 0
_begin:
#endif BOOTBLOCK

! Each standalone program is responsible for its own stack. Our strategy
! is that each program which uses this runtime code creates a stack just
! below its relocation address. Previous windows may (and probably do)
! have frames allocated on the prior stack; leave them alone. Starting with
! this window, allocate our own stack frames for our windows. (Overflows
! or a window flush would then pass seamlessly from our stack to the old.)
! RESTRICTION: A program running at some relocation address must not exec
! another which will run at the very same address: the stacks would collide.
! This is currently not a problem, as all standalone programs (boot, copy,
! kadb, unix, et al.) run at different, carefully chosen addresses...which
! is, of course, a crock.
!
! Careful: don't touch %o0 until the save, since it holds the romp
! for Forth PROMs.
!
	set	_start, %o1
	save	%o1, -SA(MINFRAME), %sp	
acall:
	call	1f			! get the current pc into o7
					! (where _start is currently located)
	sethi	%hi(acall), %o3		! relocated address of call
1:
	sub	%o7,acall-_start,%o0	! address where _start is in memory
	or	%o3, %lo(acall), %o3	! relocated address of call
	cmp	%o3, %o7
	be	jmpstart
	.empty				! next instruction ok in delay slot
	set	_edata+4, %o2		! end of program, inclusive, except bss
	set	_start, %o1		! beginning of program
	sub	%o2, %o1, %o2		! size of program
2:
	ldd	[%o0], %o4		! relocate program
	inc	8, %o0			! bcopy
	std	%o4, [%o1]
	deccc	8, %o2
	bg	2b
	inc	8, %o1
	
	set	jmpstart, %l0		! now that it is relocated, jump to it
	jmp	%l0
	nop

jmpstart:
	set	_romp, %o0		! Stash the romp we've been saving
	st	%i0, [%o0] 
	/*
	 * We need to read idprom to figure out what we are.
	 * Put machine-dependent variables in the following registers:
	 *	%l0	Cpudelay
	 *	%l1	nwindows
	 *	%l2	npmgrps
	 *	%l3	vac
	 *	%l4	vac_size
	 *	%l5	vac_linesize
	 */
fiximp:
	set	idp, %o0
	call	_getidprom
	mov     2, %o1
	cmp	%o0, IDFORM_1
	mov	VACLINESIZE_DEFAULT, %l5
	sethi	%hi(VACSIZE_DEFAULT), %l4
	mov	VAC_DEFAULT, %l3
	mov	NPMGRPS_DEFAULT, %l2
	mov	NWINDOWS_DEFAULT, %l1
	bne	id_badformat
	mov	CPUDELAY_DEFAULT, %l0
	set	idp, %o1
	ldub	[%o1+1], %o0
#ifdef sun4
	cmp	%o0, IDM_SUN4
	be	id_sunrise		! Sunrise?
	cmp	%o0, IDM_SUN4_COBRA
	be	id_cobra		! Cobra?
	cmp	%o0, IDM_SUN4_STINGRAY
	be	id_stingray		! Stingray?
	cmp	%o0, IDM_SUN4_SUNRAY
	be	id_sunray		! Sunray?
	nop
id_cobra:
	set     _segmask, %o1
	set     0xff, %o2
	st      %o2, [%o1]		! set segmask to 0xff
	mov	7, %l0			! set Cpudelay to 7
	mov	NPMGRPS_110, %l2	! set npmgrps
	mov	%g0, %l3		! set vac to zero
	ba	set_delay
	.empty				! use delay slot to set nwindows
/*
 * All of the Cpudelay values used are for cache off.
 */
id_sunrise:
	mov	7, %l1			! set nwindows to 7
	mov	NPMGRPS_260, %l2	! set npmgrps
	ba	set_delay
	mov	1, %l0			! set Cpudelay to 1
id_stingray:
	mov	7, %l1			! set nwindows to 7
	mov	NPMGRPS_330, %l2	! set npmgrps
	ba	set_delay
	mov	1, %l0			! set Cpudelay to 1
id_sunray:
	mov	NPMGRPS_460, %l2	! set npmgrps
	mov	VAC_LINESIZE_SUNRAY, %l5
	mov	1, %l0			! set Cpudelay to 1
#else sun4
/*
 * XXX - This should all come from the open prom properties.
 */
	mov	1, %l0			! set Cpudelay to 1
	cmp	%o0, IDM_SUN4C_60
	be	id_campus1		! Campus-1?
	cmp	%o0, IDM_SUN4C_40
	be	id_campus1		! Office-1?
	cmp	%o0, IDM_SUN4C_65
	be,a	id_campus1		! Campus-B?
	mov	1, %l0			! set Cpudelay to 1
	cmp	%o0, IDM_SUN4C_20
	be	id_campus1		! Off-campus?
	cmp	%o0, IDM_SUN4C_70
	be,a	id_calvin		! Calvin?
	mov	1, %l0			! set Cpudelay to 1
id_campus1:
	mov	7, %l1			! set nwindows to 7
	mov	NPMGRPS_60, %l2		! set npmgrps
	sethi	%hi(VAC_SIZE_60), %l4
	mov	VAC_LINESIZE_60, %l5
	ba	set_delay
	mov	%g0, %l3		! set vac to zero
id_calvin:
	mov	8, %l1			! set nwindows to 8
	mov	256, %l2		! set npmgrps
	sethi	%hi(VAC_SIZE_60*2), %l4
	mov	VAC_LINESIZE_60*2, %l5
	mov	%g0, %l3		! set vac to zero
#endif sun4
id_badformat:
set_delay:
	sethi	%hi(_Cpudelay), %o0
	st	%l0, [%o0 + %lo(_Cpudelay)] ! set Cpudelay
	sethi	%hi(_nwindows), %o0
	st	%l1, [%o0 + %lo(_nwindows)] ! set nwindows
	sethi	%hi(_npmgrps), %o0
	st	%l2, [%o0 + %lo(_npmgrps)] ! set npmgrps
	sethi	%hi(_vac), %o0
	st	%l3, [%o0 + %lo(_vac)]	! set vac
	sethi	%hi(_vac_size), %o0
	st	%l3, [%o0 + %lo(_vac_size)]
	sethi	%hi(_vac_linesize), %o0
#ifdef VAC
	call	init_cache
#endif
	st	%l3, [%o0 + %lo(_vac_linesize)]
	set	_edata, %o0		! beginning of bss
	set	_end+4, %o1		! end of bss
	call	_bzero			! zero the bss
	sub	%o1, %o0, %o1		! size of bss

!
! Set the psr into a known state, until we are sure it is:
! supervisor mode, interrupt level >= 13, traps enabled
!
	mov	%psr, %o0
	andn	%o0, PSR_PIL, %o0
	set	PSR_S|PSR_PIL_INIT|PSR_ET, %o1
	or	%o0, %o1, %o0
	mov	%o0, %psr
	nop; nop; nop
#ifdef sun4c
	call	_l14enable		! turn on level 14 interrupts
	nop
#endif !sun4c
!
! Mark this spot.
!
	sethi	%hi(exitbuf), %o0
	call	__setjmp
	or	%o0, %lo(exitbuf), %o0
	tst	%o0			! returned 1: we exit now.
	bnz	out
	nop
	call	_main
	mov	0, %o0			! delay slot
! Fall through...
!
! __exit means exit NOW. We may be arbitrarily deep in the windows, so longjmp.
!

#ifndef VAC

__exit:
	set	exitbuf, %o0
	call	__longjmp
	mov	1, %o1
out:
	ret				! ret to prom
	restore

__exitto:
	save	%sp, -SA(MINFRAME), %sp
	set	_romp, %o0		! pass the romp to the callee
	jmpl	%i0, %o7		! call thru register
	ld	[%o0], %o0
	ret
	restore

#else !VAC

__exit:
	save	%sp, -SA(MINFRAME), %sp
	set	_vac, %o0		! check vac flag
	ld	[%o0], %o0		
	tst	%o0
	bz	1f
	call	_turnoff_cache
	nop
1:
	set	exitbuf, %o0
	call	__longjmp
	mov	1, %o1
out:
	ret
	restore

__exitto:
	save	%sp, -SA(MINFRAME), %sp
	!
	! turn off the cache if it's currently on
	!
	set	_vac, %o0		! check vac flag
	ld	[%o0], %o0		
	tst	%o0
	bz	no_cache
	nop
	call	_turnoff_cache
	nop
no_cache:
	set	_romp, %o0		! pass the romp to the callee
	jmpl	%i0, %o7		! call thru register
	ld	[%o0], %o0
	set	_vac, %o0		! check vac flag
	ld	[%o0], %o0		
	tst	%o0
	bz	leave_cache_off
	nop
	call	_turnon_cache
	nop
leave_cache_off:
	ret
	restore

init_cache:
	save	%sp, -SA(MINFRAME), %sp
	set	_vac, %o0		! check vac flag
	ld	[%o0], %o0		
	tst	%o0
	bz	1f
	.empty
	set	_start, %o0		! this doesn't get the stack
	sethi	%hi(_end), %o1
	call	_cache_prog		! clear the NC bits for prog's pages
	or	%o1, %lo(_end), %o1
	call	_turnon_cache
	nop
1:
	ret
	restore
#endif VAC
