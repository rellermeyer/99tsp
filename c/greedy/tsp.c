/*Brandon Post (bkp472)
May, 2016
CS 345 - Rellermeyer */


#include<stdio.h>
#include<float.h>
#include<math.h>

struct Node { //nodes for the final graph
	int x;
	int y;
	int nodeId;
};
struct Element { //elements for linked list
	struct Node * node;
	struct Element * next;
};

double distance(int x1, int y1, int x2, int y2){
	return sqrt(((x2-x1)*(x2-x1))+((y2-y1)*(y2-y1)));
}
struct Element * parseFile(char * file){
	FILE *filepointer;
	char buf[255]; //lines for use in loop
	char loc[255]; //file location
	struct Element * prevElement = NULL;
	struct Element * currElement;
	int id = 0;
	int x = 0;
	int y = 0;



	strcpy(loc, "TSPdata/");
	strcat(loc, file);
	strcat(loc, ".tsp");

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
	return currElement->next;
}

main(int argx, char **argv)
{
	//argv[0] should contain program name
	//argv[1] should be first arg, should be input file.
	//!!!!! Perhaps implement multiple file names? 
	struct Element * list;

	if(argv[1] == NULL){ //check for input file
		printf("99 TSP - No input file\n");
		exit(1);
	}

	//parse input file
	list = parseFile(argv[1]); //get linked list of vals

	double minimumTotal = DBL_MAX;
	printf("Random distance: %f", distance(-2,1,1,5));

	/*while(list != NULL){
		printf("id is: %d x is: %d y is: %d\n", list->node->nodeId, list->node->x, list->node->y);
		list = list->next;
	}*/
	printf("The very end\n");
}
