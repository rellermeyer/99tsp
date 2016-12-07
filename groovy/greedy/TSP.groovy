/**
 * Tirey Morris (tam3354)
 * CS 345 (Rellermeyer)
 * December 5th, 2016
 */

class TSP {

    static final BigDecimal MAX = BigDecimal.valueOf(Double.MAX_VALUE)

    static void main(String... args) {
        if (args.size() < 1 || !args[0].endsWith(".xml")) {
            throw new IllegalArgumentException("Must provide .xml input file")
        }

        def graph = parseGraph(new File(args[0]))
        def results = solve(graph)
        println("path = ${results[0]}\n\ntotal cost = ${results[1]}")
    }

    static parseGraph(File xmlFile) {
        def tspXml = new XmlParser().parse(xmlFile)
        def graph = tspXml.graph.vertex
    }

    static getNodes(graph) {
        def nodes = [:]
        graph.eachWithIndex { vertex, i -> 
            nodes[i] =  vertex.edge
        }
        nodes
    }

    static Integer getNumFromEdge(edge) {
        edge.value().text().toInteger()
    }

    static BigDecimal getCostFromEdge(edge) {
        new BigDecimal(edge.attributes().get("cost"))
    }

    static List solve(graph) {
        def nodes = getNodes(graph)
        def path = []
        def total = 0
        int start = 0
        int current = 0

        while (nodes.size() > 0) {
            path << current
            def edges = nodes[current]
            nodes.remove(current)

            def min = MAX

            edges.each { edge -> 
                Integer num = getNumFromEdge(edge)
                BigDecimal cost = getCostFromEdge(edge)

                if (cost < min && nodes[num]) {
                    min = cost
                    current = num
                }
            }

            if (min != MAX) {
                total += min
            }

            if (nodes.size() == 1) {
                edges.each { edge -> 
                    Integer num = getNumFromEdge(edge)
                    BigDecimal cost = getCostFromEdge(edge)

                    if (num == start) {
                        total += cost
                    }

                }
            }
        }

        path << start

        [path, total]
    }
}