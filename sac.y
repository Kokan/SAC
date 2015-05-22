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
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ptype_asn.h"

int yylex(void); 
void yyerror(const char * msg); 

int line_counter  ; /* our line counter */
extern int verbose; /* flag to know if the debugging informations are printed */

/* For the storage of the files in memory */
char *content1; 
char *content2; 


definition_ptr my_list = NULL;
definition_ptr my_list1 = NULL;
definition_ptr my_list2 = NULL;
 
/*We will store the constants in this list*/ 
extern constant * constant_list;
extern constant * constant_list1; 
/* ------------------------------ */


element * new_element_SEQUENCE ( sequence_content * sc,int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=0; /* type SEQUENCE */ 
	tmp->a=sc;
	tmp->line=noline;
	return (tmp);
};

element * new_element_CHOICE ( choice_content * cc,int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=1; /* type CHOICE */ 
	tmp->line=noline;
	tmp->b=cc; 
	return (tmp);
};

element * new_element_ENUMERATED (int noenum,int noline )
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=6;
	tmp->val=noenum;
	tmp->line=noline;
	return (tmp);
};

element * new_element_BOOLEAN ( int noline )
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=3; /* BOOLEAN=type 3*/
	tmp->line=noline;
	return (tmp);
};

element * new_element_NULL ( int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=2; /* NULL*/
	tmp->line=noline;
	return (tmp);
};


element * new_element_IE_name ( char * s,int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=10;
	tmp->IE.IE_name=s;
	tmp->IE.link=NULL;
	tmp->line=noline;
	return (tmp);
};

element * new_element_BITSTRING ( element *el,char * s, int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=4;
	tmp->string.size = s;
	tmp->string.link=el;
	tmp->line=noline;
	return (tmp);
};

element * new_element_OCTETSTRING ( element *el,char * s,int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=5;
	tmp->string.size = s;
	tmp->string.link=el;
	tmp->line=noline;
	return (tmp);
};

element * new_element_INTEGER ( int type, int low, int high,char *s1,char *s,int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=7; /*INTEGER Type*/
	tmp->integ.type=type;
	tmp->integ.low=low;
	tmp->integ.high=high;
	tmp->integ.idlow=s1;
	tmp->integ.id=s; 
	tmp->line=noline;
	return (tmp);
};

sequence_content * new_sequence_content (char * s,element * el,int op, int def, int tdots )
{
	sequence_content * tmp;
	tmp=malloc (sizeof(sequence_content));
	tmp->threedots=tdots;
	/*In case of Three Dots, the following elements are useless */
	tmp->ie_value_name=s;
	tmp->elem=el;
	tmp->optionality=op; 
	tmp->default_value=def;
	tmp->nxt=NULL;
	return (tmp);
};

choice_content * new_choice_content (char * s,element * el,int tdots )
{
	choice_content * tmp;
	tmp=malloc (sizeof(choice_content));
	/*In case of Three Dots, the following elements are useless */
	tmp->threedots=tdots;
	tmp->ie_value_name=s;
	tmp->elem=el;
	tmp->nxt=NULL;
	return (tmp);
};

void Add_an_element_in_Choice (choice_content  * list, choice_content  *nouveau)
{
    if(list == NULL) {        
    }
    else
    {
        choice_content  * temp=list;
        while(temp->nxt != NULL)
        {
            temp = temp->nxt;
        }
        temp->nxt = nouveau;
    }
}


void add_a_new_sequence_element (sequence_content  * list, sequence_content  *new)
{
    if(list == NULL)
    {
        
    }
    else
    {
        sequence_content  * temp=list;
        while(temp->nxt != NULL)
        {
            temp = temp->nxt;
        }
        temp->nxt = new;
    }
}


constant * new_constant(constant * co,char *s,int n,int noline) {
/*No need to be in specific order for the addition of a constant*/
	constant * tmp;
	tmp= malloc (sizeof (constant));
	tmp->name=s;
	tmp->val=n;
	tmp->line=noline;
	tmp->nxt=co;
	return (tmp);
}

int find_value (char *s,constant * co){

/*Find the value of a constant*/
/*the ASN.1 source file should pass compilation first so that all constant have value */
/*Value 0 will be returned if no value is found*/
/*25.331 and 36.331 use only INTEGER type for constants*/

    constant *tmp = co;
    while(tmp != NULL)
    {
		if (!strcmp(s,tmp->name)) {
			return (tmp->val);
		}
       tmp = tmp->nxt;
    }
	return (0);
}


