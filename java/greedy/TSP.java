/*
Prabhat Nagarajan (pmn356)
May 5, 2016
CS 345 - Rellermeyer

Greedy Implmentation of the Traveling Salesman Problem

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
		public int degree;
		public Node(int nodeNum, int x, int y)
		{
			this.nodeNum = nodeNum;
			this.x = x;
			this.y = y;
			degree = 0;
		}
	}

	public static class Edge implements Comparable<Edge>
	{
		public int a;
		public int b;
		public double dist;
		public Edge(int a, int b, Node n1, Node n2)
		{
			this.a = a;
			this.b = b;
			dist = distance(n1, n2);
		}

		public int compareTo(Edge e)
		{
			return Double.compare(this.dist, e.dist);
		}

		public double distance(Node a, Node b)
		{
			return Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
		}
	}

	public static void main (String args[]) throws IOException
	{
		ArrayList<Node> nodes = new ArrayList<Node>();
		parse(nodes);
		solve3(nodes);
        //getDistances(nodes);
		//System.out.println("Testing Makefile");
	}

    public static void getDistances(ArrayList<Node> nodes) throws IOException
    {
        Scanner input = new Scanner(new File("a280.opt.tour"));
        input.nextLine();
        input.nextLine();
        input.nextLine();
        input.nextLine();
        double distance = 0;
        ArrayList<Integer> nums = new ArrayList<Integer>();
        for (int i = 0; i < 280; i++)
        {
            nums.add(input.nextInt());
        }
        System.out.println(nums);
        int count = 0;
        for (int i = 1; i < 280; i++)
        {
            distance += distance(nodes.get(nums.get(i) - 1), nodes.get(nums.get(i-1) - 1));
            count++; 
        }
        distance += distance(nodes.get(nums.get(nums.size()-1) -1), nodes.get(nums.get(0) - 1));
        System.out.println(count + 1);
        System.out.println(distance);
    }

	//helper method to print the node number, along with its x and y coordinates 
	public static void printNode(Node n)
	{
		System.out.println(n.nodeNum + " " + n.x + " " + n.y);
	}

	/*
	Parse the input file and store the parsed nodes into an arraylist
	*/
	public static void parse(ArrayList<Node> nodes) throws IOException
	{
		Scanner input = new Scanner(new File("a280.tsp"));
		//Parsing with a280tsp Format
		/*Ignore header lines e.g.
		NAME : a280
		COMMENT : drilling problem (Ludwig)
		TYPE : TSP
		DIMENSION: 280
		EDGE_WEIGHT_TYPE : EUC_2D
		NODE_COORD_SECTION
		*/
		for (int i = 0; i < 6; i++)
		{
			input.nextLine();
		}
		while (input.hasNextInt())
		{
			Node node = new Node(input.nextInt(), input.nextInt(), input.nextInt());
			nodes.add(node);
			//printNode(node);
		}
	}

	public static void solve(ArrayList<Node> nodes)
	{
		double totalDistance = 0;
		ArrayList<Integer> solution = new ArrayList<Integer>();
		if (nodes.isEmpty())
		{
			System.out.println("No input data");
			return;
		}
		Node startNode = nodes.get(0);
		Node currentNode = nodes.get(0);
		solution.add(currentNode.nodeNum);
		int countEdges = 0;
		while(nodes.size() > 1)
		{
			double minDistance = Double.MAX_VALUE;
			int minIndex = -1;
			for (int k = 0; k < nodes.size(); k++)
			{
				Node neighbor = nodes.get(k);
				if(neighbor.equals(currentNode))
				{
					continue;
				}
				double dist = distance(currentNode, neighbor);
				if (dist < minDistance)
				{
					minDistance = dist;
					minIndex = k;
				}
			}
			totalDistance += minDistance;
			countEdges++;
			solution.add(nodes.get(minIndex).nodeNum);
			Node tempNode = nodes.get(minIndex);
			nodes.remove(currentNode);
			currentNode = tempNode;
		}
        System.out.println(nodes.size());
		solution.add(nodes.get(0).nodeNum);
		totalDistance += distance(nodes.get(0), startNode);
		countEdges++;
		System.out.println((new HashSet<Integer>(solution)).size());
		System.out.println(totalDistance);
		System.out.println(countEdges++);
	}
	
    public static void solve2(ArrayList<Node> nodeList)
	{
        double minTotalDistance = Double.MAX_VALUE;
        ArrayList<Integer> optSolution = new ArrayList<Integer>();
        for (int i = 0; i < nodeList.size(); i++)
        { 
            ArrayList<Node> nodes = new ArrayList<Node>(nodeList);
            double totalDistance = 0;
            ArrayList<Integer> solution = new ArrayList<Integer>();
            Node startNode = nodes.get(i);
            Node currentNode = nodes.get(i);
            solution.add(currentNode.nodeNum);
            while(nodes.size() > 1)
            {
                double minDistance = Double.MAX_VALUE;
                int minIndex = -1;
                for (int k = 0; k < nodes.size(); k++)
                {
                    Node neighbor = nodes.get(k);
                    if(neighbor.equals(currentNode))
                    {
                        continue;
                    }
                    double dist = distance(currentNode, neighbor);
                    if (dist < minDistance)
                    {
                        minDistance = dist;
                        minIndex = k;
                    }
                }
                totalDistance += minDistance;
                solution.add(nodes.get(minIndex).nodeNum);
                Node tempNode = nodes.get(minIndex);
                nodes.remove(currentNode);
                currentNode = tempNode;
            }
            System.out.println(nodes.size());
            solution.add(nodes.get(0).nodeNum);
            totalDistance += distance(nodes.get(0), startNode);
            if (totalDistance < minTotalDistance)
            {
                minTotalDistance = totalDistance;
                optSolution = solution;
            }
            System.out.println("Starting at node " + i + " takes " + totalDistance);
        }
        System.out.println(optSolution);
        System.out.println(minTotalDistance);
	}

	public static void solve3(ArrayList<Node> nodeList)
	{
        double minTotalDistance = Double.MAX_VALUE;
        //ArrayList<Integer> optSolution = new ArrayList<Integer>();
        ArrayList<Node> optSolutionNode = new ArrayList<Node>();
        for (int i = 0; i < nodeList.size(); i++)
        { 
            ArrayList<Node> nodes = new ArrayList<Node>(nodeList);
            double totalDistance = 0;
            //ArrayList<Integer> solution = new ArrayList<Integer>();
            ArrayList<Node> solutionNode = new ArrayList<Node>();
            Node currentNode = nodeList.get(i);
            //solution.add(currentNode.nodeNum);
            solutionNode.add(currentNode);
            nodes.remove(i);
            while(nodes.size() > 0)
            {
            	currentNode = solutionNode.get(solutionNode.size() - 1);
            	Node nearestNeighbor = null;
                double minDistance = Double.MAX_VALUE;
                for (int k = 0; k < nodes.size(); k++)
                {
                    Node neighbor = nodes.get(k);
                    double dist = distance(currentNode, neighbor);
                    if (dist <= minDistance)
                    {
                        minDistance = dist;
                        nearestNeighbor = neighbor;
                    }
                }
                //solution.add(nearestNeighbor.nodeNum);
                solutionNode.add(nearestNeighbor);
                nodes.remove(nearestNeighbor);
                totalDistance += minDistance;
            }
            totalDistance += distance(solutionNode.get(solutionNode.size() - 1), solutionNode.get(0));
            if (totalDistance < minTotalDistance)
            {
                minTotalDistance = totalDistance;
                //optSolution = solution;
                optSolutionNode = solutionNode;
            }
            //System.out.println("Starting at node " + i + " takes " + totalDistance);
        }
        //System.out.println(optSolution);
        for (int i = 0; i < optSolutionNode.size(); i++)
        {
        	System.out.println(optSolutionNode.get(i).nodeNum);
        }
        System.out.println("Distance: " + minTotalDistance);
	}

	public static double distance(Node a, Node b)
	{
		return Math.sqrt((a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y));
	}
}
