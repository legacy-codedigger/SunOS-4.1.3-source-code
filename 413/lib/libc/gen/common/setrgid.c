#if !defined(lint) && defined(SCCSIDS)
static	char sccsid[] = "@(#)setrgid.c 1.1 92/07/30 SMI"; /* from UCB 4.1 83/06/30 */
#endif

setrgid(rgid)
	int rgid;
{

	return (setregid(rgid, -1));
}