definition_ptr add_last (definition_ptr list, int l,char* s, element * elt )
{

	definition* new_element = malloc(sizeof(definition));
 
	new_element->line = l;
	new_element->leftname = s ;
	new_element->elem = elt ; 
	new_element->PDU = 1 ; /* Definitions are considered as PDU until proved otherwise*/
    new_element->nxt = NULL;
	
 
    if(list == NULL)
    {
        return new_element;
    }
    else
    {
  
        definition* temp=list;
        while(temp->nxt != NULL)
        {
            temp = temp->nxt;
        }
        temp->nxt = new_element;
        return list;
    }
}



/* --------- Printing for debugging----------------*/

void print_constant (constant * co,FILE * F) {
/*this function only print the list of constants in the File F*/
    constant *tmp = co;
	fprintf(F,"Printing of Constants \n");
    while(tmp != NULL)
    {
       fprintf(F,"%s ::=", tmp->name);
	   fprintf(F,"%d", tmp->val);
	   fprintf(F,"\n");
       tmp = tmp->nxt;
    }
}

void print_content_sequence ( sequence_content  * liste,int offset,FILE * F);
void print_choice_content ( choice_content  * liste,int offset, FILE * F);

void print_element (element  el,int offset, FILE *F)
{
	int i;
	/* fprintf (F,"type %d\n",el.type); */
	switch (el.type) {
		case 0 : { /* SEQUENCE */
			print_content_sequence ( el.a,offset+1,F);
			break;
		}
		case 1 : { /* CHOICE */
			print_choice_content ( el.b,offset+1,F);
			break;
		}
		case 2 : { /* NULL */
			fprintf (F,"NULL");
			break;
		}
		
		case 3 : { /* BOOLEAN */
			fprintf (F,"BOOLEAN");
			break;
		}
		
		
		case 4 : { /* BITSTRING */
			fprintf (F,"BITSTRING "); 
			if (el.string.link!=NULL) {
				fprintf (F,"CONTAINING\n");
				for (i=0;i<offset;i++) 
					fprintf (F,"\%");
				print_element (*(el.string.link),offset,F);
			}
			break;
		}

		case 5 : { /* OCTET STRING */
			fprintf (F,"OCTETSTRING "); 
			if (el.string.link!=NULL) {
				fprintf (F,"CONTAINING\n");
				for (i=0;i<offset;i++) 
					fprintf (F,"\%");
				print_element (*(el.string.link),offset,F);
			}
			break;
		}
		
		case 6 : { /* ENUMERATED */
			fprintf (F,"ENUMEATED [%d]",el.val); 
			break;
		}
		
		case 7 : { /* INTEGER */
			switch (el.integ.type){
				case 0 : { /* INTEGER */
					fprintf (F,"INTEGER "); 
					break;
				}
				case 1 : { /* INTEGER (a)*/
					fprintf (F,"INTEGER (%d)",el.integ.high); 
					break;
				}
				case 2 : { /*INTEGER (a..b)*/
					if (el.integ.id==NULL) {
						fprintf (F,"INTEGER (%d..%d)",el.integ.low,el.integ.high); 
					} else
					{
						fprintf (F,"INTEGER (%d..%s)",el.integ.low,el.integ.id);
					}
					break;
				}
			}
			break;
		}
		
		
		case 10 : { /* IE name */
			fprintf (F,"%s ", el.IE.IE_name); 
			if (el.IE.link!=NULL) {
				fprintf (F,"\n");
				for (i=0;i<offset;i++) 
					fprintf (F,"+");
				print_element (*(el.IE.link),offset,F);
			}
			break;
		}
	}
}

void print_content_sequence ( sequence_content  * liste,int offset,FILE *F)
{	int i;
    sequence_content  *tmp = liste;
	fprintf(F,"SEQUENCE {");
    while(tmp != NULL)
    {
		fprintf(F,"\n");
		for (i=0;i<offset;i++) 
			fprintf (F,"-");
		if (tmp->threedots){ /*We need to take care of the case of "Three Dots" */
			fprintf(F,"...");  
		}
		else
		{
			fprintf(F,"%s ", tmp->ie_value_name); 
			print_element (*(tmp->elem),offset,F); 
			if (tmp->optionality==1)
				fprintf (F,"OPTIONAL ");
			if (tmp->optionality==2)
				fprintf (F,"DEFAULT %d",tmp->default_value,F);
		}
       tmp = tmp->nxt;
    }
	fprintf(F,"}");
}

