Imports System.Math
Imports System.IO

'Jordan Torres (jxt59)
'Hw 6
'Visual Basic Greedy algorithm.

Module ModuleGreedy
    Class GraphNode
        Public id As Integer
        Public x As Integer
        Public y As Integer
        Sub New(ByVal n1 As Integer, n2 As Integer, w As Integer)
            x = n1
            y = n2
            id = w
        End Sub
    End Class

    'return the closest node to the current node and adds the distance to a reference double
    Function closestNode(ByVal current As GraphNode, remainingNodes As List(Of GraphNode), ByRef totalPath As Double) As GraphNode
        Dim closest As GraphNode = remainingNodes.Item(0)
        If remainingNodes.Count = 1 Then
            totalPath += (Sqrt((Abs(closest.x - current.x) ^ 2) + (Abs(closest.y - current.y) ^ 2)))
            Return closest
        End If
        For i = 1 To remainingNodes.Count - 1
            If (Sqrt((Abs(closest.x - current.x) ^ 2) + (Abs(closest.y - current.y) ^ 2))) > (Sqrt((Abs(remainingNodes.Item(i).x - current.x) ^ 2) + (Abs(remainingNodes.Item(i).y - current.y) ^ 2))) Then
                closest = remainingNodes.Item(i)
            End If
        Next
        totalPath += (Sqrt((Abs(closest.x - current.x) ^ 2) + (Abs(closest.y - current.y) ^ 2)))
        Return closest
    End Function


    Sub Main()
        Console.WriteLine("hello world greedy")
        Dim list = New List(Of GraphNode)()
        'Populating our list of graph nodes by reading from the input file
        Dim EnteredCoordSection As Boolean = False
        For Each line As String In File.ReadLines("../../a280.tsp")
            If Not EnteredCoordSection Then
                If line.Contains("NODE_COORD_SECTION") Then
                    EnteredCoordSection = True
                End If
            ElseIf Not line.Contains("EOF") Then
                Dim pieces As Array = line.Trim().Split({" "}, StringSplitOptions.RemoveEmptyEntries)
                list.Add(New GraphNode(CInt(pieces(0)), CInt(pieces(2)), CInt(pieces(0))))
            End If
        Next
        Console.WriteLine("size of graph in nodes: " & list.Count)

        Dim nodesRemaining = list
        Dim resultString As String = ""
        Dim currentNode As GraphNode = list.Item(0)
        Dim firstNode As GraphNode = currentNode
        'Adding the first node to the path by default as the first node in the file.
        nodesRemaining.Remove(currentNode)
        resultString = resultString & currentNode.id

        'A loop that executes once for each node in the graph. Building the TSP solution path.
        'We calculate the closest node to our current node and travel there. Then it is removed from the remaining nodes.
        'The cost of the path is also being summed.
        Dim pathDistance As Double = 0.0
        Dim i As Integer = 0
        While nodesRemaining.Count <> 0
            currentNode = closestNode(currentNode, nodesRemaining, pathDistance)
            nodesRemaining.Remove(currentNode)
            resultString = resultString & ", " & currentNode.id
            i = i + 1
        End While
        pathDistance += (Sqrt((Abs(firstNode.x - currentNode.x) ^ 2) + (Abs(firstNode.y - currentNode.y) ^ 2)))
        currentNode = firstNode
        resultString = resultString & ", " & currentNode.id
        'Output the final path
        Console.WriteLine(resultString)
        Console.WriteLine("Total path distance: " & pathDistance)
        While True
            'stop the program from finishing until it is executed.
        End While
    End Sub

End Module
