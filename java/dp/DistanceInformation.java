
/**
 * Created by lyee on 12/5/16.
 * To solve the TSP in DP, we need to store information regarding the previous sets of nodes which we have already
 * visited. In order to do this correctly, we cannot use a traditional 1-to-1 mapping that is available in the Java
 * Standard Library. Instead, we need to store our information elsewhere.
 */
public class DistanceInformation {
    double totalDistance;
    Node secondToLastNode;

    /**
     * Constructor for creating a new object to store in the hashset of previously visited sets of nodes
     * @param totalDistance The minimum distance of the entire set, ending at the LastNodeAdded
     * @param secondToLastNode The index of the second to last node added to the set of previously existing nodes (for backtacking purposes)
     */
    public DistanceInformation(double totalDistance, Node secondToLastNode) {
        this.totalDistance = totalDistance;
        this.secondToLastNode = secondToLastNode;
    }
}