void print_choice_content ( choice_content  * liste,int offset,FILE *F)
{	int i;
    choice_content  *tmp = liste;
	fprintf(F,"CHOICE {");
    while(tmp != NULL)
    {
		fprintf(F,"\n");
		for (i=0;i<offset;i++) 
		fprintf (F,"-");
		
		if (tmp->threedots){ /*We need to take care of the case of "Three Dots" */
			fprintf(F,"...");  
		}
		else
		{
			fprintf(F,"%s ", tmp->ie_value_name); 
			print_element (*(tmp->elem),offset,F); 
		}
		tmp = tmp->nxt;
    }
	fprintf(F,"}");
}
	

void print_liste(definition_ptr liste,FILE *F)
/*this function prints all the definitions of the file and the linked elements*/

{
    definition *tmp = liste;
	fprintf(F,"Printing the whole List of definitions \n");
    while(tmp != NULL)
    {
       fprintf(F,"%s ::= ", tmp->leftname);
	    print_element (*(tmp->elem),0,F); 
	   fprintf(F,"\n\n");
       tmp = tmp->nxt;
    }
}

void print_PDU (definition_ptr liste,FILE *F){
/*this function prints the list of PDU in the File F*/
/* Do not use it after the link of definitions, the size of the result would be too big */
    definition *tmp = liste;
	fprintf(F,"List of PDU\n");
    while(tmp != NULL)
    {
		if (tmp->PDU==1) 
			fprintf(F,"%s\n", tmp->leftname); 
		tmp = tmp->nxt;  
    }
	fprintf(F,"\n");
}

/* ---- End of Printing Functions ------- */


void   browse_element (element  * elptr) ;
/* added here for recursivity */

void browse_content_sequence ( sequence_content  * liste)
{	int i;
    sequence_content  *tmp = liste;
    while(tmp != NULL)
    { 
		if (!tmp->threedots) /*In case of "three dots" elem is NULL */
			browse_element (tmp->elem); 
		tmp = tmp->nxt;
    }
}

void browse_choice_sequence ( choice_content  * liste)
{	int i;
    choice_content  *tmp = liste;
    while(tmp != NULL)
    {
		if (!tmp->threedots) /*In case of "three dots" elem is NULL */
			browse_element (tmp->elem); 

		tmp = tmp->nxt;
    }
}


void   browse_element (element * elptr) 
/* here we look at definitions only in my_list*/
/* this can be enhanced later */
/*The function will also give a value to constants in INTEGER Range*/
{	
	switch (elptr->type) {
		case 0 : {
			browse_content_sequence ( elptr->a);
			break;
		}
		case 1 : {
			browse_choice_sequence ( elptr->b);
			break;
		}
		
		case 4 : { /* BITSTRING */
			if (elptr->string.link!=NULL) {
				browse_element (elptr->string.link);
			}
			break;
		}
		
		case 5 : { /* OCTETSTRING */
			if (elptr->string.link!=NULL) {
				browse_element (elptr->string.link);
			}
			break;
		}
		
		case 7 : { /*INTEGER give value to constant */
			if (elptr->integ.id!=NULL) {
				elptr->integ.high=find_value(elptr->integ.id,constant_list);
				if (verbose) fprintf(Logfile,"Constant Assignment %s=%d\n",elptr->integ.id,elptr->integ.high);
			}
			if (elptr->integ.idlow!=NULL) {
				elptr->integ.low=find_value(elptr->integ.idlow,constant_list);
				if (verbose) fprintf(Logfile,"Constant Assignment %s=%d\n",elptr->integ.idlow,elptr->integ.low);
			}
			break;
		}
		
		
		case 10 : { /* IE name */
			/*printf ("ON CHERCHE: :%s\n", elptr->IE.IE_name); */
			/* we look for the definition of this IE */
			
			definition *tmp = my_list;
			while(tmp != NULL)
			{
				if (!strcmp (tmp->leftname,elptr->IE.IE_name)){
					/*printf("DEFINITION TROUVEE: %s\n",tmp->leftname ); */
					elptr->IE.link=tmp->elem;
					tmp->PDU=0;
				}
				tmp = tmp->nxt;
			}
			
			break;
		}
	}
}

void the_big_link (definition_ptr liste)
/* This goal of this function is to link the definitions and the names*/
/* note for the moment, this has to be done on ma_list only*/
/* the definition will be looked at in this list only */
{
 definition *tmp = liste;
 
	printf("Link ");
    while(tmp != NULL)
    {
	   browse_element (tmp->elem); 
       tmp = tmp->nxt;
    }
	printf(" OK \n");
}



/* ************************************ */

%}

