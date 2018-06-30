%{
#include <stdio.h>
#include <stdlib.h>

#include "libxml/tree.h"
#include "libxml/parser.h"

#include "GraAnalyse.h"

int yylex(void);
void yyerror();
void setnlValue(xmlNodePtr node, struct node_list *nodeList);
xmlNodePtr createNode(char *nodeName, char *nodeContent);

extern FILE *yyin;

%}

%union
{
	char *sValue;
	struct node_list *nlValue;
}

%token <sValue> Begin
%token <sValue> End
%token <sValue> Integer
%token <sValue> Function
%token <sValue> Read
%token <sValue> Write
%token <sValue> If
%token <sValue> Then
%token <sValue> Else
%token <sValue> Sub
%token <sValue> Sem
%token <sValue> Lpar
%token <sValue> Rpar
%token <sValue> Assign
%token <sValue> Mul
%token <sValue> RelationOperator
%token <sValue> Number
%token <sValue> Letter

%type <nlValue> Procedure
%type <nlValue> SubProcedure
%type <nlValue> DeclarationStatementTable
%type <nlValue> ExecuteStatementTable
%type <nlValue> DeclarationStatement
%type <nlValue> VariableDeclaration
%type <nlValue> FunctionDeclaration
%type <nlValue> VariableQuantity
%type <nlValue> Symbol
%type <nlValue> Parameter
%type <nlValue> FunctionBody
%type <nlValue> ExecuteStatement
%type <nlValue> ReadStatement
%type <nlValue> WriteStatement
%type <nlValue> AssignmentStatement
%type <nlValue> ConditionalStatement
%type <nlValue> ArithmeticFaultAccess
%type <nlValue> Term
%type <nlValue> Factor
%type <nlValue> Constant
%type <nlValue> FunctionCall
%type <nlValue> UnsignedInteger
%type <nlValue> ConditionalExpression

%%

