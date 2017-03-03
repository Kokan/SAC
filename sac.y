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

/* TO DO: enhance the handling of (SIZE) for INTEGER and SEQUENCE OF */

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
/*duplication of some IE_chain handling functions */
IE_chain * add_IE3 (IE_chain * iec, char * c){
	IE_chain * new_IE = NULL;
	new_IE= malloc (sizeof (IE_chain));
	new_IE->name=c;
	new_IE->nxt=NULL;
	if (iec==NULL) {
		return new_IE;
	}
	else
	{
		IE_chain * temp=iec;
		while (temp->nxt!=NULL)
		{
			temp=temp->nxt;		
		}
		temp->nxt=new_IE;
		return iec;
	}
}




/*********************************/
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

element * new_element_ENUMERATED (int noenum, int indexdot,IE_chain * iec,int noline )
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=6;
	tmp->enumer.val1=noenum;
	tmp->enumer.val2=indexdot;
	tmp->enumer.liste_enu=iec;
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

element * new_element_sequence_of (element * el ,int noline) {
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=11;
	tmp->sequence_of.link=el;
	tmp->line=noline;
	tmp->sequence_of.type=0;
	tmp->sequence_of.low=-1;
	tmp->sequence_of.high=-1;
	tmp->sequence_of.idlow=NULL;
	tmp->sequence_of.idhigh=NULL;	
	
	return (tmp);
};

element * new_element_sequence_of_with_size (element* el ,int noline,struct sizetype size) {
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=11;
	tmp->sequence_of.link=el;
	tmp->line=noline;
	tmp->sequence_of.type=size.type;
	tmp->sequence_of.low=size.val1;
	tmp->sequence_of.high=size.val2;
	tmp->sequence_of.idlow=size.s1;
	tmp->sequence_of.idhigh=size.s2;	

	return (tmp);
};


element * new_element_BITSTRING ( element *el, int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=4;
	tmp->line=noline;
	tmp->string.link=el;
	tmp->string.type=0;
	tmp->string.low=-1;
	tmp->string.high=-1;
	tmp->string.idlow=NULL;
	tmp->string.idhigh=NULL;
	return (tmp);
};

element * new_element_BITSTRING_with_size ( element *el,struct sizetype size, int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=4;
	tmp->line=noline;

	tmp->string.link=el;
	tmp->string.type=size.type;
	tmp->string.low=size.val1;
	tmp->string.high=size.val2;
	tmp->string.idlow=size.s1;
	tmp->string.idhigh=size.s2;
	return (tmp);
};

element * new_element_OCTETSTRING ( element *el,int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=5;
	tmp->line=noline;
	
	tmp->string.link=el;
	tmp->string.type=0;
	tmp->string.low=-1;
	tmp->string.high=-1;
	tmp->string.idlow=NULL;
	tmp->string.idhigh=NULL;

	return (tmp);
};