%union {
int val;
char *id;
struct svtype sv;
/*When we have to give line number +srting, we use a struct */ 
element * el_ptr ;
sequence_content * sc_ptr; 
choice_content * cc_ptr; 
}

/* the following token will give the name */
%token <sv> _BIGNAME  _SMALLNAME
/* the following token will give the line number */
%token <val> _ENTIER _SEQUENCE _NULL _BOOLEAN _INTEGER _ENUMERATED _BIT _OCTET _ASSIGN _CHOICE

%token _BEGIN _END 
%token _SEMICOLON 
%token _IMPORTS _FROM _COMMA
%token _OPENC _CLOSEC    _OPTIONAL
%token _STRING
%token _OPENP _CLOSEP  _DOTDOT _SIZE   _CONTAINING  _OF _DEFAULT
%token _DEFINITIONS _AUTOMATIC _TAGS
%token _THREEDOTS
%token _ABSENT 
%token _WITH _COMPONENTS 
%token _HEIGHT_ONE /*This is a hack to handle the only case of DEFAULT with binary in ASN1 */ 

/* %type <id> AssignmentList   Assignment */ 
%type <el_ptr> LeftPart octetstrings bitstrings
%type <sc_ptr> SequenceContent
%type <sc_ptr> SequenceAssignList  SequenceAssign  SequenceAssignSingle
%type <cc_ptr> ChoiceContent ChoiceAssignList    ChoiceAssignSeul
%type <val> Defaultvalue  ListEnumeration

%start program /* the axiom of our grammar */
%%
program : 
	program Module
	| Module
;

Module :
	_BIGNAME _DEFINITIONS _AUTOMATIC _TAGS _ASSIGN _BEGIN ModuleBody _END 
;

ModuleBody:
     Imports AssignmentList
  | empty
;

/* Management of Imports */
Imports:
    _IMPORTS SymbolsImported _SEMICOLON 
  | empty
;


SymbolsImported:
    SymbolsFromModuleList 
  | empty
;

SymbolsFromModuleList:
    SymbolsFromModuleList SymbolsFromModule

  | SymbolsFromModule 
;

SymbolsFromModule:
    SymbolList _FROM _BIGNAME
;

SymbolList:
    SymbolList _COMMA _BIGNAME   
	| _BIGNAME
	|SymbolList _COMMA _SMALLNAME
	|_SMALLNAME
  ;
/* Definitions */

AssignmentList:
    AssignmentList   Assignment 
				
  | Assignment 
;

Assignment : 
	_BIGNAME _ASSIGN LeftPart { 	if (verbose) /*Only if we allow debug/log output */
										fprintf (Logfile,"Parse %s Line %d\n",$1.id,line_counter); 
									my_list= add_last(my_list,$2,$1.id,$3 ) ;
									/* the line number will be given by "::=" */
									
									}
	| _SMALLNAME _INTEGER _ASSIGN _ENTIER {constant_list=new_constant(constant_list,$1.id,$4,$2);}
;

ChoiceContent :
	ChoiceAssignList {$$=$1;}
;

ChoiceAssignList :
	ChoiceAssignList _COMMA ChoiceAssignSeul  { Add_an_element_in_Choice ($1,$3) ;  $$=$1;}
	| ChoiceAssignSeul {$$=$1;}
;

ChoiceAssignSeul :
	_SMALLNAME LeftPart  { $$= new_choice_content ($1.id,$2,0 )   ; }
	| _THREEDOTS { $$= new_choice_content ("",NULL,1 )   ; }
;


SequenceContent :
	SequenceAssignList {$$=$1;} 
	| empty {$$=NULL;}
;

SequenceAssignList :
	SequenceAssignList _COMMA SequenceAssign  { add_a_new_sequence_element ($1,$3) ;  $$=$1;}
	| SequenceAssign  {$$=$1;}
;

SequenceAssign :
	SequenceAssignSingle { $$= $1  ; }
	|	SequenceAssignSingle _OPTIONAL { $1->optionality=1;$$= $1 ; } 
	|	SequenceAssignSingle _DEFAULT Defaultvalue { $1->optionality=2;$1->default_value=$3;$$= $1; }
/*	|	SequenceAssignSingle WithComponent { $$= $1  ; }  */
	|	_SMALLNAME _BIGNAME WithComponent { $$= new_sequence_content ($1.id,new_element_IE_name ( $2.id,$2.val),0,0,0 )  ; } 
	|	_THREEDOTS { $$= new_sequence_content ("",NULL,-1,0,1 )   ; } /*As it is a "Three Dots, only the last element is useful*/
;


