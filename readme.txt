/*Copyright (C) 2015 Nokia Solutions and Networks. */

/*    This file is part of "Simple ASN.1 Checker".                                   */
/*                                                                                   */
/*   "Simple ASN.1 Checker" is free software: you can redistribute it and/or modify  */
/*    it under the terms of the GNU General Public License as published by           */
/*    the Free Software Foundation, either version 2 of the License, or              */
/*    (at your option) any later version.                                            */
/*                                                                                   */
/*    "Simple ASN.1 Checker" is distributed in the hope that it will be useful,      */
/*    but WITHOUT ANY WARRANTY; without even the implied warranty of                 */
/*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  */
/*    GNU General Public License for more details.                                   */
/*                                                                                   */
/*    You should have received a copy of the GNU General Public License              */
/*    along with "Simple ASN.1 Checker".  If not, see <http://www.gnu.org/licenses/>.*/

Simple ANS.1 Checker (SAC) - User Manual

0. Introduction

Simple ANS.1 Checker (SAC) is a software that compares two versions of the ASN.1 file of 3GPP TS 25.331 or 36.331 and checks the backward compatibility of the ASN.1 source files.


1. Installation and compilation

1.1 Installation and compilation on Linux

1.1.1 Installation

Copy the following files in a directory:

sac.y
sac.l
main.c
parallel.c
ptype_asn.h

Install flex and bison if not done previously. 

This is how to do it on Ubuntu:

	sudo apt-get install flex
	sudo apt-get install bison

1.1.2 Compilation

Use the following command:

	flex sac.l
	bison -d sac.y
	gcc lex.yy.c sac.tab.c parallel.c main.c -o sac.exe


1.1.3 Online version

If you want to use the on-line version: do the compilation as explained above, the rename the executable:

	mv sax.exe sac.cgi

Copy this file in the directory where cgi script should be stored on your server. 

The web page that will launch the cgi scipt will contain the following form:

	<FORM action="../cgi-bin/test.cgi" method="post">
	<P>
	<INPUT type="submit" value="Send"><INPUT type="reset">
	<BR>
	Display IE Chain?<BR>
	<INPUT TYPE=RADIO NAME="IEChain" VALUE="Yes">Yes<BR>
	<INPUT TYPE=RADIO NAME="IEChain" VALUE="No" CHECKED>No<BR>
	Display Warnings ? <BR>

	<INPUT TYPE=RADIO NAME="Warnings" VALUE="Yes">Yes<BR>
	<INPUT TYPE=RADIO NAME="Warnings" VALUE="No" CHECKED>No<BR>
	<BR> 
	<BR>
	<TEXTAREA name="file1" rows="10" cols="80">Copy-Paste here the first file</TEXTAREA>
	<TEXTAREA name="file2" rows="10" cols="80">Copy-Paste here the second file</TEXTAREA>
	</P>
	</FORM>

	
1.2 Installation on Windows

1.2.1 Get a C compiler
You can install MinGW, it is light and fast. (http://www.mingw.org/)

Go to http://www.mingw.org/wiki/InstallationHOWTOforMinGW for instructions.
Installing the C compiler is enough. It should be installed in C:\MinGW\bin

add the gcc compiler directory in the PATH:
	SET PATH=%PATH%;C:\MinGW\bin\

1.2.2 Install Flex and Bison
Go to http://sourceforge.net/projects/winflexbison/
Install it for example on C:\flexbison

1.2.3 Compilation
Add C:\flexbison to the path

	SET PATH=%PATH%;C:\flexbison\
	SET PATH=%PATH%;C:\flexbison\data\m4sugar\

To compile: 

	win_bison -d sac.y
	win_flex sac.l 
	gcc lex.yy.c sac.tab.c parallel.c main.c -o sac.exe
	
2. Usage

2.1 Command Line

This program checks the consistency of ASN.1 between two versions.
It recognizes the SEQUENCE / CHOICE structure and can spot simple mistakes.
It can also recognize the extension mechanism (critical and non critical) used in ASN.1 in TS25.331 and TS36.331.

The syntax is:

sac.exe file1.asn file2.asn [-w] [-ie] [-v]

For example:

	sac.exe 25331-6q0.asn 25331-b60.asn

The first file is the "old" one, the second the “new” one. They must be from TS25.331 or TS36.331. The two files must "compile", i.e. they should respect ASN.1 syntax. If not, "SAC" will not be able to do the check.

The option –w (for "warning") allows the warnings to be printed.

The option –v (for "verbose") creates a file: "sac_log.txt" for debuging purpose.

The option –ie (for "IE Chain") is for printing the chain of IE in case of an error/warning is found, starting from the PDU that contains the error/warning.

The locations of errors are indicated with line number: the first line number for first file, second line number for second file. (I am using notepad++ as editor). The lines are printed below the error.

For example: 

ERROR: Two INTEGERS do not have the same limits line=6577 12503
File 1(line 6577):MapParameter ::=				INTEGER (0..99)
File 2(line 12503):MapParameter ::=				INTEGER (0..127)

For some errors, SAC gives also the line where the element is defined. This line may be different of the line where the error is found. For example:

ERROR: TYPE MISMATCH : line: 9 8 (6 5)
File 1(line 9): a1 FirstIE,
File 2(line 8): a1 FirstIE2,

File 1(line 6):FirstIE ::= INTEGER
File 2(line 5):FirstIE2 ::= BOOLEAN


2.2 Online version
The output from the online version are the same as the command line version.
