/* Naren Inukoti
   CS 345
   ni975  */

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <time.h>
#include <stdbool.h>

#define numIterations 100
#define initialTemp 100.0
#define meltingRate 0.99
#define targetTemp 0.001

typedef struct {
    int x;
    int y; } city;

int numCities;

double currTravelLength = 0.0;

//Calculates distance between two points
double distance(x, x1, y, y1){
    return sqrt(((x-x1)*(x-x1))+((y-y1)*(y-y1)));
}

//Given an arrangement it calculates the total travelLength of that arrangement
double total_travelLengths(city listOfCities[]){
    double totalTravel = 0.0;

    int i = 0;
    while(i<numCities){
        totalTravel += distance(listOfCities[i].x,listOfCities[i].y,listOfCities[i+1].x, listOfCities[i+1].y);
        i++;
    }
    //length between last node and first node
    totalTravel += distance(listOfCities[numCities-1].x,listOfCities[numCities-1].y, listOfCities[0].x, listOfCities[0].y);

    return totalTravel;
}

//Given an arrangement, randomly switches two indexes and recalculates travelLength for the new arrangement
void findRandomNeighbor(city listOfCities[]){
    int randPos, randPos1;
    bool flag = true;
    while(flag){
        randPos = (int)( ((double)numCities * rand()) / (RAND_MAX + 1.0) );
        randPos1 = (int)( ((double)numCities * rand()) / (RAND_MAX + 1.0) );

        flag = (randPos == randPos1);
    }
    int tx = listOfCities[randPos].x;
    int ty = listOfCities[randPos].y;
    listOfCities[randPos].x = listOfCities[randPos1].x;
    listOfCities[randPos].y = listOfCities[randPos1].y;
    listOfCities[randPos1].x = tx;
    listOfCities[randPos1].y = ty;
}

double sim_anneal(city listOfCities[]){
    double deltaE = 0;
    double temperature = initialTemp;
    double finalTravelLength = currTravelLength;
    double tempTravelLength = 0.0;
       while(temperature > targetTemp) {
            for (int i = 0 ; i < numIterations ; i++) {
              findRandomNeighbor(listOfCities);
              tempTravelLength = total_travelLengths(listOfCities);
              deltaE = tempTravelLength - currTravelLength;
              double r = ((double)rand()/(double)RAND_MAX);
              if((deltaE<0.0)||(deltaE>0.0 && (exp((-deltaE/temperature)) > r))) {
                if (tempTravelLength < finalTravelLength){
                    finalTravelLength = tempTravelLength;
                }
                currTravelLength = tempTravelLength;
              }
            }
        temperature *= meltingRate;
        }
    return finalTravelLength;
}

main(int argx, char **argv){
    if(argv[1] == NULL){
    		printf("No file found\n");
    		exit(1);
    }
    srand(time(NULL));
    char * file = argv[1];
    FILE *fp;
    char buffer[255];
    int cityCount = 0;
    int x = 0;
    int y = 0;

	printf("\n");

	fp = fopen(file,"r");

	for(int x = 0;x<3;x++){
    	fgets(buffer, 255, fp);
    }
    char str1[15];
    fscanf(fp, "%s %d", str1, &numCities);
    city listOfCities[numCities];

    for(int x = 0;x<2;x++){
        fgets(buffer, 255, (FILE*)fp);
    }
    int i = 0;
    while(!feof(fp)){
        fscanf(fp, "%d", &cityCount);
        fscanf(fp, "%d", &x);
        fscanf(fp, "%d", &y);
        city newCity = {x,y};
        listOfCities[i] = newCity;
        fgets(buffer, 255, (FILE*)fp);
        i++;
    }
    fclose(fp);
    currTravelLength = total_travelLengths(listOfCities);
    double result = sim_anneal(listOfCities);
    printf("Best total minimum travel distance: %f\n", result);
}