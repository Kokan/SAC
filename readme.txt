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

Table of Content:

0.	Introduction
1.	Installation and compilation
1.1	Installation and compilation on Linux
1.2	Installation on Windows
2.	Usage
2.1	Command Line
2.2	Online version
3.	List of Error and Warning Messages
3.1 	List of Error Messages
4. 	Macro for 36.331


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

3 List of Error and Warning Messages

3.1 List of Error Messages

3.1.1 Extension MISMATCH in a SEQUENCE
This error occurs when ASN.1 extension is not properly done in a SEQUENCE. It could be either caused by "...", "[[" or "]]". The lines given in the error message are the beginning of the SEQUENCE.

example 1:
File1:
PDU-010::= SEQUENCE {
	a BOOLEAN
}

File 2:
PDU-010::= SEQUENCE {
	a BOOLEAN,
	...
}

example 2:
File1:
PDU-011::= SEQUENCE {
	a1 BOOLEAN,
	...,
  [[a2 BOOLEAN,
	a3 BOOLEAN ]],
	a4 BOOLEAN
}

File2:
PDU-011::= SEQUENCE {
	a1 BOOLEAN,
	...,
[[  a2 BOOLEAN,
	a3 BOOLEAN,
	a4 BOOLEAN]]
}


3.1.2 OPTIONALITY MISMATCH
This error occurs when, in a SEQUENCE, elements have different optionality options. For example: OPTIONAL in one file and mandatory in the other one.
 
example:
File1:
PDU-020::= SEQUENCE {
	a BOOLEAN OPTIONAL
}

File 2:
PDU-020::= SEQUENCE {
	a BOOLEAN
}

3.1.3 ONE OF THE 2 SEQUENCE IS TOO LONG
One of the SEQUENCEs has too many elements in one of the file. This error does not occur in case of extension with "...". The lines given in the error message are the beginning of the SEQUENCEs.

File1:
PDU-030::= SEQUENCE {
	a1	BOOLEAN	
}

File 2:
PDU-030::= SEQUENCE {
	a1	BOOLEAN,
	a2	BOOLEAN
}

3.1.4 ... (extension) MISMATCH in a CHOICE
This error occurs when, in a CHOICE, the ASN.1 extension "..." are not at the same position in the two files.

example:
File1:
PDU-040 ::= CHOICE {
	a1 BOOLEAN,
	a2 BOOLEAN,
	...
}

File2:
PDU-040 ::= CHOICE {
	a1 BOOLEAN,
	...,
	a2 BOOLEAN
}

3.1.5 ONE OF THE 2 CHOICE IS TOO LONG
One of the CHOICEs has too much elements in one of the file. This error does not occur in case of extension with "...". The lines given in the error message are the beginning of the CHOICE.

example:
file1:
PDU-050 ::= CHOICE {
	a1 BOOLEAN,
	a2 BOOLEAN
}

file2:
PDU-050 ::= CHOICE {
	a1 BOOLEAN,
	a2 BOOLEAN,
	a3 BOOLEAN
}

3.1.6 ENUMERATED: DEFAULT differs
The Default Values for ENUMERATED differ. The lines given in the error message are the line of the DEFAULT value attribution and the lines of the definition of the ENUMERATED.

example:
file1:
PDU-060::= SEQUENCE {
	a A-060  DEFAULT e1
}

A-060::= ENUMERATED {e1,e2}

file2:
PDU-060::= SEQUENCE {
	a A-060  DEFAULT e2
}

A-060::= ENUMERATED {e1,e2}

3.1.7 ENUMERATED: usage of ... differs
The ASN.1 extension in ENUMERATED are not located at the same place in the two files.

example:
file1:
PDU-070::= ENUMERATED {e1,...,e2}

file2:
PDU-070::= ENUMERATED {e1,e2,...}

3.1.8 ENUMERATED: number of item differs
The numbers of items in ENUMERATED are not the same in the two files.

