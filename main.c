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


#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#define SIZE_TOTAL  4000000
#define SIZE_1 2000000
#define SIZE_2  2000000
 

#include "ptype_asn.h"
#include "sac.tab.h" 


constant * constant_list = NULL;
constant * constant_list1 = NULL; 


int web=1; /*Boolean to indicate if the compilation is done for a web server . Now this is detected automatically */

extern  definition_ptr my_list ;
extern  definition_ptr my_list1 ;
extern  definition_ptr my_list2 ;

extern int print_warnings;
extern char * content1;
extern char * content2;
extern int line_counter ;/* our line counter */

int verbose=0;       	/*Boolean to have some log in files for debugging*/
int print_warnings=0;	/*Boolean to print the warnings */
int showIEchain=0;		/*Boolean to print the IE chain when an error is found*/


FILE * Logfile=NULL;



/* Functions */
void haut(char *title) {
     printf("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"fr\" >\n\t<head>");
     printf("\t\t<title>%s</title>", title);
     printf("\t\t<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n\t</head>\n\t<body>");
}

void bas() {
     printf("\t</body>\n</html>");
}


char *decode(char *str, char *fin)
{
     char *dest = strdup(str);
     if (dest == NULL)
          return NULL;
     char *ret = dest;

     for (; str < fin && *str != '\0'; str++, dest++)
     {
          if (*str == '+')
               *dest = ' ';
          else if (*str == '%')
          {
               ++str;
               if (*str == '\0')
                    break;
               int code = '?';
               sscanf(str, "%2x", &code);
               *dest = code;

               str++;
               if (*str == '\0')
                    break;
          }
          else
               *dest = *str;
     }
     *dest = '\0';
     return ret;
}




int load_file_to_memory(const char *filename, char **result) 
{ 
	int size = 0;
	FILE *f = fopen(filename, "rb");
	if (f == NULL) 
	{ 
		*result = NULL;
		return -1; // -1 means file opening fail 
	} 
	fseek(f, 0, SEEK_END);
	size = ftell(f);
	fseek(f, 0, SEEK_SET);
	*result = (char *)malloc(size+1);
	if (size != fread(*result, sizeof(char), size, f)) 
	{ 
		free(*result);
		return -2; // -2 means file reading fail 
	} 
	fclose(f);
	(*result)[size] = 0;
	return size;
}


int simple_analyse () {
	int ne=0;
	int size;
	int my_parse_result1;
	int my_parse_result2;
	printf ( "Analysis of File 1: ");
	line_counter=1;
	my_parse_result1= analyse_string ( content1);
	if (!my_parse_result1) {
		printf ("OK\n");
		add_BR();
		my_list1=my_list;
		if (verbose) print_liste(my_list,Logfile); 
		if (verbose) print_constant (constant_list,Logfile);
		the_big_link (my_list);
		my_list=NULL;
	
	}
	add_BR();
	printf ( "Analysis of  File 2: ");
	line_counter=1;
	constant_list1=constant_list; /*save the list of constants  */
	constant_list=NULL; /*empty the list of constants  */
	my_parse_result2= analyse_string ( content2);
	
	if (!my_parse_result2) {
		printf ("OK\n");
		add_BR();
		if (verbose) print_liste(my_list,Logfile);
		if (verbose) print_constant (constant_list,Logfile);
		the_big_link (my_list);
		my_list2=my_list;
	}	
	add_BR();
		
	/* ---*/
	if (!(my_parse_result1||my_parse_result2))ne=para ();

}

int cgi_version() {
    char text_1[SIZE_1] = "";
    char text_2[SIZE_2] = "";
    char line_text[SIZE_TOTAL] = "";
	char *tdecode = NULL;
	char s1[3];
	char s2[3];
	int i,l1,l2;
	
	printf("Content-Type: text/html; charset=utf-8\n\n");
	haut("ASN.1 parser");

	fgets(line_text, SIZE_TOTAL, stdin);
	
	// printf("DEBUG %s",line_text);
	add_BR();
	
	tdecode = decode(line_text, line_text+SIZE_TOTAL);
	// printf("DEBUG %s",tdecode);
	add_BR();
	
	if(sscanf(tdecode, "IEChain=%3[^&]&Warnings=%3[^&]&file1=%2000000[^&]&file2=%2000000[^&]s", s1,s2,text_1, text_2) > 0) {
		free(tdecode);
		if(strlen(text_1) == 0 || strlen(text_2) == 0) {
			printf("There was an error");
		}
		else {
			if (strcmp (s2,"Yes")==0){
				print_warnings=1;
			}
			if (strcmp (s1,"Yes")==0) {
				showIEchain=1;
			}
			l1=strlen(text_1);
			content1=malloc (l1+1);
			strcpy (content1,text_1);
			content1[l1]='\0';
			
			l2=strlen(text_2);
			content2=malloc (l2+1);
			strcpy (content2,text_2);
			content2[l2]='\0';
			
			printf("<p>Analysing</p> <BR>");
			simple_analyse ();
		}
	}
	else
	{
		printf ("An error occurred \n");
		add_BR ();
	}
	bas();
}

int main( argc, argv )
int argc;
char **argv;
{
	int ne=0;
	int size;
	int i;
	web= (strstr(argv[0],".cgi")!=NULL); 
	/*Test if the program is a CGI script or a command line */
	
	

	
	if (web) {
		/* CGI version */
		cgi_version();
	}
	else {
		/* command line version */
		printf ("Simple ASN.1 Checker \n\n");
		if ( argc > 2 )	{
		
			/*  Initialization of options */	
			i=3;
			while (i<argc) {
				if  (!strcmp(argv[i],"-w")) {
				printf ("Warning activated \n");
				printf ("DEBUG argc=%d i=%d \n",argc,i);
				print_warnings=1;
				}
				
				if  (!strcmp(argv[i],"-v")) {
				printf ("Verbose mode activated\n");
				printf ("DEBUG argc=%d i=%d \n",argc,i);
				verbose=1;
				}
				
				if  (!strcmp(argv[i],"-ie")) {
				printf ("IE chain will be printed \n");
				printf ("DEBUG argc=%d i=%d \n",argc,i);
				showIEchain=1;
				}
				i++;
			}
	
			/*Opening of the log file for writing */
			if (verbose) {
				/* We give some log information only if variable command verbose=1 */
				printf ("opening of sac_log.txt \n");
				Logfile=fopen ("sac_log.txt","w");
				if (Logfile==NULL) {
					printf ("Error when opening sac_log.txt\n");
					return (1);
				}
			}
		
		
		
			/*  loads the file in memory*/
			printf ("Loading files in memory");	
			size = load_file_to_memory(argv[1], &content1);
			if (size < 0) 
			{	 
				puts("Error loading file");
				return 1;
			} 
			printf ("...");
			size = load_file_to_memory(argv[2], &content2);
			if (size < 0) 
			{ 
				puts("Error loading file");
				return 1;
			}	 	
			printf ("OK\n");
			
			


			
			/* -- */	
			simple_analyse ();
			/* -- */
			free_liste (my_list1);
			free_liste (my_list2);	
		}
	} 
	
	printf ("END\n");
	add_BR();
	return 0;
}
