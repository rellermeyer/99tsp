import java.io.File;
import java.io.IOException;
import java.util.*;

/**
 * Created by lyee on 12/5/16.
 * This Traveling Salesman implementation only takes .tsp files.
 * Uses a DP algorithm to solve the TSP problem.
 */
public class TSP {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.err.println("99 TSP - No input file");
            System.exit(1);
        }
        System.out.println("99 TSP - Input file is " + args[0]);
        new TSP(args[0]);
    }

    /**
     * TSMain constructor. Parses the given file name and outputs the result of the TSP to standard output.
     * @param file The name of the file to read
     */
    public TSP(String file) {
        try {
            List<Node> nodes = parse(file);
            evaluate(nodes);
        }
        catch(IOException exception) {
            System.err.println("Error reading file " + exception.getMessage());
            System.exit(1);
        }
    }

    /**
     * Parses the given .tsp file into a List of nodes
     * @param file The name of the .tsp file to parse
     * @return A list of parsed nodes in the order provided in the file
     * @throws IOException
     */
    public List<Node> parse(String file) throws IOException{
        Scanner sc = new Scanner(new File(file));
        String line = sc.nextLine();
        //Ignore all lines until we get to the "NODE_COORD_SECTION"
        while(!line.trim().equals("NODE_COORD_SECTION")) {
            line = sc.nextLine();
        }

        List<Node> nodes = new ArrayList<>();
        //This is the node coordinate section
        while(sc.hasNext() && !line.equals("EOF")) {
            line = sc.next();
            if(!line.equals("EOF")) {
                nodes.add(new Node(line, sc.next(), sc.next()));
            }
        }

        return nodes;
     }

    /**
     * Evaluates the given nodes according to the DP solution for the TSP problem.
     * @param nodes the list of nodes to evaluate. {@code nodes(0)} will be treated as the starting node.
     * @return the minimal total length to traverse each {@code Node} exactly once and return back to the starting Node.
     */
     public void evaluate(List<Node> nodes) {

         //This will be the first node that we have to return to last in the list.
         Node firstNode = nodes.remove(0);
         //We will initialize a new set every time we want to check against the distance to any previous set
         Map<PreviousSetInformation, DistanceInformation> lastIteration = new HashMap<>();
         //For each node in the list (except the first node), calculate the distance to the starting node
         for(int x = 0; x < nodes.size(); x++) {
             PreviousSetInformation PSI = new PreviousSetInformation(
                 //Add a new empty set of previously evaluated nodes
                 new HashSet<Node>(),
                 //Add the current "last" node of this new set
                 nodes.get(x)
             );
             DistanceInformation DI = new DistanceInformation(
                 //Calculate the distance between the newly added node and the starting node
                 distance(nodes.get(x), firstNode),
                 //There is no second to last node since this is the first iteration
                 null
             );
             lastIteration.put(PSI,DI);
         }

         //For each node in the list, calculate the distance to the last node in the set before this
         for(int x = 1; x < nodes.size(); x++) {
             //Generate all sets of size x and store them in a list
             List<Set<Node>> setOfSizeX = generateAllSets(x, nodes);
             for(Set<Node> set : setOfSizeX) {
                 //Gather all possible nodes to add to each of the new sets
                 List<Node> nodesCopy = new ArrayList<>(nodes);
                 nodesCopy.removeAll(set);

                 //Go through the entire set and remove each node as the "last" node of the previous set
                 for(Node newNode : nodesCopy) {
                     //Find the minimum distance to each of the previous sets
                     double minDistance = Double.MAX_VALUE;
                     Node newSecondToLastNode = null;
                     //go through the set and change which node the "lastnode" is to determine the optimal "lastnode"
                     for(Node lastNode : set) {
                         HashSet<Node> oldClone = new HashSet<>(set);
                         oldClone.remove(lastNode);
                         //Get the old set information out of the hash map
                         PreviousSetInformation tempPSI = new PreviousSetInformation(oldClone, lastNode);
                         DistanceInformation lastDistanceInformation = lastIteration.get(tempPSI);
                            if(newNode.equals(lastNode)) {
                                System.out.println("fail");
                                System.exit(1);
                            }

                         double distanceToLastNode = distance(lastNode, newNode) + lastDistanceInformation.totalDistance;
                         if(distanceToLastNode < minDistance) {
                             minDistance = distanceToLastNode;
                             newSecondToLastNode = lastNode;
                         }
                     }
                     PreviousSetInformation newPSI = new PreviousSetInformation(set, newNode);
                     DistanceInformation newDistanceInformation = new DistanceInformation(minDistance, newSecondToLastNode);
                     lastIteration.put(newPSI, newDistanceInformation);
                 }
             }

         }

         //Cool! Now that we have ALL our optimal distances to the previous set of nodes, we can determine the optimal
         //set which returns back to the starting node
         double minDistance = Double.MAX_VALUE;
         Node newSecondToLastNode = null;
         for(Node n : nodes) {
             //Choose one node, n, to be the node that will be removed from the list. Go through each node n and
             //determine which "last node" optimally returns back to the start
             List<Node> nodesCopy = new ArrayList<>(nodes);
             nodesCopy.remove(n);
             //Get the old set information out of the hash map
             Set<Node> oldSet = new HashSet<>(nodesCopy);
             PreviousSetInformation tempPSI = new PreviousSetInformation(oldSet, n);
             DistanceInformation lastDistanceInformation = lastIteration.get(tempPSI);

             //Calculate the distance of the last set ending at each node, plus the distance to return back to the start
             double distanceToLastNode = distance(n, firstNode) + lastDistanceInformation.totalDistance;
             if(distanceToLastNode < minDistance) {
                 minDistance = distanceToLastNode;
                 newSecondToLastNode = n;
             }
         }
         System.out.println("The minimum distance to traverse each city once and return to the first node is: " + minDistance);

         //Now we calculate the optimal travel path to achieve the minimum distance by removing using the secondToLastNode
         //which is stored in the map
         List<Node> travelPath = new ArrayList<>();
         travelPath.add(firstNode);
         Node currLast = newSecondToLastNode;
         List<Node> nodesCopy = new ArrayList<>(nodes);
         while(!nodesCopy.isEmpty()) {
             travelPath.add(currLast);
             nodesCopy.remove(currLast);
             Set<Node> remainingNodes = new HashSet<>(nodesCopy);

             //Get the information out of the set
             PreviousSetInformation tempPSI = new PreviousSetInformation(remainingNodes, currLast);
             DistanceInformation lastDistanceInformation = lastIteration.get(tempPSI);
             currLast = lastDistanceInformation.secondToLastNode;
         }
         System.out.print("The optimal travel path to achieve the minimal distance is:");
         for(Node n : travelPath) {
             System.out.print(" " +n.id);
         }
         //Have to return to the start!
         System.out.println(" " +firstNode.id);

     }

    /**
     * Calculates the euclidean distance between two given nodes.
     * @param a the first node
     * @param b the second node
     * @return the euclidean distance between {@param a} and {@param b}.
     */
    public double distance(Node a, Node b) {
        double xCoordDifference = a.xCoord - b.xCoord;
        double yCoordDifference = a.yCoord - b.yCoord;
        return Math.sqrt(xCoordDifference*xCoordDifference + yCoordDifference*yCoordDifference);
    }


    /**
     * Generates a list of set permutations of a given size, given a list of nodes to choose from
     * @param size the target size of the resulting sets
     * @param nodes the list of all nodes to choose from
     * @return
     */
    public List<Set<Node>> generateAllSets(int size, List<Node> nodes) {
        List<Set<Node>> listOfAllSets = new ArrayList<>();
        try {
            generateAllSetsHelper(size, nodes, listOfAllSets, new HashSet<>(), 0);
        }
        catch(Exception e) {
            System.out.println("Your generation code failed.");
        }
        return listOfAllSets;
    }

    private void generateAllSetsHelper(
            int size,
            List<Node> nodes,
            List<Set<Node>> setsOfCorrectSize,
            Set<Node> currSet,
            int currPos) throws Exception {

        if(currSet.size() > size) {
            throw new Exception("You've generated a larger set than what has been requested");
        }
        if(currSet.size() == size) {
            setsOfCorrectSize.add(currSet);
        }
        else {
            for(int i = currPos; i < nodes.size(); i++) {
                Set<Node> newCurrSet = new HashSet<>(currSet);
                newCurrSet.add(nodes.get(i));
                generateAllSetsHelper(size, nodes, setsOfCorrectSize, newCurrSet, i+1);
            }
        }
    }
}
