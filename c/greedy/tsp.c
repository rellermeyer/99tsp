/*Brandon Post (bkp472)
May, 2016
CS 345 - Rellermeyer 

Fixed/edited by Loc Hoang
*/


#include<stdio.h>
#include<float.h>
#include<math.h>

struct Node { // nodes for the final graph
	int x;
	int y;
	int nodeId;
};
struct Element { // elements for linked list
	struct Node *node;
	struct Element *next;
};

double distance(int x1, int y1, int x2, int y2){
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)));
}

printList(struct Element * list){
	while(list != NULL){
		printf("id is: %d x is: %d y is: %d\n", list->node->nodeId, list->node->x, list->node->y);
		list = list->next;
	}
}
struct Element* parseFile(char *file){
	FILE *filepointer;
	char buf[255]; // lines for use in loop
	char loc[255]; // file location
	struct Element *prevElement = NULL;
	struct Element *currElement;
	int id = 0;
	int x = 0;
	int y = 0;

	//strcpy(loc, "TSPdata/");
	strcat(loc, file);
	//strcat(loc, ".tsp");

	printf("\n");

	filepointer = fopen(loc,"r");

	for(int x = 0;x<6;x++){ //skip the upper data section
		fgets(buf, 255, filepointer);
	}

	while(!feof(filepointer))
	{
		struct Node * newNode = malloc(96); //3 ints
		currElement = malloc(128); //I think I'm running on 64 bit
		fscanf(filepointer, "%d", &id); //assign parts of nodes
		fscanf(filepointer, "%d", &x);
		fscanf(filepointer, "%d", &y);
		newNode->nodeId = id;
		newNode->x = x;
		newNode->y = y;
		currElement->node = newNode;
		currElement->next = prevElement;
		prevElement = currElement;


	fgets(buf, 255, (FILE*)filepointer);
	}

	fclose(filepointer); //done with file
	return currElement->next->next;
}

double getSolution(struct Element * list, struct Element * first, struct Element * justUsed, double sol){
	double minDist = DBL_MAX;
	struct Element * minElement;
	struct Element * listCopy = list;
	struct Element * returnList = list;
	int skip = 0;
	if(list->next == NULL)
		return sol + distance(first->node->x,first->node->y,list->node->x,list->node->y);

	if(justUsed == NULL){
		list = list->next;
		returnList = returnList->next;
		justUsed = first;
	}

	while(list != NULL){
		double dist = distance(justUsed->node->x,justUsed->node->y,list->node->x,list->node->y);
		if(dist < minDist){
			minDist = dist;
			minElement = list;
		}
		list = list->next;
	}
	printf("Picked node %d\t at a cost of %f\n",minElement->node->nodeId,minDist);
	if(listCopy == minElement){
		skip = 1;
		returnList = returnList->next;
	}
	while(listCopy->next != minElement && !skip){
		listCopy = listCopy -> next;
	}
	//node is currently before the minElement, which we need to remove from the list.
	listCopy->next = listCopy->next->next;
	return getSolution(returnList,first,minElement,sol + minDist);
}

main(int argx, char **argv)
{
	//argv[0] should contain program name
	//argv[1] should be first arg, should be input file.
	//!!!!! Perhaps implement multiple file names? 
	struct Element *list;
	double solution = 0.0;
	if(argv[1] == NULL){ // check for input file
		printf("99 TSP - No input file\n");
		exit(1);
	}

	//parse input file
	list = parseFile(argv[1]); //get linked list of vals
	solution = getSolution(list, list, NULL, 0.0);

	printf("The total distance is: %f\n", solution);
}
