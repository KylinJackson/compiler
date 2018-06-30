%{
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
%}


%%

[a-zA-Z]	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Letter;
		}
[0-9]		{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Number;
		}
begin	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Begin;
		}
end		{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return End;
		}
integer	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Integer;
		}
function	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Function;
		}
read	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Read;
		}
write	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Write;
		}			
if		{	
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return If;
		}
then	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Then;
		}
else	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Else;
		}
"<"|"<="|">"|">="|"="|"<>"	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return RelationOperator;
		}
\;		{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Sem;
		}
\(		{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Lpar;
		}
\)		{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);	
			return Rpar;
		}
\:\=	{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Assign;
		}
\-		{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Sub;
		}
\*		{
			yylval.sValue = (char *)malloc(sizeof(yytext + 1));
			strcpy(yylval.sValue, yytext);
			return Mul;
		}
[ \t\n\r]
.		{
			printf("lex error: %s\n", yytext);
		}
%%