example:
file1:
PDU-080::= ENUMERATED {e1,e2}

file2:
PDU-080::= ENUMERATED {e1,e2,e3}

3.1.9 TYPE MISMATCH
The types of IE don't match. The lines given in the error message are the lines of the attribution and where it is actually defined.

example:
file1:
PDU-090::= A-0190
A-090::=BOOLEAN

file2:
PDU-090::= A-0190
A-090::=INTEGER

3.1.10 ERROR in BIT STRING
The BIT STRING definitions don't match.

example:
file1:
PDU-100 ::= BIT STRING ( CONTAINING A-100)
A-100::=BOOLEAN 

file2:
PDU-100 ::= BIT STRING 

3.1.11 ERROR in OCTET STRING
The OCTET STRING definitions don't match.

example:
file1:
PDU-110 ::= OCTET STRING ( CONTAINING A-110)
A-110::=BOOLEAN 

file2:
PDU-110 ::= OCTET STRING 

3.1.12 INTEGER type mismatch
The INTEGERs are not defined the same way.

example:
file1:
PDU-120 ::= INTEGER (1..5)
file2:
PDU-120 ::= INTEGER  (10)

3.1.13 Two INTEGERS don't have the same limits
The INTEGERs don't have the same limits.

example:
file1:
PDU-130 ::= INTEGER (1..5)
file2:
PDU-130 ::= INTEGER  (1..6)

3.1.14 SIZE type mismatch for SEQUENCE OF
The SEQUENCE OF are not defined the same way.

example:
file1:
PDU-140 ::= SEQUENCE (SIZE (1..5)) OF BOOLEAN
file2:
PDU-140 ::= SEQUENCE (SIZE (5)) OF BOOLEAN

3.1.15 Two SIZEs of SEQUENCE OF  don't have the same limits
The SEQUENCE OF don't have the same limits

example:
file1:
PDU-150 ::= SEQUENCE (SIZE (1..5)) OF BOOLEAN
file2:
PDU-150 ::= SEQUENCE (SIZE (1..6)) OF BOOLEAN


3.1.16 SIZE type mismatch for BITSTRING
The BIT STRINGs are not defined the same way.

example:
file1:
PDU-160 ::= BIT STRING  (SIZE (1..5)) 
file2:
PDU-160 ::= BIT STRING  (SIZE (5))

3.1.17 Two SIZEs of BIT STRING don't have the same limits
The size of BIT STRINGs don't have the same limits

example:
file1:
PDU-170 ::= BIT STRING (SIZE (1..5)) 
file2:
PDU-170 ::= BIT STRING  (SIZE (1..6)) 

3.1.18 SIZE type mismatch for OCTET STRING
The OCTET STRINGs are not defined the same way.

example:
file1:
PDU-180 ::= OCTET STRING  (SIZE (1..5)) 
file2:
PDU-180 ::= OCTET STRING  (SIZE (5))

3.1.19 Two SIZEs of OCTET STRING don't have the same limits
The size of OCTET STRINGs don't have the same limits

example:
file1:
PDU-190 ::= OCTET STRING (SIZE (1..5)) 
file2:
PDU-190 ::= OCTET STRING  (SIZE (1..6)) 

3.1.20 Old file Contains too much elements in a extended SEQUENCE
In an SEQUENCE, extended with "..."the new old file contains more elements than the new file.

example:
file1:
PDU-200::=SEQUENCE {
	a BOOLEAN,
	...,
	b BOOLEAN,
	c BOOLEAN
}
file2:
PDU-200::=SEQUENCE {
	a BOOLEAN,
	...,
	b BOOLEAN
}

3.1.21 Old file Contains too much elements in a extended CHOICE
In an CHOICE, extended with "..."the new old file contains more elements than the new file.

example:
file1:
PDU-210::=CHOICE {
	a BOOLEAN,
	...,
	b BOOLEAN,
	c BOOLEAN
}
file2:
PDU-210::=CHOICE {
	a BOOLEAN,
	...,
	b BOOLEAN
}

