/*
Prabhat Nagarajan (pmn356)
May 5, 2016
CS 345 - Rellermeyer

Greedy Implementation of the Traveling Salesman Problem

This implementation requires the .tsp format for input files
*/
import java.util.*;
import java.io.*;
public class TSP
{
    /*    
    Node helper class
    We create a Node to store the node number, and x,y cartesian coordinates 
    from the input file
    */
    public static class Node
    {
        public int nodeNum;
        public int x;
        public int y;
        public Node(int nodeNum, int x, int y)
        {
            this.nodeNum = nodeNum;
            this.x = x;
            this.y = y;
        }
    }

    public static void main (String args[])
    {
        try
        {
            //Take filename as command line argument
            String fileName = args[0];
            ArrayList<Node> nodes = new ArrayList<Node>();
            //parse creates node objects and stores them in nodes
            parse(nodes, fileName);
            //implements the greedy TSP algorithm on given nodes
            solve(nodes);
        }
        catch (IOException e)
        {
            e.printStackTrace();
        }
    }

    //helper method to print the node number, along with its x and y coordinates 
    public static void printNode(Node n)
    {
        System.out.println(n.nodeNum + " " + n.x + " " + n.y);
    }

    /*
    Parse the input file and store the parsed nodes into an arraylist
    */
    public static void parse(ArrayList<Node> nodes, String fileName) throws IOException
    {
        Scanner input = new Scanner(new File(fileName));
        //Parsing with a280tsp Format
        /*Ignore header lines e.g.
        NAME : a280
        COMMENT : drilling problem (Ludwig)
        TYPE : TSP
        DIMENSION: 280
        EDGE_WEIGHT_TYPE : EUC_2D
        NODE_COORD_SECTION
        */
        //Ignore the first 6 header lines
        for (int i = 0; i < 6; i++)
        {
            input.nextLine();
        }
        //read in the values for each node
        while (input.hasNextInt())
        {
            /*
            read in node number, x coordinate, y coordinate
            e.g. 20 280 290
            */
            Node node = new Node(input.nextInt(), input.nextInt(), input.nextInt());
            nodes.add(node);
        }
    }

    public static void solve(ArrayList<Node> nodeList)
    { 
        //copy the list of nodes
        ArrayList<Node> nodes = new ArrayList<Node>(nodeList);
        double totalDistance = 0;
        //we build up the solution in the following list
        ArrayList<Node> solutionNodes = new ArrayList<Node>();
        int random = (int) (Math.random() * nodes.size());
        //choose a random start node
        Node currentNode = nodeList.get(random);
        solutionNodes.add(currentNode);
        nodes.remove(random);
        while(nodes.size() > 0)
        {
            currentNode = solutionNodes.get(solutionNodes.size() - 1);
            Node nearestNeighbor = getNearestNeighbor(currentNode, nodes);
            double minDistance = distance(currentNode, nearestNeighbor);
            solutionNodes.add(nearestNeighbor);
            nodes.remove(nearestNeighbor);
            totalDistance += minDistance;
        }
        totalDistance += distance(solutionNodes.get(solutionNodes.size() - 1), solutionNodes.get(0));
        /*
        Print out the solution
        Line 1: total distance of solution cycle
        Next Lines: print out nodes in order of cycle path
        Final Line: print out -1, indicating end of solution output, consistent with a280.opt.tour file
        */ 
        System.out.println("Distance: " + totalDistance);
        for (int i = 0; i < solutionNodes.size(); i++)
        {
            System.out.println(solutionNodes.get(i).nodeNum);
        }
        System.out.println(-1);
    }

    /*
    Utility function to obtain the nearest neighbor
    */
    public static Node getNearestNeighbor(Node currentNode, ArrayList<Node> nodes)
    {
        Node nearestNeighbor = null;
        double minDistance = Double.MAX_VALUE;
        for (int k = 0; k < nodes.size(); k++)
        {
            Node neighbor = nodes.get(k);
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

    /*
    Utility function to get the distance between two nodes
    */
    public static double distance(Node a, Node b)
    {
        return Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
    }
}
