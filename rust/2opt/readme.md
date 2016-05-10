#TSP implementation in Rust using 2opt
######Note: Passing the flag -printarray to this implementation will print the solution formatted as an array instead of just listing the nodes one by one. The flag is currently commented out in the Makefile in this director.

Check the source file (2opt.rs) for detailed explanations of the implementation.

2opt is an approximate algorithm and does not give the optimal solution every time. 

For example: when run on a280.tsp if the algorithm starts from the first node (index 0) then it's solution is 2756.788 units long. Whereas if it starts from the second node (index 1) then it's solution is 2727.229 units long.

P.S. If you want to use the makefile in this director (/rust/2opt) then you'll have to comment out the 'include ../Rules.mk'