element * new_element_OCTETSTRING_with_size ( element *el,struct sizetype size, int noline)
{
	element *tmp;
	tmp=malloc (sizeof(element));
	tmp->type=5;
	tmp->line=noline;

	tmp->string.link=el;
	tmp->string.type=size.type;
	tmp->string.low=size.val1;
	tmp->string.high=size.val2;
	tmp->string.idlow=size.s1;
	tmp->string.idhigh=size.s2;
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

void print_IE_chain_debug (IE_chain * iec,FILE *F) {
	IE_chain *tmp=iec;
	while (tmp!= NULL)
	{
		fprintf (F,"%s",tmp->name);
		if (tmp->nxt!=NULL) fprintf (F,",");
		tmp=tmp->nxt;
	}
}

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

void print_size_sequence_of (element el, FILE * F) {
	switch (el.sequence_of.type) {
		case 0 : {
		break;
		}
		case 1 : { /* SIZE (A) */
 		if (el.sequence_of.high!=-1) fprintf (F,"(SIZE(%d))",el.sequence_of.high);
			else  fprintf (F,"SIZE(%s)",el.sequence_of.idhigh);
		break;
		}
		case 2 : { /* SIZE (A..B) */
		fprintf (F,"(SIZE(");
 		if (el.sequence_of.low!=-1) fprintf (F,"%d..",el.sequence_of.low);
			else  fprintf (F,"%s..",el.sequence_of.idlow);
		if (el.sequence_of.high!=-1) fprintf (F,"%d",el.sequence_of.high);
			else  fprintf (F,"%s",el.sequence_of.idhigh);
		fprintf (F,"))");
		break;
		}
	}
} 

void print_size_STRING (element el, FILE * F) {
	switch (el.string.type) {
		case 0 : {
		break;
		}
		case 1 : { /* SIZE (A) */
 		if (el.string.high!=-1) fprintf (F,"(SIZE(%d))",el.string.high);
			else  fprintf (F,"SIZE(%s)",el.string.idhigh);
		break;
		}
		case 2 : { /* SIZE (A..B) */
		fprintf (F,"(SIZE(");
 		if (el.string.low!=-1) fprintf (F,"%d..",el.string.low);
			else  fprintf (F,"%s..",el.string.idlow);
		if (el.string.high!=-1) fprintf (F,"%d",el.string.high);
			else  fprintf (F,"%s",el.string.idhigh);
		fprintf (F,"))");
		break;
		}
	}
} 


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
			print_size_STRING (el,F);
			if (el.string.link!=NULL) {
				fprintf (F,"CONTAINING\n");
				for (i=0;i<offset;i++) 
					fprintf (F,"%%");
				print_element (*(el.string.link),offset,F);
			}
			break;
		}

		case 5 : { /* OCTET STRING */

			fprintf (F,"OCTETSTRING "); 
			print_size_STRING (el,F);
			if (el.string.link!=NULL) {
				fprintf (F,"CONTAINING\n");
				for (i=0;i<offset;i++) 
					fprintf (F,"%%");
				print_element (*(el.string.link),offset,F);
			}
			break;
		}
		
		case 6 : { /* ENUMERATED */
			fprintf (F,"ENUMERATED {");
			print_IE_chain_debug (el.enumer.liste_enu,F);
			fprintf (F,"} #of elements:%d,position of extension mark: %d]",el.enumer.val1,el.enumer.val2);
			break;
		}
		
		case 7 : { /* INTEGER */
		/* This is not 100% correct and need to be corrected */
		/* there are issues when variable are used and not yet translated to values*/
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
		case 11 : { /* SEQUENCE OF */
			fprintf (F,"SEQUENCE OF "); 
			print_size_sequence_of  (el,F);
			if (el.sequence_of.link!=NULL) {
				fprintf (F,"\n");
				for (i=0;i<offset;i++) 
					fprintf (F,"+");
				print_element (*(el.sequence_of.link),offset+1,F);
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
		if (tmp->threedots){ /*We need to take care of the case of "Three Dots" and [[, ]] */
			switch (tmp->threedots) {
				case 1:{ 
					fprintf(F,"...");
					break;
				}
				case 2: {
					fprintf(F,"[[");
					break;
				}
				case 3: { 
					fprintf(F,"]]");
					break;
				}


			}
		}
		else
		{
			fprintf(F,"%s ", tmp->ie_value_name); 
			print_element (*(tmp->elem),offset,F); 
			if (tmp->optionality==1)
				fprintf (F,"OPTIONAL ");
			if (tmp->optionality==2)
				fprintf (F,"DEFAULT %d",tmp->default_value);
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
		if (!tmp->threedots) { 	/*In case of "three dots" elem is NULL */
			browse_element (tmp->elem); 
		}
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

			if (elptr->string.type!=0) {
				if (elptr->string.idlow!=NULL) {
					elptr->string.low=find_value(elptr->string.idlow,constant_list);
					if (verbose) fprintf(Logfile,"Constant Assignment for SIZE in BIT STRING  %s=%d\n",elptr->string.idlow,elptr->string.low);
				}			
			
				if (elptr->string.idhigh!=NULL) {
					elptr->string.high=find_value(elptr->string.idhigh,constant_list);
					if (verbose) fprintf(Logfile,"Constant Assignment for SIZE in BIT STRING  %s=%d\n",elptr->string.idhigh,elptr->string.high);
				}
			}
		
		
			if (elptr->string.link!=NULL) {
				browse_element (elptr->string.link);
			}
			break;
		}
		
		case 5 : { /* OCTETSTRING */
			
			if (elptr->string.type!=0) {
				if (elptr->string.idlow!=NULL) {
					elptr->string.low=find_value(elptr->string.idlow,constant_list);
					if (verbose) fprintf(Logfile,"Constant Assignment for SIZE in OCTET STRING  %s=%d\n",elptr->string.idlow,elptr->string.low);
				}			
			
				if (elptr->string.idhigh!=NULL) {
					elptr->string.high=find_value(elptr->string.idhigh,constant_list);
					if (verbose) fprintf(Logfile,"Constant Assignment for SIZE in OCTET STRING  %s=%d\n",elptr->string.idhigh,elptr->string.high);
				}
			}

			
			
			
			if (elptr->string.link!=NULL) {
				browse_element (elptr->string.link);
			}
			break;
		}
		
		case 7 : { /*INTEGER give value to constant */
			if (elptr->integ.id!=NULL) {
				elptr->integ.high=find_value(elptr->integ.id,constant_list);
				if (verbose) fprintf(Logfile,"Constant Assignment for INTEGER %s=%d\n",elptr->integ.id,elptr->integ.high);
			}
			if (elptr->integ.idlow!=NULL) {
				elptr->integ.low=find_value(elptr->integ.idlow,constant_list);
				if (verbose) fprintf(Logfile,"Constant Assignment for INTEGER %s=%d\n",elptr->integ.idlow,elptr->integ.low);
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
		
		case 11 : { /*SEQUENCE OF. Give value to constant and link to content*/
			if (elptr->sequence_of.type!=0) {
				if (elptr->sequence_of.idlow!=NULL) {
					elptr->sequence_of.low=find_value(elptr->sequence_of.idlow,constant_list);
					if (verbose) fprintf(Logfile,"Constant Assignment for SIZE in SEQUENCE OF  %s=%d\n",elptr->sequence_of.idlow,elptr->sequence_of.low);
				}			
			
				if (elptr->sequence_of.idhigh!=NULL) {
					elptr->sequence_of.high=find_value(elptr->sequence_of.idhigh,constant_list);
					if (verbose) fprintf(Logfile,"Constant Assignment for SIZE in SEQUENCE OF  %s=%d\n",elptr->sequence_of.idhigh,elptr->sequence_of.high);
				}
			}
			if (elptr->sequence_of.link!=NULL) {
				browse_element (elptr->sequence_of.link);}
			break;
		}
		
	}
}

void the_big_link (definition_ptr liste)
/* This goal of this function is to link the definitions and the names*/
/* note for the moment, this has to be done on my_list only*/
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
/*When we have to give line number +string, we use a struct */ 
element * el_ptr ;
sequence_content * sc_ptr; 
choice_content * cc_ptr; 
struct pairtype ppt;  /* To be removed */
struct sizetype size_value;
struct enum_struc enumeration;
}

/* the following token will give the name */
%token <sv> _BIGNAME  _SMALLNAME
/* the following token will give the line number */
%token <val> _ENTIER _SEQUENCE _NULL _BOOLEAN _INTEGER _ENUMERATED _BIT _OCTET _ASSIGN _CHOICE _ODSB _CDSB

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
%type <sc_ptr> SequenceContent SequenceAssignBlock SequenceAssignListWithinBlock
%type <sc_ptr> SequenceAssignList  SequenceAssign  SequenceAssignSingle
%type <sc_ptr> OpenDoubleSquareBrackets CloseDoubleSquareBrackets
%type <cc_ptr> ChoiceContent ChoiceAssignList    ChoiceAssignSeul
%type <cc_ptr> ChoiceAssignBlock   OpenDoubleSquareBracketsChoice 
%type <cc_ptr> CloseDoubleSquareBracketsChoice ChoiceAssignListWithinBlock 
  
%type <enumeration>  ListEnumeration 
%type <size_value> size 
%type <id> Enumarationcontent

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
	ChoiceAssignList _COMMA ChoiceAssignBlock  { Add_an_element_in_Choice ($1,$3) ;  $$=$1;}
	| ChoiceAssignBlock {$$=$1;}
/*	| ChoiceAssignSeul {$$=$1;} */	
;

ChoiceAssignBlock :
	 OpenDoubleSquareBracketsChoice ChoiceAssignListWithinBlock CloseDoubleSquareBracketsChoice {
		Add_an_element_in_Choice  ($2,$3);
		Add_an_element_in_Choice  ($1,$2);
		$$=$1;}
	| ChoiceAssignSeul  {$$=$1;}
;

OpenDoubleSquareBracketsChoice :
	_ODSB { $$= new_choice_content ("",NULL,2 );} /* we use the tdots parameter to code the opening of double brackets */
;

CloseDoubleSquareBracketsChoice :
	_CDSB {$$= new_choice_content ("",NULL,3 );} /* we use the tdots parameter to code the closing of double brackets  */
;

ChoiceAssignListWithinBlock :
	ChoiceAssignListWithinBlock _COMMA ChoiceAssignSeul  { Add_an_element_in_Choice ($1,$3) ;  $$=$1;}
	| ChoiceAssignSeul  {$$=$1;}
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
	SequenceAssignList _COMMA SequenceAssignBlock  { add_a_new_sequence_element ($1,$3) ;  $$=$1;}
	| SequenceAssignBlock  {$$=$1;}
;

SequenceAssignBlock :
	 OpenDoubleSquareBrackets SequenceAssignListWithinBlock CloseDoubleSquareBrackets {
		add_a_new_sequence_element ($2,$3);
		add_a_new_sequence_element ($1,$2);
		$$=$1;}
	| SequenceAssign  {$$=$1;}
;

OpenDoubleSquareBrackets :
	_ODSB { $$= new_sequence_content ("",NULL,-1,0,2 );}
;

CloseDoubleSquareBrackets :
	_CDSB {$$= new_sequence_content ("",NULL,-1,0,3 );}
;

SequenceAssignListWithinBlock :
	SequenceAssignListWithinBlock _COMMA SequenceAssign  { add_a_new_sequence_element ($1,$3) ;  $$=$1;}
	| SequenceAssign  {$$=$1;}
;

SequenceAssign :
	SequenceAssignSingle { $$= $1  ; }
	|	SequenceAssignSingle _OPTIONAL { $1->optionality=1;$$= $1 ; } 
	|	SequenceAssignSingle _DEFAULT _ENTIER { $1->optionality=2;$1->default_value=$3;$1->default_str=NULL;$$= $1; }
	|	SequenceAssignSingle _DEFAULT _SMALLNAME { $1->optionality=3;$1->default_value=0;$1->default_str=$3.id;$$= $1; }
	|	SequenceAssignSingle _DEFAULT _HEIGHT_ONE { $1->optionality=2;$1->default_value=255;$1->default_str=NULL;$$= $1; }
	/*This is a hack to handle the only case of DEFAULT with binary in 36.331'ASN1 */
	|	_SMALLNAME _BIGNAME WithComponent { $$= new_sequence_content ($1.id,new_element_IE_name ( $2.id,$2.val),0,0,0 )  ; } 
	|	_THREEDOTS { $$= new_sequence_content ("",NULL,-1,0,1 )   ; } /*As it is a "Three Dots", only the last element is useful*/
/*	|	_ODSB { $$= new_sequence_content ("",NULL,-1,0,2 )   ; } */ 
/*	|	_CDSB { $$= new_sequence_content ("",NULL,-1,0,3 )   ; } */ 
	
;


WithComponent : 
	_OPENP _WITH _COMPONENTS _OPENC  ListEnumeration _ABSENT _CLOSEC _CLOSEP 
	/* Not treated in this version*/
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
	
	|_ENUMERATED _OPENC ListEnumeration _CLOSEC  {$$=new_element_ENUMERATED ($3.val1,$3.val2,$3.liste_enu,$1);}
	
	|_SEQUENCE _OPENC SequenceContent _CLOSEC { $$=new_element_SEQUENCE ($3,$1);}

	/* The size should be taken into account*/
	|_SEQUENCE size  _OF LeftPart {$$=new_element_sequence_of_with_size ($4,$1,$2);}
	|_SEQUENCE  _OF LeftPart {$$=new_element_sequence_of ($3,$1);}

	|_CHOICE  _OPENC ChoiceContent _CLOSEC {$$=new_element_CHOICE ($3,$1);}
	|  bitstrings {$$=$1;}
	| octetstrings {$$=$1;}
	| _NULL {$$=new_element_NULL ($1);}
;


size :
		_OPENP _SIZE _OPENP _ENTIER					_CLOSEP _CLOSEP       {$$.type=1; $$.val1=-1; $$.val2=$4; $$.s1=NULL;  $$.s2=NULL;}
	|	_OPENP _SIZE _OPENP _SMALLNAME				_CLOSEP _CLOSEP       {$$.type=1; $$.val1=-1; $$.val2=-1; $$.s1=NULL;  $$.s2=$4.id;}
	|	_OPENP _SIZE _OPENP _ENTIER _DOTDOT _ENTIER	_CLOSEP _CLOSEP       {$$.type=2; $$.val1=$4; $$.val2=$6; $$.s1=NULL;  $$.s2=NULL;}
	|	_OPENP _SIZE _OPENP _ENTIER _DOTDOT _SMALLNAME _CLOSEP _CLOSEP    {$$.type=2; $$.val1=$4; $$.val2=-1; $$.s1=NULL;  $$.s2=$6.id;}
	|	_OPENP _SIZE _OPENP _SMALLNAME _DOTDOT _SMALLNAME _CLOSEP _CLOSEP {$$.type=2; $$.val1=-1; $$.val2=-1; $$.s1=$4.id; $$.s2=$6.id;}
	

bitstrings :
		_BIT _STRING 				{$$=new_element_BITSTRING (NULL,$1);} 
	|	_BIT _STRING size			{$$=new_element_BITSTRING_with_size(NULL,$3,$1); } 
	|	_BIT _STRING _OPENC binarycontent  _CLOSEC size
									{$$=new_element_BITSTRING_with_size(NULL,$6,$1);} /* binary content is ignored */
	|	_BIT _STRING _OPENP _CONTAINING _BIGNAME _CLOSEP 
									{element *IE_Temp;
									IE_Temp=new_element_IE_name ( $5.id,$5.val);
									$$=new_element_BITSTRING(IE_Temp,$1);			
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
		_OCTET _STRING 				{$$=new_element_OCTETSTRING (NULL,$1);} 
	|	_OCTET _STRING size			{$$=new_element_OCTETSTRING_with_size(NULL,$3,$1); } 
	|	_OCTET _STRING _OPENP _CONTAINING _BIGNAME _CLOSEP 
									{element *IE_Temp;
									IE_Temp=new_element_IE_name ( $5.id,$5.val);
									$$=new_element_OCTETSTRING(IE_Temp,$1);			
									}
;







ListEnumeration :
	ListEnumeration _COMMA Enumarationcontent  {$$.val1=$1.val1+1;$$.liste_enu=add_IE3($1.liste_enu,$3);if (!strcmp($3,"...")) $$.val2=$$.val1; }
	| Enumarationcontent {$$.val1=1; $$.val2=0;$$.liste_enu=add_IE3(NULL,$1);if (!strcmp($1,"...")) $$.val2=1;	}
;

Enumarationcontent :
	_SMALLNAME {$$=$1.id;}
	| _THREEDOTS {$$="...";}
;




empty:
;

%%

void yyerror(const char * msg)
{
printf ( "Erreur : %s\n",msg  );
}