start : Procedure {
	xmlDocPtr doc = xmlNewDoc(BAD_CAST "1.0");
	xmlNodePtr root_node = xmlNewNode(NULL, BAD_CAST "procedure");
	xmlDocSetRootElement(doc, root_node);
	
	setnlValue(root_node, $1);
	
	if (xmlSaveFile("GraAnalyse.xml", doc) != -1) {
		printf("Created the XML File for GraAnalyse Successfully!!!\n");
	}
}
Procedure : SubProcedure {
	/* 创建节点 */
	xmlNodePtr subProcedure = createNode("subProcedure", NULL);
	/* 连接子节点 */
	setnlValue(subProcedure, $1);

	/* 生成新的节点 */
	$$ = setStack(1, subProcedure);
}
SubProcedure : Begin DeclarationStatementTable Sem ExecuteStatementTable End {
	xmlNodePtr varBegin = createNode("terminal", $1);
	xmlNodePtr declarationStatementTable = createNode("declarationStatementTable", NULL);
	xmlNodePtr sem = createNode("terminal", $3);
	xmlNodePtr executeStatementTable = createNode("executeStatementTable", NULL);
	xmlNodePtr varEnd = createNode("terminal", $5);
	
	setnlValue(declarationStatementTable, $2);
	setnlValue(executeStatementTable, $4);
	
	$$ = setStack(5, varBegin, declarationStatementTable, sem, executeStatementTable, varEnd);
}
DeclarationStatementTable : DeclarationStatement {
	xmlNodePtr declarationStatement = createNode("declarationStatement", NULL);
	
	setnlValue(declarationStatement, $1);

	$$ = setStack(1, declarationStatement);
}
| DeclarationStatementTable Sem DeclarationStatement {
	xmlNodePtr declarationStatementTable = createNode("declarationStatementTable", NULL);
	xmlNodePtr sem = createNode("terminal", $2);
	xmlNodePtr declarationStatement = createNode("declarationStatement", NULL);
	
	setnlValue(declarationStatementTable, $1);
	setnlValue(declarationStatement, $3);

	$$ = setStack(3, declarationStatementTable, sem, declarationStatement);
}
DeclarationStatement : VariableDeclaration {
	xmlNodePtr variableDeclaration = createNode("variableDeclaration", NULL);
	
	setnlValue(variableDeclaration, $1);
	
	$$ = setStack(1, variableDeclaration);
}
| FunctionDeclaration {
	xmlNodePtr functionDeclaration = createNode("functionDeclaration", NULL);
	
	setnlValue(functionDeclaration, $1);
	
	$$ = setStack(1, functionDeclaration);
}
VariableDeclaration : Integer VariableQuantity {
	xmlNodePtr varInteger = createNode("terminal", $1);
	xmlNodePtr variableQuantity = createNode("variableQuantity", NULL);
	
	setnlValue(variableQuantity, $2);
	
	$$ = setStack(2, varInteger, variableQuantity);
}
VariableQuantity : Symbol {
	xmlNodePtr symbol = createNode("symbol", NULL);
	
	setnlValue(symbol, $1);
	
	$$ = setStack(1, symbol);
}
Symbol : Letter {
	xmlNodePtr letter = createNode("letter", $1);
	
	$$ = setStack(1, letter);
}
| Symbol Letter {
	xmlNodePtr symbol = createNode("symbol", NULL);
	xmlNodePtr letter = createNode("letter", $2);
	
	setnlValue(symbol, $1);
	
	$$ = setStack(2, symbol, letter);
}
| Symbol Number {
	xmlNodePtr symbol = createNode("symbol", NULL);
	xmlNodePtr number = createNode("number", $2);
	
	setnlValue(symbol, $1);
	
	$$ = setStack(2, symbol, number);
}
FunctionDeclaration : Integer Function Symbol Lpar Parameter Rpar Sem FunctionBody {
	xmlNodePtr varInteger = createNode("terminal", $1);
	xmlNodePtr varFunction = createNode("terminal", $2);
	xmlNodePtr symbol = createNode("symbol", NULL);
	xmlNodePtr lpar = createNode("terminal", $4);
	xmlNodePtr parameter = createNode("parameter", NULL);
	xmlNodePtr rpar = createNode("terminal", $6);
	xmlNodePtr sem = createNode("terminal", $7);
	xmlNodePtr functionBody = createNode("functionBody", NULL);
	
	setnlValue(symbol, $3);
	setnlValue(parameter, $5);
	setnlValue(functionBody, $8);
	
	$$ = setStack(8, varInteger, varFunction, symbol, lpar, parameter, rpar, sem, functionBody);
}
Parameter : VariableQuantity {
	xmlNodePtr variableQuantity = createNode("variableQuantity", NULL);
	
	setnlValue(variableQuantity, $1);
	
	$$ = setStack(1, variableQuantity);
}
FunctionBody : Begin DeclarationStatementTable Sem ExecuteStatementTable End {
	xmlNodePtr varBegin = createNode("terminal", $1);
	xmlNodePtr declarationStatementTable = createNode("declarationStatementTable", NULL);
	xmlNodePtr sem = createNode("terminal", $3);
	xmlNodePtr executeStatementTable = createNode("executeStatementTable", NULL);
	xmlNodePtr varEnd = createNode("terminal", $5);
	
	setnlValue(declarationStatementTable, $2);
	setnlValue(executeStatementTable, $4);
	
	$$ = setStack(5, varBegin, declarationStatementTable, sem, executeStatementTable, varEnd);
}
ExecuteStatementTable : ExecuteStatement {
	xmlNodePtr executeStatement = createNode("executeStatement", NULL);
	
	setnlValue(executeStatement, $1);
	
	$$ = setStack(1, executeStatement);
}
| ExecuteStatementTable Sem ExecuteStatement {
	xmlNodePtr executeStatementTable = createNode("executeStatementTable", NULL);
	xmlNodePtr sem = createNode("terminal", $2);
	xmlNodePtr executeStatement = createNode("executeStatement", NULL);
	
	setnlValue(executeStatementTable, $1);
	setnlValue(executeStatement, $3);
	
	$$ = setStack(3, executeStatementTable, sem, executeStatement);
}
ExecuteStatement : ReadStatement {
	xmlNodePtr readStatement = createNode("readStatement", NULL);
	
	setnlValue(readStatement, $1);
	
	$$ = setStack(1, readStatement);
}
| WriteStatement {
	xmlNodePtr writeStatement = createNode("writeStatement", NULL);
	
	setnlValue(writeStatement, $1);
	
	$$ = setStack(1, writeStatement);
}
| AssignmentStatement {
	xmlNodePtr assignmentStatement = createNode("assignmentStatement", NULL);
	
	setnlValue(assignmentStatement, $1);
	
	$$ = setStack(1, assignmentStatement);
}
| ConditionalStatement {
	xmlNodePtr conditionalStatement = createNode("conditionalStatement", NULL);
	
	setnlValue(conditionalStatement, $1);
	
	$$ = setStack(1, conditionalStatement);
}
ReadStatement : Read Lpar VariableQuantity Rpar {
	xmlNodePtr varRead = createNode("terminal", $1);
	xmlNodePtr lpar = createNode("terminal", $2);
	xmlNodePtr variableQuantity = createNode("variableQuantity", NULL);
	xmlNodePtr rpar = createNode("terminal", $4);
	
	setnlValue(variableQuantity, $3);
	
	$$ = setStack(4, varRead, lpar, variableQuantity, rpar);
}
WriteStatement : Write Lpar VariableQuantity Rpar {
	xmlNodePtr varWrite = createNode("terminal", $1);
	xmlNodePtr lpar = createNode("terminal", $2);
	xmlNodePtr variableQuantity = createNode("variableQuantity", NULL);
	xmlNodePtr rpar = createNode("terminal", $4);
	
	setnlValue(variableQuantity, $3);
	
	$$ = setStack(4, varWrite, lpar, variableQuantity, rpar);
}
AssignmentStatement : VariableQuantity Assign ArithmeticFaultAccess {
	xmlNodePtr variableQuantity = createNode("variableQuantity", NULL);
	xmlNodePtr varAssign = createNode("terminal", $2);
	xmlNodePtr arithmeticFaultAccess = createNode("arithmeticFaultAccess", NULL);
	
	setnlValue(variableQuantity, $1);
	setnlValue(arithmeticFaultAccess, $3);
	
	$$ = setStack(3, variableQuantity, varAssign, arithmeticFaultAccess);
}
ArithmeticFaultAccess : ArithmeticFaultAccess Sub Term {
	xmlNodePtr arithmeticFaultAccess = createNode("arithmeticFaultAccess", NULL);
	xmlNodePtr sub = createNode("terminal", $2);
	xmlNodePtr term = createNode("term", NULL);
	
	setnlValue(arithmeticFaultAccess, $1);
	setnlValue(term, $3);

	$$ = setStack(3, arithmeticFaultAccess, sub, term);
}
| Term {
	xmlNodePtr term = createNode("term", NULL);
	
	setnlValue(term, $1);
	
	$$ = setStack(1, term);
}
Term : Term Mul Factor {
	xmlNodePtr term = createNode("term", NULL);
	xmlNodePtr mul = createNode("terminal", $2);
	xmlNodePtr factor = createNode("factor", NULL);
	
	setnlValue(term, $1);
	setnlValue(factor, $3);
	
	$$ = setStack(3, term, mul, factor);
}
| Factor {
	xmlNodePtr factor = createNode("factor", NULL);
	
	setnlValue(factor, $1);
	
	$$ = setStack(1, factor);
}
Factor : VariableQuantity {
	xmlNodePtr variableQuantity = createNode("variableQuantity", NULL);
	
	setnlValue(variableQuantity, $1);
	
	$$ = setStack(1, variableQuantity);
}
| Constant {
	xmlNodePtr varConstant = createNode("constant", NULL);
	
	setnlValue(varConstant, $1);
	
	$$ = setStack(1, varConstant);
}
| FunctionCall {
	xmlNodePtr functionCall = createNode("functionCall", NULL);
	
	setnlValue(functionCall, $1);
	
	$$ = setStack(1, functionCall);
}
Constant : UnsignedInteger {
	xmlNodePtr unsignedInteger = createNode("unsignedInteger", NULL);
	
	setnlValue(unsignedInteger, $1);
	
	$$ = setStack(1, unsignedInteger);
}
UnsignedInteger : Number {
	xmlNodePtr number = createNode("number", $1);
	
	$$ = setStack(1, number);
}
FunctionCall : Symbol Lpar ArithmeticFaultAccess Rpar {
	xmlNodePtr symbol = createNode("symbol", NULL);
	xmlNodePtr lpar = createNode("terminal", $2);
	xmlNodePtr arithmeticFaultAccess = createNode("arithmeticFaultAccess", NULL);
	xmlNodePtr rpar = createNode("terminal", $4);
	
	setnlValue(symbol, $1);
	setnlValue(arithmeticFaultAccess, $3);
	
	$$ = setStack(4, symbol, lpar, arithmeticFaultAccess, rpar);
}
ConditionalStatement : If ConditionalExpression Then ExecuteStatement Else ExecuteStatement {
	xmlNodePtr varIf = createNode("terminal", $1);
	xmlNodePtr conditionalExpression = createNode("conditionalExpression", NULL);
	xmlNodePtr varThen = createNode("terminal", $3);
	xmlNodePtr executeStatement1 = createNode("executeStatement", NULL);
	xmlNodePtr varElse = createNode("terminal", $5);
	xmlNodePtr executeStatement2 = createNode("executeStatement", NULL);
	
	setnlValue(conditionalExpression, $2);
	setnlValue(executeStatement1, $4);
	setnlValue(executeStatement2, $6);
	
	$$ = setStack(6, varIf, conditionalExpression, varThen, executeStatement1, varElse, executeStatement2);
}
ConditionalExpression : ArithmeticFaultAccess RelationOperator ArithmeticFaultAccess {
	xmlNodePtr arithmeticFaultAccess1 = createNode("arithmeticFaultAccess", NULL);
	xmlNodePtr relationOperator = createNode("relationOperator", $2);
	xmlNodePtr arithmeticFaultAccess2 = createNode("arithmeticFaultAccess", NULL);
	
	setnlValue(arithmeticFaultAccess1, $1);
	setnlValue(arithmeticFaultAccess2, $3);

	$$ = setStack(3, arithmeticFaultAccess1, relationOperator, arithmeticFaultAccess2);
}

%%

int main(int argc, char **argv) {
	if (argc != 2) {
		printf("Usage: %s filename\n", argv[0]);
		return 0;
	}
	yyin = fopen(argv[1], "r");
	
	yyparse();
	fclose(yyin);
	return 0;
}