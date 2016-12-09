/**
 * Created by lyee on 12/5/16.
 *
 * The Node class helps store the X and Y coordinates for each of our cities.
 */
public class Node {
    double xCoord;
    double yCoord;
    String id;

    public Node(String index, String x, String y) {
        id = index;
        xCoord = Double.parseDouble(x);
        yCoord = Double.parseDouble(y);
    }
}
