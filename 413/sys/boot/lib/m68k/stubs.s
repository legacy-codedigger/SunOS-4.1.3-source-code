| 	stubs.s 	1.1	92/07/30

	.globl	_nullsys, _xxboot, _xxprobe, _ttboot
_nullsys:
_xxprobe:
_xxboot:
_ttboot:
	movl	#-1,d0
	rts