3.2 List of Warning Messages

3.2.1 Allowed non critical extension (SEQUENCE {} OP)
This is used for non-critical extension of messages in 25.331 and 36.331.

example:
file1:
PDUW-010::=SEQUENCE {
	a	BOOLEAN,
	noncriticalextension SEQUENCE {} OPTIONAL
}

file2:
PDUW-010::=SEQUENCE {
	a	BOOLEAN,
	extension-W-010 Extension-W-010 OPTIONAL
}

Extension-W-010 ::= SEQUENCE {
	b	BOOLEAN
}

3.2.2 Allowed critical extension in CHOICE with NULL
This is an example of critical extension mechanism.

example:
file1:
PDUW-020 ::= CHOICE {
	a1 BOOLEAN,
	a2 NULL
}

file2:
PDUW-020 ::= CHOICE { 
	a1 BOOLEAN,
	a2 Extension-W-020
}

Extension-W-020::= INTEGER

3.2.3 SEQUENCE {} MP in a SEQUENCE
This mechanism has been used only in 25.331, in Rel-99, for some messages, in the "later-than-r3 " IE. When the "extension" is used (in Rel-4 or later), it causes also an error "TYPE MISMATCH" because it is not backward compatible.
The part SEQUENCE {} is not encoded in ASN.1, because it is not OPTIONAL.
This is present in the following messages:

DL DCCH Messages:
-----------------
ActiveSetUpdate
AssistanceDataDelivery
CellChangeOrderFromUTRAN
CellUpdateConfirm
CounterCheck
DownlinkDirectTransfer
HandoverFromUTRANCommand-GSM
HandoverFromUTRANCommand-CDMA2000
MeasurementControl
PhysicalChannelReconfiguration
PhysicalSharedChannelAllocation
RadioBearerReconfiguration
RadioBearerRelease
RadioBearerSetup
RRCConnectionRelease
SecurityModeCommand
SignallingConnectionRelease
TransportChannelReconfiguration
UECapabilityEnquiry
UECapabilityInformationConfirm
UplinkPhysicalChannelControl
URAUpdateConfirm
UTRANMobilityInformation

UL DCCH Messages
----------------
CellChangeOrderFromUTRANFailure

DL CCCH Message
---------------
CellUpdateConfirm-CCCH
RRCConnectionReject
RRCConnectionRelease-CCCH
RRCConnectionSetup
URAUpdateConfirm-CCCH

DL SHCCH Message
----------------
PhysicalSharedChannelAllocation

example:
file1:
PDUW-030 ::= SEQUENCE { 
	a BOOLEAN,
	criticalext SEQUENCE {}
}

file2:
PDUW-030 ::= SEQUENCE { 
	a BOOLEAN,
	criticalext Criticalext-W-030
}

Criticalext-W-030::=SEQUENCE {
	b BOOLEAN
}

3.2.4 Allowed critical extension in a CHOICE
For this extension, SEQUENCE {} becomes CHOICE inside a CHOICE. It is used for critical extensions in 25.331 and 36.331.

example:
file1:
PDUW-040 ::= CHOICE {
	a BOOLEAN,
	critical-extension SEQUENCE {}
}

file2:
PDUW-040 ::= CHOICE { 
	a BOOLEAN,
	critical-extension Critical-extension-W-040 
}

Critical-extension-W-040 ::= CHOICE {
	b1 BOOLEAN,
	b2  INTEGER
}

3.2.5 Allowed extension in BITSTRING
In the first file, the BITSTING does not make any reference, in the second file, the extension is named and used.

example:
file1:
PDUW-050::= BIT STRING

file2:
PDUW-050::=BIT STRING (CONTAINING Bitstring-extension-W-050) 

Bitstring-extension-W-050 ::= SEQUENCE {
	b1	INTEGER,
	b2  BOOLEAN
}

