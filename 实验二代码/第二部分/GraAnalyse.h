#include "libxml/tree.h"
#include "libxml/parser.h"
#include <stdarg.h>

struct node_list {
	xmlNodePtr node[10];			/* node list for unconnected nodes */
	int numOfNodes;					/* number of unconnected nodes */
};

void setnlValue(xmlNodePtr node, struct node_list *nodeList) {
	/* connect the parent nodes with the child nodes in the unconnected node list. */
	int i;
	for (i = 0; i < nodeList->numOfNodes; i++) {
		xmlAddChild(node, nodeList->node[i]);
	}
	free(nodeList);
}

void yyerror(char* str) {
	/* call when yacc discovering a error */
	printf("yacc error: %s\n", str);
	exit(0);
}

xmlNodePtr createNode(char *nodeName, char *nodeContent) {
	/* create a new node while reducting */
	xmlNodePtr newNode = xmlNewNode(NULL, BAD_CAST nodeName);
	if (nodeContent != NULL) {
		/* when the node is a terminal node */
		xmlNodePtr content = xmlNewText(BAD_CAST nodeContent);
		xmlAddChild(newNode, content);
	}
	return newNode;
}

struct node_list *setStack(int num, ...) {
	struct node_list *newNodeList = (struct node_list *) malloc (sizeof (struct node_list));
	va_list nodeList;
	va_start(nodeList, num);
	newNodeList->numOfNodes = num;
	int i;
	for (i = 0; i < num; i++) {
		newNodeList->node[i] = va_arg(nodeList, struct node_list *);
	}
	va_end(nodeList);
	return newNodeList;
}