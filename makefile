# Copyright (C) 2015 Nokia Solutions and Networks. 

#    This file is part of "Simple ASN.1 Checker".                                   
#                                                                                   
#   "Simple ASN.1 Checker" is free software: you can redistribute it and/or modify  
#    it under the terms of the GNU General Public License as published by           
#    the Free Software Foundation, either version 2 of the License, or              
#    (at your option) any later version.                                            
#                                                                                   
#    "Simple ASN.1 Checker" is distributed in the hope that it will be useful,      
#    but WITHOUT ANY WARRANTY; without even the implied warranty of                 
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                  
#    GNU General Public License for more details.                                   
#                                                                                   
#    You should have received a copy of the GNU General Public License              
#    along with "Simple ASN.1 Checker".  If not, see <http://www.gnu.org/licenses/>.

LEX     = flex
YACC    = bison
YFLAGS  = -d

SAC_EX=sac.exe

all: $(SAC_EX)

$(SAC_EX) : lex.yy.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $(SAC_EX) lex.yy.c  sac.tab.c parallel.c main.c

lex.yy.c: sac.l sac.tab.c
	$(LEX)  sac.l

sac.tab.c: sac.y
	$(YACC) $(YFLAGS) sac.y

clean:
	$(RM) $(SAC_EX) lex.yy.c sac.tab.c sac.tab.h

.PHONY: clean