3.2.6 Allowed extension in OCTET STRING
Same as before but with an octet string.

example:
file1:
PDUW-060::= OCTET STRING

file2:
PDUW-060::=OCTET STRING (CONTAINING Bitstring-extension-W-060) 

Bitstring-extension-W-060 ::= SEQUENCE {
	b1	INTEGER,
	b2  BOOLEAN
}

3.2.7 Name mismatch in a SEQUENCE
The names of IE don't match in the two files.

example:
file1:
PDUW-070::=SEQUENCE {
	a BOOLEAN
}

file2:
PDUW-070::=SEQUENCE {
	b BOOLEAN
}

3.2.8 Name mismatch in a CHOICE
The names of IE don't match in the two files.

example:
file1:
PDUW-080::=CHOICE {
	a1 BOOLEAN,
	a2 INTEGER
}

file2:
PDUW-080::=CHOICE {
	b1 BOOLEAN,
	a2 INTEGER
}

3.2.9 ENUMERATED: ... used to extend the number of elements
The ASN.1 extension "..." has been used to extend the number of elements in an ENUMERATED.

example:
file1:
PDUW-090::= SEQUENCE {
	a ENUMERATED {e1,e2,...}
}
file2:
PDUW-090::= SEQUENCE {
	a ENUMERATED {e1,e2,...,e3}
}

3.2.10 NAME mismatch
The names of an IE don't match in the two files.

example:
file1:
PDUW-100::=Name-W-100
Name-100::=BOOLEAN

file2:
PDUW-100::=OtherName-W-100
OtherName-100::=BOOLEAN

3.2.11 ENUMERATED: change of name in the elements
The name of an element in an ENUMERATED has changed.

example:
file1:
PDUW-110::=ENUMERATED {e1,e2}
file2:
PDUW-110::=ENUMERATED {a1,e2}

3.2.12 Mandatory ENUMERATED with 1 choice only
There is an ENUMERATED with only 1 element, with presence MANDATORY in a SEQUENCE. This is not encoded by ASN1. Note that in this case, there may not be any difference between the two files.

example:
file1:
PDUW-120::=SEQUENCE {
	a1	ENUMERATED {e1},
	a2	BOOLEAN
}
file2:
PDUW-120::=SEQUENCE {
	a1	ENUMERATED {e1},
	a2	BOOLEAN
}

3.2.13 Mandatory ENUMERATED with 1 choice only in the new branch
In a new branch of a PDU in file2, there is an ENUMERATED with only 1 element, with presence MANDATORY in a SEQUENCE. This is not encoded by ASN1. This new branch is not present in file1 and can be for example a non-critical extension.

example:
file1:
PDUW-130::=SEQUENCE {
	a BOOLEAN,
	non-critical-extension SEQUENCE {} OPTIONAL
}
file2:
PDUW-130::=SEQUENCE {
	a BOOLEAN,
	non-critical-extension Extension-W-0130 OPTIONAL
}

Extension-W-0130 ::= SEQUENCE {
	b1	ENUMERATED {e1},
	b2	BOOLEAN
}



4 Macro for 36.331
This Word macro removes the non-ASN.1 text from 36.331.


	Sub Extract()
		Dim A As String
		Dim B As String
		Dim S As String
		Dim x As Long
		Dim y As Long
		Dim z As Long
    		Dim myRange As Range
		Dim wholespec As String

		z = 1
		A = "-- ASN1START"
		B = "-- ASN1STOP"
		l = Len(A)
		Set myRange = ActiveDocument.Range
		wholespec = myRange.Text
		Do Until z = 0
			x = InStr(z, wholespec, A, vbTextCompare)
			y = InStr(x, wholespec, B, vbTextCompare)
			S = S + Mid$(wholespec, x + l, y - x - l)
			z = InStr(y, wholespec, A, vbTextCompare)
		Loop
		ActiveDocument.Range.Text = S
	End Sub
