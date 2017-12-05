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

FILE * Logfile;

struct  svtype{int val;char *id;} ;

struct pairtype {int val1;int val2;};

struct sizetype {int type;int val1;int val2; char* s1; char *s2;};
/* 0: (no size defined) 1: SIZE  (A), 2: SIZE (A..B)*/


typedef struct element element;

typedef struct definition definition;
struct definition
{
	int line;
	char* leftname;
	element * elem; 
    struct definition *nxt;
	int PDU; /* Boolean to know if the definition is a PDU or not*/
};
typedef definition * definition_ptr;


typedef struct definition_pt definition_pt;
struct definition_pt
{
	int line;
	char* leftname;
	element * elem; 
    struct definition_pt *nxt;
	char* ref_variable; /*The IE that will be referred in the definition */
};
typedef definition_pt * definition_pt_ptr;


typedef struct constant constant;
struct constant
{
	int line;
	char* name;
	int val;
	struct constant *nxt;
};

/*To store the constant definitions*/
/*In 25.331 and 36.331 it is only INTEGER*/

typedef struct sequence_content sequence_content;
struct sequence_content
{	char * ie_value_name;
	int optionality; /*0: Mandatory, 1:OPTIONAL, 2: DEFAULT integer, 3:DEFAULT for ENUMERATED / INTEGER (string), -1: N/A (in case of Three Dots for example*/
	int default_value; /* for INTEGER */ 
	char * default_str; /* for ENUMERATED */
	element * elem;
	sequence_content * nxt;
	int threedots;
	/*threedots is used to signal the presence of "...", [[ or ]]*/
	/*1:"...", 2:[[, 3:]], 0:none of those */
};

typedef struct choice_content choice_content;
struct choice_content
{	char * ie_value_name;
	element * elem;
	choice_content * nxt;
	int threedots;
};

typedef struct IE_chain  IE_chain;
struct IE_chain
{	char * name;
	IE_chain * nxt;
};

struct enum_struc {
	int val1;
	int val2;
	IE_chain * liste_enu; 	
};


struct element
{
	int type; /*0:SEQUENCE, 1: CHOICE, 2:NULL, 3:BOOLEAN, 4:BITSTRING, 5:OCTET STRING 
			6:ENUMERATED, 7:INTEGER, 10:Identifier (name with upper case first letter) 11: SEQUENCE OF
			8:Parameterized Type */
	int line;
	union  {
		sequence_content * a; /*0:SEQUENCE */
		choice_content *b ; /*1:CHOICE  */
		struct  {
			char * IE_name;  /* 10: Identifier */
			element * link;
		} IE ;
		struct  {  /* 4: BITSTRING  or 5:OCTET STRING*/
			element * link;
			int type; /*0: no limit ,1: SIZE (A), 2:SIZE (A..B)*/
			int low;
			int high;
			char * idlow;
			char * idhigh; /* high */		
		} string ;
		struct { /*for 6: ENUMERATED */
		/* The first value is the number of enumerated. */
		/* The second indicates the presence of "...": the value is the index of "..." in the list*/
		/*     0 means absent */
			int val1;
			int val2;
			IE_chain * liste_enu; 
		}
		enumer; 
		struct { /*for 7: INTEGER type */
			int type; /*0: no limit (not used in 25.331),1: INTEGER (A), 2:INTEGER (A..B)*/
			int low;
			int high;
			char * idlow;
			char * id; /* high */		
		} integ;
		struct  {
			char * IE_name;  /* 11: SEQUENCE OF */
			element * link;
			int type; /*0: no limit ,1: SIZE (A), 2:SIZE (A..B)*/
			int low;
			int high;
			char * idlow;
			char * idhigh; /* high */		
			
		} sequence_of ;
		
		struct  {
			char * name;  /* 8: PARAMETERIZED TYPE  */
			element * link;		
		} partype ;
	};

};


