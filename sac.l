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


%{
#include "ptype_asn.h"
#include "sac.tab.h" 

extern int line_counter ;/* Our Line Counter. Defined in bison's file (.y) */
void yyerror(const char * msg); /* defined in bison's file (.y) */


%}


%%
"BEGIN" { return(_BEGIN); }
"END" { return(_END); }
"::=" { yylval.val=line_counter;return(_ASSIGN); }
";" { return(_SEMICOLON); }
"IMPORTS"  { return(_IMPORTS); }
"FROM"  { return(_FROM); }
","  { return(_COMMA); }
"SEQUENCE"  { yylval.val=line_counter;return(_SEQUENCE); }
"CHOICE"  { yylval.val=line_counter;return(_CHOICE); }
"BOOLEAN"  { yylval.val=line_counter; return(_BOOLEAN); }
"INTEGER"  { yylval.val=line_counter; return(_INTEGER); }
"ENUMERATED"  { yylval.val=line_counter;return(_ENUMERATED); }
"OPTIONAL"  { return(_OPTIONAL); }
"BIT" { yylval.val=line_counter;return(_BIT); }
"STRING" { return(_STRING); }
"DEFINITIONS" { return(_DEFINITIONS) ; }

"AUTOMATIC" { return(_AUTOMATIC) ;}
"TAGS" { return(_TAGS) ;}
"(" { return(_OPENP); }
")" { return(_CLOSEP); }
".." {return (_DOTDOT);}
"..." {return (_THREEDOTS);}
"[[" {yylval.val=line_counter;return (_ODSB);}
"]]" {yylval.val=line_counter;return (_CDSB);}
[0-9]+ {yylval.val=atoi(yytext);return (_ENTIER);}
"SIZE" {return (_SIZE) ;}
"{"	{return (_OPENC) ; }
"}" {return (_CLOSEC); }
"NULL" {yylval.val=line_counter; return (_NULL);}
"CONTAINING" {return (_CONTAINING);}
"OCTET" {return (_OCTET);}
"DEFAULT" {return (_DEFAULT);}
"OF" {return (_OF);}
"WITH" {return (_WITH);}
"COMPONENTS" {return (_COMPONENTS);}
"ABSENT" {return (_ABSENT);}
"'11111111'B" {return (_HEIGHT_ONE);} /*This is a hack to handle the only case of DEFAULT with binary in 36.331's ASN1 */
[a-z](-[a-zA-Z0-9]|[a-zA-Z0-9])*  {yylval.sv.id=strdup(yytext);yylval.sv.val=line_counter; return(_SMALLNAME); }
[A-Z](-[a-zA-Z0-9]|[a-zA-Z0-9])* { yylval.sv.id=strdup(yytext);yylval.sv.val=line_counter;return(_BIGNAME); }

"--".*\n    { ++line_counter; }		
"\n"	{++line_counter; }	 
.		{ }
		
				
%%
 
 int yywrap ()
 {
 return 1;
 }
 
 int analyse_string (char * content){
 	YY_BUFFER_STATE my_string_buffer;
	int  my_parse_result;
	
	my_string_buffer = yy_scan_string (content);
    my_parse_result  = yyparse ();
    yy_delete_buffer (my_string_buffer);
	return (my_parse_result);
 }
 
 