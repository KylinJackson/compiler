%{
#include<stdlib.h>
#include<stdio.h>

#include "y.tab.h"

%}


%%

[a-zA-Z]	{
			return LETTER;
		}
[0-9]		{
			return NUMBER;
		}
begin	{
			return VARBEGIN;
		}
end		{
			return VAREND;
		}
integer	{
			return INTEGER;
		}
function	{
			return FUNCTION;
		}
read	{
			return READ;
		}
write	{
			return WRITE;
		}			
if		{	
			return IF;
		}
then	{
			return THEN;
		}
else	{
			return ELSE;
		}
\<		{
			return L;
		}
\<\=	{
			return LE;
		}
\>		{
			return R;
		}
\>\=	{
			return RE;
		}
\=		{
			return E;
		}
\<\>	{
			return NE;
		}
\;		{
			return SEM;
		}
\(		{
			return LPAR;
		}
\)		{	
			return RPAR;
		}
\:\=	{
			return ASSIGN;
		}
\-		{
			return SUB;
		}
\*		{
			return MUL;
		}
[ \t\n\r]
.		{
			printf("lex error: %s\n", yytext);
		}
%%





