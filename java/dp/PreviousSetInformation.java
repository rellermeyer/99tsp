import java.util.Set;

/**
 * Created by lyee on 12/5/16.
 * To solve the TSP in DP, we need to store information regarding the previous sets of nodes which we have already
 * visited. In order to do this correctly, we cannot use a traditional 1-to-1 mapping that is available in the Java
 * Standard Library. Instead, we need to store our information elsewhere.
 */
public class PreviousSetInformation {
    Set<Node> set;
    Node lastNodeAdded;

    /**
     * Constructor for creating a new object to store in the hashset of previously visited sets of nodes
     * @param set The set of already evaluated nodes
     * @param lastNodeAdded The last node added to the set of already evaluated nodes does not exist within the set)
     */
    public PreviousSetInformation(Set<Node> set, Node lastNodeAdded) {
        this.set = set;
        this.lastNodeAdded = lastNodeAdded;
    }

    /**
     * Overrides the default hashCode() method for the purpose of gathering this object from a HashSet implementation.
     * @return the new hashCode of this object, dependant on its set of already evaulated nodes and the last node in the
     *      set that has been evaluated.
     */
    @Override
    public int hashCode() {
        return set.hashCode() + lastNodeAdded.hashCode();
    }

    /**
     * Overrides the default equals() method to check for equality in the same fashion of using the hashcode
     * @param o the other PreviousSetInformation object to compare to
     * @return true if the sets and the last node of the set that has been added are the same, and false otherwise.
     */
    @Override
    public boolean equals(Object o) {
        if(o instanceof PreviousSetInformation) {
            if(this.set.equals(((PreviousSetInformation)o).set)
                    && this.lastNodeAdded.equals(((PreviousSetInformation)o).lastNodeAdded)) {
                return true;
            }
        }
        return false;
    }
}
