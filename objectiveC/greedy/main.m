//
//  main.m
//  greedy99tsp
//
//  Maurya Avirneni
//  EID: ma48833
//  5/9/16
//  CS 345 Assignment 6

#import <Foundation/Foundation.h>

// Node class implementation

@interface Node : NSObject

@property int nodeNum;
@property int x;
@property int y;

@end

@implementation Node

@synthesize nodeNum, x, y;

-(id) init:(int)num x:(int)tempX y:(int)tempY {
    
    self = [super init];
    if (self) {
        
        nodeNum = num;
        x = tempX;
        y = tempY;
        
        return self;
    }
    return nil;
}

-(void) printData {
    
    NSLog(@"%d %d %d", nodeNum, x, y);
}

@end


// Function to get the distance between two nodes

double distance(Node *a, Node *b)
{
    return sqrt(([a x] - [b x]) * ([a x] - [b x]) + ([a y] - [b y]) * ([a y] - [b y]));
}

// Function to obtain nearest neighbor

Node *getNearestNeighbor(Node *currentNode, NSMutableArray *nodes)
{
    Node *nearestNeighbor = nil;
    double minDistance = DBL_MAX;
    for (int k = 0; k < [nodes count]; k++)
    {
        Node *neighbor = [nodes objectAtIndex:k];
        double dist = distance(currentNode, neighbor);
        //NOTE: using dist<= minDistance in the below conditional can yield different solution
        if (dist < minDistance)
        {
            minDistance = dist;
            nearestNeighbor = neighbor;
        }
    }
    return nearestNeighbor;
}

// Solve function for algorithm

void solve(NSMutableArray *nodeList)
{
    double minTotalDistance = DBL_MAX; 
    NSMutableArray *optSolutionNodes = [NSMutableArray array];
    
    // Attempt the greedy solution on every possible start node
    for (int i = 0; i < [nodeList count]; i++)
    { 
        // Copy the list of nodes
        NSMutableArray *nodes = [nodeList mutableCopy];
        double totalDistance = 0;
        
        // Build up the solution in the following list
        NSMutableArray *solutionNodes = [NSMutableArray array];
        
        // Start node
        Node *currentNode = [nodeList objectAtIndex:i];
        [solutionNodes addObject:currentNode];
        [nodes removeObjectAtIndex:i];
        while([nodes count] > 0)
        {
            currentNode = [solutionNodes objectAtIndex:[solutionNodes count] - 1];
            Node *nearestNeighbor = getNearestNeighbor(currentNode, nodes);
            double minDistance = distance(currentNode, nearestNeighbor);
            [solutionNodes addObject:nearestNeighbor];
            [nodes removeObject:nearestNeighbor];
            totalDistance += minDistance;
        }
        totalDistance += distance([solutionNodes objectAtIndex:[solutionNodes count] - 1], [solutionNodes objectAtIndex:0]);
        
        // Choose the solution with the optimal start node
        if (totalDistance < minTotalDistance)
        {
            minTotalDistance = totalDistance;
            optSolutionNodes = solutionNodes;
        }   
    }
    
    /*
     Print out the solution
     Line 1: total distance of solution cycle
     Then print nodes in order of cycle path
     */
    NSLog(@"Distance: %f", minTotalDistance);
    for (int i = 0; i < [optSolutionNodes count]; i++)
    {
        NSLog(@"%d", [[optSolutionNodes objectAtIndex:i] nodeNum]);
    }
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *str = [NSString stringWithUTF8String:argv[1]];
        
        NSString* content = [NSString stringWithContentsOfFile:str encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [content componentsSeparatedByString:@"\n"];
        
        NSMutableArray *nodes = [NSMutableArray array];
        
        for (int i=6; i<[lines count]-2; i++) {
            
            NSArray *temp = [[lines objectAtIndex:i] componentsSeparatedByString:@" "];
            NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:temp copyItems:YES];
            [arr removeObject:@""];
            
            int numTemp = [[arr objectAtIndex:0] intValue];
            int xTemp = [[arr objectAtIndex:1] intValue];
            int yTemp = [[arr objectAtIndex:2] intValue];
            
            [nodes addObject:[[Node alloc] init:numTemp x:xTemp y:yTemp]];
        }
        
        solve(nodes);
        
    }
    return 0;
}