WithComponent : 
	_OPENP _WITH _COMPONENTS _OPENC  ListEnumeration _ABSENT _CLOSEC _CLOSEP 
	/* Not treated in this version*/
;
Defaultvalue :
	_ENTIER {$$=$1;}
	| _SMALLNAME  {$$=9999;}/* we will not handle the case DEFAULT Variable for now*/
	| _HEIGHT_ONE {$$=9999;} /*This is a hack to handle the only case of DEFAULT with binary in ASN1 */
;

SequenceAssignSingle :
	_SMALLNAME LeftPart  { $$= new_sequence_content ($1.id,$2,0,0,0 )   ; }
;
	
LeftPart :
	_BIGNAME { $$=new_element_IE_name ( $1.id,$1.val); }
	|_BOOLEAN {$$=new_element_BOOLEAN ($1);}
	|_INTEGER {$$=new_element_INTEGER (0,0,0,NULL,NULL,$1);}
	|_INTEGER _OPENP _ENTIER _DOTDOT _ENTIER _CLOSEP {$$=new_element_INTEGER (2,$3,$5,NULL,NULL,$1);}
	|_INTEGER _OPENP _ENTIER _DOTDOT _SMALLNAME _CLOSEP 
		{$$=new_element_INTEGER (2,$3,0,NULL,$5.id,$1);}
	|_INTEGER _OPENP _SMALLNAME _DOTDOT _SMALLNAME _CLOSEP 		{$$=new_element_INTEGER (2,0,0,$3.id,$5.id,$1);} 
	|_INTEGER _OPENP _ENTIER  _CLOSEP {$$=new_element_INTEGER (1,0,$3,NULL,NULL,$1);}
	|_INTEGER _OPENP _SMALLNAME  _CLOSEP {$$=new_element_INTEGER (1,0,0,NULL,$3.id,$1);}
	
	|_ENUMERATED _OPENC ListEnumeration _CLOSEC  {$$=new_element_ENUMERATED ($3,$1);}
	
	|_SEQUENCE _OPENC SequenceContent _CLOSEC { $$=new_element_SEQUENCE ($3,$1);}
	|_SEQUENCE size _OPENC SequenceContent _CLOSEC {$$=new_element_SEQUENCE ($4,$1);}
	/* Il faudra prendre en compte la size*/
	|_SEQUENCE size  _OF LeftPart {$$=$4;$$->line=$1;}
	/*traite comme un _BIGNAME pour l'instant pour gerer le lien */
	|_CHOICE  _OPENC ChoiceContent _CLOSEC {$$=new_element_CHOICE ($3,$1);}
	| _BIT _STRING bitstrings {$$=new_element_BITSTRING($3,"",$1);}
	| _OCTET _STRING octetstrings {$$=new_element_OCTETSTRING($3,"",$1);}
	| _NULL {$$=new_element_NULL ($1);}
;

size :
		_OPENP _SIZE _OPENP _ENTIER					_CLOSEP _CLOSEP
	|	_OPENP _SIZE _OPENP _SMALLNAME				_CLOSEP _CLOSEP
	|	_OPENP _SIZE _OPENP _ENTIER _DOTDOT _ENTIER	_CLOSEP _CLOSEP
	|	_OPENP _SIZE _OPENP _ENTIER _DOTDOT _SMALLNAME _CLOSEP _CLOSEP
;

bitstrings :
		 {$$=NULL;} /*Note this is the case of a element pointer to NULL is generated*/
	|	 size	 {$$=NULL;} /* idem */
	|	_OPENC binarycontent  _CLOSEC _OPENP _SIZE _OPENP _ENTIER _CLOSEP _CLOSEP {$$=NULL;} /* idem */
	|	_OPENP _CONTAINING _BIGNAME _CLOSEP {$$=new_element_IE_name ( $3.id,$3.val);
									 }
;

binarycontent :
	binarycontent _COMMA bit
	| bit
;

bit :
	_SMALLNAME _OPENP _ENTIER _CLOSEP
;

octetstrings : 
		  {$$=NULL;} /*Note this is the case of a element pointer to NULL is generated*/
	|	  size {$$=NULL; }
	| 	  _OPENP _CONTAINING _BIGNAME _CLOSEP {$$=new_element_IE_name ( $3.id,$3.val);}

;

ListEnumeration :
	ListEnumeration _COMMA Enumarationcontent  {$$=$1+1;}
	| Enumarationcontent {$$=1;}
;

Enumarationcontent :
	_SMALLNAME
	| _THREEDOTS
;

empty:
;

%%

void yyerror(const char * msg)
{
printf ( "Erreur : %s\n",msg  );
}





