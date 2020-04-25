#ifndef lint
static	char sccsid[] = "@(#)rules.c 1.1 92/08/05 SMI"; /* from S5R2 1.2 03/28/83 */
#endif

#include "defs"
/* DEFAULT RULES FOR UNIX */

/*
 *	These are the internal rules that "make" trucks around with it at
 *	all times. One could completely delete this entire list and just
 *	conventionally define a global "include" makefile which had these
 *	rules in it. That would make the rules dynamically changeable
 *	without recompiling make. This file may be modified to local
 *	needs. There are currently two versions of this file with the
 *	source; namely, rules.c (which is the version running in Columbus)
 *	and pwbrules.c which is my attempt at satisfying the requirements
 *	of PWB systems.
 *	The makefile for make (make.mk) is parameterized for a different
 *	rules file. The macro $(RULES) defined in "make.mk" can be set
 *	to another file and when "make" is "made" the procedure will
 *	use the new file. The recommended way to do this is on the
 *	command line as follows:
 *		"make -f make.mk RULES=pwbrules"
 */

CHARSTAR builtin[] =
	{
	".SUFFIXES: .o .c .c~ .mod .mod~ .sym .def .def~ .p .p~ .f .f~ .F .F~ .r .r~ .y .y~ .l .l~ .s .s~ .sh .sh~ .h .h~",

/* PRESET VARIABLES */
	"MAKE=make",
	"YACC=yacc",
	"YFLAGS=",
	"LEX=lex",
	"LFLAGS=",
	"LD=ld",
	"LDFLAGS=",
	"CC=cc",
	"CFLAGS=",
	"PC=pc",
	"PFLAGS=",
	"M2C=m2c",
	"M2FLAGS=",
	"FC=f77",
	"FFLAGS=",
	"RFLAGS=",
	"AS=as",
	"ASFLAGS=",
	"GET=/usr/sccs/get",
	"GFLAGS=",

/* SINGLE SUFFIX RULES */
	".c:",
		"\t$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@",
	".c~:",
		"\t$(GET) -G$*.c $(GFLAGS) $<",
		"\t$(CC) $(CFLAGS) $(LDFLAGS) $*.c -o $*",
	".p:",
		"\t$(PC) $(PFLAGS) $(LDFLAGS) $< -o $@",
	".p~:",
		"\t$(GET) -G$*.p $(GFLAGS) $<",
		"\t$(PC) $(PFLAGS) $(LDFLAGS) $*.p -o $*",
	".mod:",
		"\t$(M2C) $(M2FLAGS) $(LDFLAGS) $< -e $@ -o $@",
	".mod~:",
		"\t$(GET) -G$*.mod $(GFLAGS) $<",
		"\t$(M2C) $(M2FLAGS) $(LDFLAGS) $*.mod -e $* -o $*",
	".f:",
		"\t$(FC) $(FFLAGS) $(LDFLAGS) $< -o $@",
	".f~:",
		"\t$(GET) -G$*.f $(GFLAGS) $<",
		"\t$(FC) $(FFLAGS) $(LDFLAGS) $*.f -o $*",
	".F:",
		"\t$(FC) $(FFLAGS) $(LDFLAGS) $< -o $@",
	".F~:",
		"\t$(GET) -G$*.F $(GFLAGS) $<",
		"\t$(FC) $(FFLAGS) $(LDFLAGS) $*.F -o $*",
	".r:",
		"\t$(FC) $(RFLAGS) $(FFLAGS) $(LDFLAGS) $< -o $@",
	".r~:",
		"\t$(GET) -G$*.r $(GFLAGS) $<",
		"\t$(FC) $(RFLAGS) $(FFLAGS) $(LDFLAGS) $*.r -o $*",
	".sh:",
		"\tcat $< >$@; chmod +x $@",
	".sh~:",
		"\t$(GET) -G$*.sh $(GFLAGS) $<",
		"\tcat $*.sh >$*; chmod +x $@",

/*  DOUBLE SUFFIX RULES  */
	".c.o:",
		"\t$(CC) $(CFLAGS) -c $<",
	".c~.o:",
		"\t$(GET) -G$*.c $(GFLAGS) $<",
		"\t$(CC) $(CFLAGS) -c $*.c",
	".c~.c:",
		"\t$(GET) -G$*.c $(GFLAGS) $<",
	".p.o:",
		"\t$(PC) $(PFLAGS) -c $<",
	".p~.o:",
		"\t$(GET) -G$*.p $(GFLAGS) $<",
		"\t$(PC) $(PFLAGS) -c $*.p",
	".p~.p:",
		"\t$(GET) -G$*.p $(GFLAGS) $<",
	".mod.o:",
		"\t$(M2C) $(M2FLAGS) $<",
	".mod~.o:",
		"\t$(GET) -G$*.mod $(GFLAGS) $<",
		"\t$(M2C) $(M2FLAGS) $*.mod",
	".mod~.mod:",
		"\t$(GET) -G$*.mod $(GFLAGS) $<",
	".def.sym:",
		"\t$(M2C) $(M2FLAGS) $<",
	".def~.sym:",
		"\t$(GET) -G$*.def $(GFLAGS) $<",
		"\t$(M2C) $(M2FLAGS) $*.def",
	".def~.def:",
		"\t$(GET) -G$*.def $(GFLAGS) $<",
	".f.o:",
		"\t$(FC) $(FFLAGS) -c $<",
	".f~.o:",
		"\t$(GET) -G$*.f $(GFLAGS) $<",
		"\t$(FC) $(FFLAGS) -c $*.f",
	".f~.f:",
		"\t$(GET) -G$*.f $(GFLAGS) $<",
	".F.o:",
		"\t$(FC) $(FFLAGS) -c $<",
	".F~.o:",
		"\t$(GET) -G$*.F $(GFLAGS) $<",
		"\t$(FC) $(FFLAGS) -c $*.F",
	".F~.F:",
		"\t$(GET) -G$*.F $(GFLAGS) $<",
	".r.o:",
		"\t$(FC) $(RFLAGS) $(FFLAGS) -c $<",
	".r~.o:",
		"\t$(GET) -G$*.r $(GFLAGS) $<",
		"\t$(FC) $(RFLAGS) $(FFLAGS) -c $*.r",
	".r~.r:",
		"\t$(GET) -G$*.r $(GFLAGS) $<",
	".s.o:",
		"\t$(AS) $(ASFLAGS) -o $@ $<",
	".s~.o:",
		"\t$(GET) -G$*.s $(GFLAGS) $<",
		"\t$(AS) $(ASFLAGS) -o $*.o $*.s",
	".s~.s:",
		"\t$(GET) -G$*.s $(GFLAGS) $<",
	".sh~.sh:",
		"\t$(GET) -G$*.sh $(GFLAGS) $<",
	".y.o:",
		"\t$(YACC) $(YFLAGS) $<",
		"\t$(CC) $(CFLAGS) -c y.tab.c",
		"\trm y.tab.c",
		"\tmv y.tab.o $@",
	".y~.o:",
		"\t$(GET) -G$*.y $(GFLAGS) $<",
		"\t$(YACC) $(YFLAGS) $*.y",
		"\t$(CC) $(CFLAGS) -c y.tab.c",
		"\trm -f y.tab.c",
		"\tmv y.tab.o $*.o",
	".l.o:",
		"\t$(LEX) $(LFLAGS) $<",
		"\t$(CC) $(CFLAGS) -c lex.yy.c",
		"\trm lex.yy.c",
		"\tmv lex.yy.o $@",
	".l~.o:",
		"\t$(GET) -G$*.l $(GFLAGS) $<",
		"\t$(LEX) $(LFLAGS) $*.l",
		"\t$(CC) $(CFLAGS) -c lex.yy.c",
		"\trm -f lex.yy.c",
		"\tmv lex.yy.o $*.o",
	".y.c :",
		"\t$(YACC) $(YFLAGS) $<",
		"\tmv y.tab.c $@",
	".y~.c :",
		"\t$(GET) -G$*.y $(GFLAGS) $<",
		"\t$(YACC) $(YFLAGS) $*.y",
		"\tmv y.tab.c $*.c",
	".y~.y:",
		"\t$(GET) -G$*.y $(GFLAGS) $<",
	".l.c :",
		"\t$(LEX) $(LFLAGS) $<",
		"\tmv lex.yy.c $@",
	".l~.c :",
		"\t$(GET) -G$*.l $(GFLAGS) $<",
		"\t$(LEX) $(LFLAGS) $*.l",
		"\tmv lex.yy.c $*.c",
	".l~.l:",
		"\t$(GET) -G$*.l $(GFLAGS) $<",
	".c.a:",
		"\t$(CC) -c $(CFLAGS) $<",
		"\tar rv $@ $*.o",
		"\trm -f $*.o",
	".c~.a:",
		"\t$(GET) -G$*.c $(GFLAGS) $<",
		"\t$(CC) -c $(CFLAGS) $*.c",
		"\tar rv $@ $*.o",
		"\trm -f $*.o",
	".s~.a:",
		"\t$(GET) -G$*.s $(GFLAGS) $<",
		"\t$(AS) $(ASFLAGS) -o $*.o $*.s",
		"\tar rv $@ $*.o",
		"\t-rm -f $*.o",
	".h~.h:",
		"\t$(GET) -G$*.h $(GFLAGS) $<",
	"markfile.o:	markfile",
		"\tA=@;echo \"static char _sccsid[] = \\042`grep $$A'(#)' markfile`\\042;\" > markfile.c",
		"\tcc -c markfile.c",
		"\trm -f markfile.c",
	0 };

