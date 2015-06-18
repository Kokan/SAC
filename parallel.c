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

/*TO DO List: */
/*print the lines in case of warnings */
/*take "..." into account in ENUMERATED */
/*manage [[ and ]]*/
/*add line reference for "..." in a CHOICE */
/*check that additions after "..." are done in the right order (more elements in the new file) */
/*give the value of constant when they are the source of error*/


#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "ptype_asn.h"
#include "sac.tab.h" 

extern  definition_ptr my_list ;
extern  definition_ptr my_list1 ;
extern  definition_ptr my_list2 ;

extern int print_warnings;
extern int showIEchain;
extern char * content1;
extern char * content2;


IE_chain * IEChain1=NULL;
IE_chain * IEChain2=NULL;

extern int web; /*Boolean to indicate if the compilation is done for cgi */

int nb_error=0; /*number of non backward compatible errors*/
int nb_warnings=0; /*number of non backward compatible errors*/

void showlines (int l1,int l2);
void safe_print (char *s) ;



void add_BR () {
	if (web) printf ("<BR>\n");
}

/*------ handling of IE Chain ----- */
IE_chain *  add_IE (char * s) {
	printf ("+");
	safe_print (s);
	printf ("\n");
	add_BR();
}


IE_chain * add_IE2 (IE_chain * iec, char * c){
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

IE_chain *  remove_last_IE (IE_chain * iec ){	
	if (iec==NULL) return NULL;
	if(iec->nxt == NULL)
	{
		free (iec);
        	return NULL;
	}
 
	IE_chain * tmp =iec;
	IE_chain * ptmp =iec;
	while(tmp->nxt != NULL)
    	{
        	ptmp=tmp;
		tmp = tmp->nxt;
	}
	
	ptmp->nxt=NULL;
	free (tmp);
	return iec;	
}

IE_chain * last_IE (IE_chain * iec){
	if (iec==NULL) return NULL;
	
	if(iec->nxt == NULL)
	{
        	return iec;
	}
 
	IE_chain * tmp =iec;
	while(tmp->nxt != NULL)
    	{
        	tmp = tmp->nxt;
	}
	return tmp;	

}

IE_chain * remove_n_last_IE (IE_chain * iec, int n) {
	IE_chain * temp=iec;
	int i;
	for (i=0;i<n;i++) {
		temp= remove_last_IE (temp);
	}		
	return temp;
}
	
void IE_restore (IE_chain * iec) {
}

void clean_IE_chain (IE_chain * iec){
	IE_chain * tmp=NULL;
	if (iec!=NULL) {
		tmp=iec->nxt;
		free (iec);
		clean_IE_chain (tmp);	
	}
}

void print_IE_chain (IE_chain * iec) {
	IE_chain *tmp=iec;
	while (tmp!= NULL)
	{
		
		safe_print (tmp->name);
		if (tmp->nxt!=NULL) printf (" / ");
		tmp=tmp->nxt;
	}
}

/* --- end of handling of IE chain ---*/

int para_def (definition * l1, definition * l2)
{
	if ((l1!=NULL)&&(l2!=NULL)) {
		if ((l1->elem->type)!=(l2->elem->type)) {
			printf ("ERROR: TYPE MISMATCH Line:%d %d\n",l1->line,l2->line);
			add_BR ();
			showlines (l1->line,l2->line);
			printf ("\n");
			add_BR();
			nb_error++;
			return (0);
		}		
		para_browse_element (l1->elem,l2->elem,0,-1,0);	
	}	
}

int para_browse_content_sequence ( sequence_content * sc1, sequence_content * sc2,int offset,int op,int l1, int l2){
/*op: Optionality of the SEQUENCE : 0 Mandatory, 1 : OPTIONAL*/
/*l1 and l2: lines of the beginning of the SEQUENCE in the 2 files */	
	int tdflag=0; /*Flag tdflag (Three Dots flag) indicate that the SEQUENCE has been extended with three dots */
	IE_chain * ic1;
	IE_chain * ic2;
	if ((sc1==NULL)&&(sc2!=NULL)&&(op==1)) {	
		if (print_warnings) {
			fprintf (stdout,"Warning: Allowed non critical extension (SEQUENCE {} OP) line:%d %d \n",l1,l2);
			add_BR();
			showlines (l1,l2);
			printf ("\n");
			add_BR();
			nb_warnings++;
			new_branch_browse_content_sequence (sc2,1,l2);
		}
	return (0);
	}
	while ((sc1!=NULL)&&(sc2!=NULL)) {		
		if (sc1->threedots ||  sc2->threedots ) {/*In case of Three Dots: special case */
			tdflag=1;
			if (sc1->threedots!=sc2->threedots) {
				fprintf(stdout,"ERROR:  ... (extension) MISMATCH in a SEQUENCE line %d %d\n",l1,l2);
				add_BR();
				showlines (l1,l2);
				printf ("\n");
				add_BR();
				nb_error++;
				return (1);
			}
			
		}
		else
		{
			if (sc1->optionality!=sc2->optionality) {			
				fprintf(stdout,"ERROR:  OPTIONALITY MISMATCH line %d %d\n",sc1->elem->line,sc2->elem->line);
				add_BR();
				showlines (sc1->elem->line,sc2->elem->line);
				printf ("\n");
				add_BR();
				nb_error++;
				return (1);
			}
					
			if (strcmp (sc1->ie_value_name,sc2->ie_value_name)) {
				if (print_warnings) {
					fprintf(stdout,"Warning: name mismatch %s %s line %d %d\n\n",sc1->ie_value_name,sc2->ie_value_name,sc1->elem->line,sc2->elem->line);
					add_BR();
					add_BR();
					nb_warnings++;
				}
			}
			IEChain1=add_IE2(IEChain1,sc1->ie_value_name);	
			IEChain2=add_IE2(IEChain2,sc2->ie_value_name);
			para_browse_element (sc1->elem, sc2->elem,offset,0,sc1->optionality);
			IEChain1=remove_last_IE(IEChain1);
			IEChain2=remove_last_IE(IEChain2);
	
			switch (sc1->optionality) {
				case 1 : { /* OPTIONAL */								
							break;						
						}
				case 2 : { /* DEFAULT */
							break;		
				}
			}
		}
		sc1=sc1->nxt;
		sc2=sc2->nxt;

		
	}
	if ((!tdflag)&&(!((sc1==NULL)&&(sc2==NULL)))) {
		printf("ERROR: ONE OF THE 2 SEQUENCE IS TOO LONG line:%d %d\n",l1,l2);
		add_BR();
		showlines (l1,l2);
		printf ("\n");
		add_BR();
		nb_error++;
	}
	return (0);
}
			
int para_browse_choice_content ( choice_content * cc1, choice_content *cc2,int offset,int line1, int line2){
	int	tdflag=0;
	IE_chain * ic1;
	IE_chain * ic2;
	while ((cc1!=NULL)&&(cc2!=NULL)) {		
		
		if (cc1->threedots ||  cc2->threedots ) {/*In case of Three Dots: special case */
			tdflag=1;
			if (cc1->threedots!=cc2->threedots) {
				fprintf(stdout,"ERROR:  ... (extension) MISMATCH in a CHOICE line %d %d\n",line1,line2); 
				add_BR();
				showlines (line1,line2);
				printf ("\n");
				add_BR();
				nb_error++;
				return (1);
			}
		}
		else
		{
			
			if (strcmp (cc1->ie_value_name,cc2->ie_value_name)) {
				if (print_warnings) {
					fprintf(stdout,"Warning: name mismatch %s %s line %d %d\n",cc1->ie_value_name,cc2->ie_value_name,cc1->elem->line,cc2->elem->line);
					add_BR();
					nb_warnings++;
				}
			}		
			IEChain1=add_IE2(IEChain1,cc1->ie_value_name);	
			IEChain2=add_IE2(IEChain2,cc2->ie_value_name);
			para_browse_element (cc1->elem, cc2->elem,offset,1,0);
			IEChain1=remove_last_IE(IEChain1);
			IEChain2=remove_last_IE(IEChain2);
	

		}
		cc1=cc1->nxt;
		cc2=cc2->nxt;

	}
	if ((!tdflag)&&(!((cc1==NULL)&&(cc2==NULL)))) {
		printf("ERROR: ONE OF THE 2 CHOICE IS TOO LONG line %d %d\n",line1,line2); 
		add_BR();
		showlines (line1,line2);
		printf ("\n");
		add_BR();
		nb_error++;
	}
	return (0);
}
			

int para_browse_NULL ( int offset){
}

int para_browse_BOOLEAN ( int offset){
}

int para_browse_IE_Name (element *t1, element * t2,int offset){
/* This function is never called */
}

int para_browse_element (element *t1, element *t2,int offset,int source,int op) {
/*source what is calling the function: 0:SEQUENCE, 1:CHOICE, -1:OTHER */
/*op: optionality of the IE in case of a sequence : 0  Mandatory, 1 OPTIONAL 2 DEFAULT */
/*This is used for the SEQUENCE {} OPTIONAL detection*/

/*NOTE we have to add the possibility to remove uncoded parts like AccessStratumReleaseIndicator*/
int line1;
int line2;
int icc1=0;
int icc2=0;
/* used to save the line of the first IE in case of the definition is done in another place */


	if ((t1!=NULL)&&(t2!=NULL)) {
		int i;
		line1=t1->line;
		line2=t2->line;
		
		/*Test if the names are the same */
		if ((t1->type==10)&&(t2->type==10)) {
			if (strcmp (t1->IE.IE_name,t2->IE.IE_name)) {
				if (print_warnings) {
					fprintf(stdout,"Warning: name mismatch %s %s\n\n",t1->IE.IE_name,t2->IE.IE_name);
					add_BR ();
					add_BR();
					nb_warnings++;
				}
			}
		}
		
		
		/* Resolve IE_NAME-> Definition */ 
		while ((t1->type==10)&&(t1->IE.link!=NULL)) {
			IEChain1=add_IE2 (IEChain1,t1->IE.IE_name);
			icc1++;
			t1=t1->IE.link;
	
		}
		while ((t2->type==10)&&(t2->IE.link!=NULL))  {
			IEChain2=add_IE2 (IEChain2,t2->IE.IE_name);
			icc2++;
			t2=t2->IE.link;
		}
		
		/* Check allowed extensions  ,  2=NULL*/
		/* A NULL becomes something in the later version */
		if ((source==1)&&(t1->type==2)&&(t2->type!=2)) {
		/*We check that we are in a CHOICE, that the old version has NULL and the new version not a NULL */
			if (print_warnings) {
				fprintf(stdout,"Warning Allowed critical extension in CHOICE with NULL line %d %d \n\n",t1->line,t2->line);
				add_BR();
				add_BR();
				nb_warnings++;
				new_branch_browse_element (t2,1,op);
			}
			IEChain1=remove_n_last_IE (IEChain1,icc1);
			IEChain2=remove_n_last_IE (IEChain2,icc2);
			return (0);			
		}
		
		/* case of critical extension : SEQUENCE {} MP  inside a SEQUENCE */
		if ((op==0)&&(source==0)&&(t1->type==0)&&(t1->a==NULL)) {
		/*source=0: it comes from a SEQUENCE */
		/*t1 is a SEQUENCE {}*/

			if (print_warnings) {
				fprintf(stdout,"Warning: SEQUENCE {} MP in a SEQUENCE line=%d %d\n\n",t1->line,t2->line);
				add_BR();
				add_BR();
				nb_warnings++;
			}
			
		}
		
		
		/* case of critical extention : SEQUENCE {} becomes CHOICE inside a CHOICE */
		if ((op==0)&&(source==1)&&(t1->type==0)&&(t2->type==1)&&(t1->a==NULL)) {
		/*source=1: it comes from a CHOICE */
		/*t1 is a SEQUENCE {}*/
		/*t2 is a CHOICE  */
			if (print_warnings) fprintf(stdout,"Warning Allowed critical extension in a CHOICE line=%d %d\n\n",t1->line,t2->line);
			new_branch_browse_element (t2,1,op); 
			IEChain1=remove_n_last_IE (IEChain1,icc1);
			IEChain2=remove_n_last_IE (IEChain2,icc2);
			add_BR();
			add_BR();
			nb_warnings++;

			return (0);			
		}
		
		if ((t1->type)!=(t2->type)) {
			
			fprintf (stdout,"ERROR: TYPE MISMATCH : line: %d %d (%d %d)\n",line1,line2,t1->line,t2->line);
			add_BR();
			showlines (line1,line2);
			showlines (t1->line,t2->line);
			printf ("\n");
			add_BR();
			nb_error++;
			IEChain1=remove_n_last_IE (IEChain1,icc1);
			IEChain2=remove_n_last_IE (IEChain2,icc2);
			return (1);
		}

		/* printf (" TYPE: %d ",el.type); */
		switch (t1->type) {
			case 0 : { /* SEQUENCE */
				para_browse_content_sequence ( t1->a,t2->a,offset+1,op,t1->line,t2->line);
				break;
			}
			case 1 : { /* CHOICE */
				para_browse_choice_content ( t1->b,t2->b,offset+1,t1->line,t2->line);
				break;
			}
			case 2 : { /* NULL */
				para_browse_NULL ( offset);
				break;
			}
			case 3 : { /* BOOLEAN */
				para_browse_BOOLEAN ( offset);
				break;
			}
			
			case 4 : { /* BITSTRING  */

				if ((t1->string.link!=NULL)&&(t2->string.link!=NULL)){
					para_browse_element (t1->string.link, t2->string.link,offset,-1,op);
					/*for the moment we only check the content*/
				} else
				{
					if ((t1->string.link!=NULL)||(t2->string.link!=NULL)){
						if (t1->string.link==NULL) {
							if (print_warnings) {
								fprintf (stdout,"Allowed extension in BITSTRING :line:%d %d\n\n",t1->line,t2->line);
								add_BR();
								add_BR();
								nb_warnings++;
								new_branch_browse_element (t2->string.link,-1,op);
							}
						} else
						{
							fprintf (stdout,"ERROR: in BIT STRING :line:%d %d\n",t1->line,t2->line);
							add_BR();
							showlines (t1->line,t2->line);
							printf ("\n");
							add_BR();
							nb_error++;
						}
					}
				}
				break;
			}
			
			case 5 : { /* OCTETSTRING  */
				if ((t1->string.link!=NULL)&&(t2->string.link!=NULL)){
					para_browse_element (t1->string.link, t2->string.link,offset,-1,op);
					/*for the moment we only check the content*/
				} else
				{
					if ((t1->string.link!=NULL)||(t2->string.link!=NULL)){
						fprintf (stdout,"ERROR in OCTET STRING :line:%d %d\n",t1->line,t2->line);
						add_BR();
						showlines (t1->line,t2->line);
						printf ("\n");
						add_BR();
						nb_error++;
					}
				}
				break;
			}
			
			
			
			case 6 : { /* ENUMERATED */
				if ( ( (t2->enumer.val2)!= (t1->enumer.val2))) {
					/*"..."  are not at the same position*/

					fprintf(stdout,"ERROR: ENUMERATED: usage of ... differs line=%d %d\n",t1->line,t2->line);

					add_BR();
					showlines (t1->line,t2->line);
					printf ("\n");
					add_BR();
					nb_error++;
					break;	
				}
			
				if ((t1->enumer.val1!=t2->enumer.val1)&&((t2->enumer.val2)==0)) {
					/*number of item differs  */
					fprintf(stdout,"ERROR: ENUMERATED: number of item differs line=%d %d\n",t1->line,t2->line);
					add_BR();
					showlines (t1->line,t2->line);
					printf ("\n");
					add_BR();
					nb_error++;
					break;
				}
				
				if ( ((t1->enumer.val1)!=(t2->enumer.val1)) && ((t2->enumer.val2)!=0)  ) {
					/*"..." is used to extend the number of values */
					if (print_warnings) {
						fprintf(stdout,"WARNING: ENUMERATED: ... used to extend the number of elements line=%d %d\n",t1->line,t2->line);
						add_BR();
						showlines (t1->line,t2->line);
						printf ("\n");
						add_BR();
						nb_warnings++;
					}
				}
				
				if ((1==t1->enumer.val1)&&(0==op) && (0==source)) {
					/*"..." is used to extend the number of values */
					if (print_warnings) {
						fprintf(stdout,"WARNING: Mandatory ENUMERATED with 1 choice only line=%d %d\n",t1->line,t2->line);
						add_BR();
						showlines (t1->line,t2->line);
						printf ("\n");
						add_BR();
						nb_warnings++;
					}
				}
				break;
			}
			
			case 7 : { /* INTEGER */
				if (t1->integ.type!=t2->integ.type) {
					/*The two INTEGERS do not have the same type */
					fprintf(stdout,"ERROR: INTEGER type mismatch line=%d %d\n",t1->line,t2->line);
					add_BR();
					showlines (t1->line,t2->line);
					printf ("\n");
					add_BR();
					nb_error++;
					break;
				}
				
				if  ((t1->integ.low!=t2->integ.low) || ((t1->integ.high!=t2->integ.high))) {
					/*The two INTEGERS do not have the same limits */
					fprintf(stdout,"ERROR: Two INTEGERS do not have the same limits line=%d %d\n",t1->line,t2->line);
					add_BR();
					showlines (t1->line,t2->line);
					printf ("\n");
					add_BR();
					nb_error++;
				}
				break;
				
				break;
			}


			
			case 10 : { /* IE name */
			/*I don't think this part is used because we try to resolve the links at the begining*/
				para_browse_IE_Name ( t1,t2,offset);
				
				if ((t1->IE.link!=NULL)&& (t2->IE.link!=NULL)){
				
					para_browse_element (t1->IE.link, t2->IE.link,offset,-1,op);	
				}
			break;
				
			}
		}
	}	
	if ((t1==NULL)||(t2==NULL))
		if (print_warnings) { 
			printf ("Warning(link): One of the element is empty\n\n");
			add_BR();
			add_BR();
			nb_warnings++;
		}
	IEChain1=remove_n_last_IE (IEChain1,icc1);
	IEChain2=remove_n_last_IE (IEChain2,icc2);
}

void browse_PDUpara (definition_ptr liste1, definition_ptr liste2){
    definition *tmp1 = liste1;
	definition *tmp2 = liste2;
	printf("Checking the PDU(s):\n\n");
	add_BR();
	add_BR();
	
    while(tmp1 != NULL)
    {
		if (tmp1->PDU==1) {		
			tmp2=liste2;
			while(tmp2 != NULL) {
				if (!strcmp (tmp1->leftname,tmp2->leftname)){
					printf ("Analysing PDU:");
					safe_print (tmp1->leftname);
					printf("\n"); 
					add_BR();				
					IEChain1=add_IE2(IEChain1,tmp1->leftname);	
					IEChain2=add_IE2(IEChain2,tmp2->leftname);
					para_def(tmp1,tmp2); 

					IEChain1=remove_last_IE(IEChain1);
					IEChain2=remove_last_IE(IEChain2);

					printf("**************************\n");
					add_BR();
				}
				tmp2 = tmp2->nxt;
			}	
				
			
		} /* if (tmp1->PDU==1) */
			
		tmp1 = tmp1->nxt;  
    } /* while(tmp1 != NULL) */
	printf("\n");
}	







/* procedures to free the memory */ 
void free_element (element * elptr);

void free_sequence ( sequence_content * sc) {
sequence_content * tmp;
	while (sc!=NULL) {		
		free_element(sc->elem);	
		tmp=sc->nxt;
		free(sc);
		sc=tmp;
	}	
}
void free_choice_sequence (choice_content *cc ) {
choice_content * tmp;
	while (cc!=NULL) {		
		free_element(cc->elem);	
		tmp=cc->nxt;
		free(cc);
		cc=tmp;
	}	
}

		

void free_element (element * elptr) {
	if (elptr!=NULL){ 
		switch (elptr->type) {
			case 0 : { /* SEQUENCE */
				free_sequence ( elptr->a);
				break;
			}
			case 1 : { /* CHOICE */
			
				free_choice_sequence ( elptr->b);
				break;
			}
			case 4 : { /* BITSTRING */
				break;
			}
		
			case 5 : { /* OCTETSTRING */
	
				break;
			}
			case 7 : { /*INTEGER  */
				
				free(elptr->integ.id);
				free (elptr->integ.idlow);
				break;
			}	
		
		}
			free (elptr);
	}
}

void free_liste (definition_ptr liste) {
    definition *tmp1 = liste;
    definition *tmp2 = liste;
    while(tmp1 != NULL)
    {
		free (tmp1->leftname);
		free_element (tmp1->elem);
		tmp2 = tmp1->nxt;
		free (tmp1);
		tmp1 = tmp2;  
		} 
}

void free_IE_Chain (IE_chain * iec ) {
	IE_chain * tmp = iec; 
	while (tmp!=NULL) {
		tmp=remove_last_IE (tmp);
	}
}

/* End of procedures to free the memory */

/* new branch parsing */

int new_branch_browse_element (element *t2,int source, int op) {
/*source what is calling the function: 0:SEQUENCE, 1:CHOICE, -1:OTHER */
/*op: optionality of the IE in case of a sequence : 0  Mandatory, 1 OPTIONAL 2 DEFAULT */

	int line2;
	int icc2=0;

	/* used to save the line of the first IE in case of the definition is done in another place */

	if (t2!=NULL) {
		int i;
		line2=t2->line;

		/* Resolve IE_NAME-> Definition */ 
		while ((t2->type==10)&&(t2->IE.link!=NULL))  {
			IEChain2=add_IE2 (IEChain2,t2->IE.IE_name);
			icc2++;
			t2=t2->IE.link;
		}


		/* printf (" TYPE: %d ",el.type); */
		switch (t2->type) {
			case 0 : { /* SEQUENCE */
				new_branch_browse_content_sequence ( t2->a,op,t2->line);
				break;
			}
			
			case 1 : { /* CHOICE */
				new_branch_browse_choice_content ( t2->b,t2->line);
				break;
			}

			case 4 : { /* BITSTRING  */
				if (t2->string.link!=NULL){
					new_branch_browse_element (t2->string.link,-1,op);
				} 
				break;
			}
			
			case 5 : { /* OCTETSTRING  */
				if (t2->string.link!=NULL){
					new_branch_browse_element (t2->string.link,-1,op);
				} 
				break;
			}
			
			case 6 : { /* ENUMERATED */
				if ((1==t2->enumer.val1)&&(0==op)&& (0==source)) {
	
					if (print_warnings) {
						fprintf(stdout,"WARNING: Mandatory ENUMERATED with 1 choice only in the new branch line=%d\n",t2->line);
						add_BR();
						printf ("IE Chain for File 2:");
						printf ("\n");
						add_BR();
						print_IE_chain (IEChain2);
						printf ("\n");
						add_BR();

						printf ("\n");
						add_BR();
						nb_warnings++;
					}
				}
				break;
			}

		}
	}	
	IEChain2=remove_n_last_IE (IEChain2,icc2);
}


int new_branch_browse_content_sequence (sequence_content * sc2,int op, int l2){
/*op: Optionality of the SEQUENCE : 0 Mandatory, 1 : OPTIONAL*/
/*l2: line of the beginning of the SEQUENCE */	


	IE_chain * ic2;

	while (sc2!=NULL) {		
	
		IEChain2=add_IE2(IEChain2,sc2->ie_value_name);
		new_branch_browse_element (sc2->elem,0,sc2->optionality);
		IEChain2=remove_last_IE(IEChain2);
		sc2=sc2->nxt;
		
	}
	return (0);
}

int new_branch_browse_choice_content (choice_content *cc2,int line2){
	int	tdflag=0;

	IE_chain * ic2;
	while (cc2!=NULL) {		
		IEChain2=add_IE2(IEChain2,cc2->ie_value_name);
		new_branch_browse_element (cc2->elem,1,0);
		IEChain2=remove_last_IE(IEChain2);
		cc2=cc2->nxt;
	}
	return (0);
}
				
			
/* End of new branch parsing*/




/* Printing procedures*/

void safe_print (char*s) {
//This function is used to print in case of online versio (CGI). It prevents malicious code to be executed.
	char *t;
	int i,l;
	char c;

	l=strlen(s);
	for (i=0;i<l;i++){
		switch (c=s[i]) {
			 case '<' :
				printf (" &lt;");
				break;
			case '>' :
				printf ("&gt;");
				break;
					

			default :
				printf ("%c",c);
		}
	}
}

void print_line (char * c,int li) {
	int l=1;
	int i=0;
	int j;
	int len;
	char line_text[256];
	
	while (l<li) {
		while (c[i]!='\n') {
			i++;
		}
		l++;
		i++;
	}
	j=i;
	i++;
	while ((c[i]!='\n') && (c[i]!='\r')){
		i++;
	}
	len=i-j;	
	if (len>255) len=255;
	strncpy (line_text,c+j,len);
	line_text[len]=0;
	
	safe_print (line_text);
}

void showlines (int l1,int l2) {
	printf ("File 1(line %d):",l1);
	print_line ( content1, l1);
	printf ("\n");
	add_BR();
	printf ("File 2(line %d):",l2);
	print_line ( content2, l2);
	printf ("\n");
	add_BR();
	
	if (showIEchain) {
		print_both_IEchain ();
	}
}	

int print_both_IEchain () {
	printf ("IE Chain for File 1:");
	printf ("\n");
	add_BR();
	print_IE_chain (IEChain1);
	printf ("\n");
	add_BR();
	printf ("IE Chain for File 2:");
	printf ("\n");
	add_BR();
	print_IE_chain (IEChain2);
	printf ("\n");
	add_BR();
}
	
int  para ()
{
	browse_PDUpara (my_list1,my_list2);
	printf("Number of errors : %d\n",nb_error);
	add_BR();
	clean_IE_chain(IEChain1);
	clean_IE_chain(IEChain2);
	if (print_warnings) {
		printf ("Number of warnings : %d\n",nb_warnings);
		add_BR();
	}
	return (nb_error);
}
