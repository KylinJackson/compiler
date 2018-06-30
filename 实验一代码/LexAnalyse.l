%{
#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "libxml/parser.h"
#include "libxml/tree.h"

#define $SYMBOL 1
#define $CONSTANT 2
#define $INT 3
#define $IF 4
#define $ELSE 5
#define $WHILE 6
#define $FOR 7
#define $READ 8
#define $WRITE 9
#define $ADD 10
#define $SUB 11
#define $MUL 12
#define $DIV 13
#define $L 14
#define $LE 15
#define $G 16
#define $GE 17
#define $NE 18
#define $E 19
#define $ASSIGN 20
#define $LPAR 21
#define $RPAR 22
#define $COM 23
#define $SEM 24

#define MAX_LEN 1000

xmlNodePtr binary; /* 定义二元式xml节点 */
xmlNodePtr symbol_table; /* 定义符号表xml节点 */
xmlNodePtr constant_table; /* 定义常数表xml节点 */

char *symbol[MAX_LEN]; /* 符号表 */
int number[MAX_LEN]; /* 常数表 */

int lenSymbol = 0; /* 符号表中元素个数 */
int lenNumber = 0; /* 常数表中元素个数 */

struct Word_Struct {
	int type;
	int position;
} val;

void addBinary(struct Word_Struct word);

%}

symbol [a-zA-Z][a-zA-Z0-9]*
number [0-9]+

%%
int		{
			val.type = $INT;
			val.position = -1;
			addBinary(val);
		}
if		{
			val.type = $IF;
			val.position = -1;
			addBinary(val);
		}
else	{
			val.type = $ELSE;
			val.position = -1;
			addBinary(val);
		}
while	{
			val.type = $WHILE;
			val.position = -1;
			addBinary(val);
		}
for		{
			val.type = $FOR;
			val.position = -1;
			addBinary(val);
		}
read	{
			val.type = $READ;
			val.position = -1;
			addBinary(val);
		}
write	{
			val.type = $WRITE;
			val.position = -1;
			addBinary(val);
		}
\+		{
			val.type = $ADD;
			val.position = -1;
			addBinary(val);
		}
\-		{
			val.type = $SUB;
			val.position = -1;
			addBinary(val);
		}
\*		{
			val.type = $MUL;
			val.position = -1;
			addBinary(val);
		}
\/		{
			val.type = $DIV;
			val.position = -1;
			addBinary(val);
		}
\<		{
			val.type = $L;
			val.position = -1;
			addBinary(val);
		}
\<\=	{
			val.type = $LE;
			val.position = -1;
			addBinary(val);
		}
\>		{
			val.type = $G;
			val.position = -1;
			addBinary(val);
		}	
\>\=	{
			val.type = $GE;
			val.position = -1;
			addBinary(val);
		}
\=		{
			val.type = $ASSIGN;
			val.position = -1;
			addBinary(val);
		}
\=\=		{
			val.type = $E;
			val.position = -1;
			addBinary(val);
		}
\!\=	{
			val.type = $NE;
			val.position = -1;
			addBinary(val);
		}
\(		{
			val.type = $LPAR;
			val.position = -1;
			addBinary(val);
		}
\)		{
			val.type = $RPAR;
			val.position = -1;
			addBinary(val);
		}
\,		{
			val.type = $COM;
			val.position = -1;
			addBinary(val);
		}
\;		{
			val.type = $SEM;
			val.position = -1;
			addBinary(val);
		}
{symbol}	{
				val.type = $SYMBOL;
				int i;
				for (i = 0; i < lenSymbol; i++) {
					if (strcmp(symbol[i], yytext) == 0) {
						val.position = i;
						break;
					}
				}
				if (i == lenSymbol) {
					lenSymbol++;
					symbol[i] = (char*)malloc(sizeof(char) * strlen(yytext));
					strcpy(symbol[i], yytext);
					val.position = i;
					
					/* 加入符号表 */
					
					char tmpstr[15];
					xmlNodePtr newSymbol = xmlNewNode(NULL, BAD_CAST "symbol");
					xmlAddChild(symbol_table, newSymbol);
					xmlNewTextChild(newSymbol, NULL, BAD_CAST "value", BAD_CAST yytext);
					sprintf(tmpstr, "%d", i);
					xmlNewTextChild(newSymbol, NULL, BAD_CAST "position", BAD_CAST tmpstr);
				}
				addBinary(val);
			}
{number}	{
				val.type = $CONSTANT;
				
				int i;
				for (i = 0; i < lenNumber; i++) {
					if (number[i] == atoi(yytext)) {
						val.position = i;
						break;
					}
				}
				if (i == lenNumber) {
					lenNumber++;
					number[i] = atoi(yytext);
					val.position = i;
					char tmpstr[15];
					xmlNodePtr newNumber = xmlNewNode(NULL, BAD_CAST "constant");
					xmlAddChild(constant_table, newNumber);
					xmlNewTextChild(newNumber, NULL, BAD_CAST "value", BAD_CAST yytext);
					sprintf(tmpstr, "%d", i);
					xmlNewTextChild(newNumber, NULL, BAD_CAST "position", BAD_CAST tmpstr);
				}
				addBinary(val);
			}
%%

void addBinary(struct Word_Struct word) {
	xmlNodePtr newWord = xmlNewNode(NULL, BAD_CAST "word");
	xmlAddChild(binary, newWord);
	char tmpstr[15];
	sprintf(tmpstr, "%d", word.type);
	xmlNewTextChild(newWord, NULL, BAD_CAST "type", BAD_CAST tmpstr);
	if (word.position == -1) {
		xmlNewTextChild(newWord, NULL, BAD_CAST "position", BAD_CAST "NULL");
	} else {
		sprintf(tmpstr, "%d", word.position);
		xmlNewTextChild(newWord, NULL, BAD_CAST "position", BAD_CAST tmpstr);
	}
}

int main(int argc, char **argv) {
	yyin = fopen(argv[1], "r");
	
	if(yyin == NULL)
	{
		printf("error: no file or file not found\n");
		return 0;
	}
	
	xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
	xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST "LexAnalyse");
	xmlDocSetRootElement(doc, root_node);
	
	binary = xmlNewNode(NULL, BAD_CAST "binary");
	symbol_table = xmlNewNode(NULL, BAD_CAST "symbol_table");
	constant_table = xmlNewNode(NULL, BAD_CAST "constant_table");
	
	xmlAddChild(root_node, binary);
	xmlAddChild(root_node, symbol_table);
	xmlAddChild(root_node, constant_table);
	
	yylex();
	
	if (xmlSaveFile("LexAnalyse.xml", doc) != -1) {
		printf("Created the XML File for LexAnalyse Successfully!!!\n");
	}
	xmlFreeDoc(doc);
	int i;
	for (i = 0; i < lenSymbol; i++) {
		free(symbol[i]);
	}
	fclose(yyin);
	return 0;
}
int yywrap() {
	return 1;
}


