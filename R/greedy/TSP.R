"""
Name: Shuoyi Yang
UTEID: sy6955

CS 345
Greed algorithm for TSP.

"""

#reading from the input path
filepath = "a280.tsp"
data = read.table(filepath,skip =6, header=FALSE,nrow=length(readLines(filepath))-7)


#calculate the euclidean distance between two node
distance <- function(x1,x2){
	return (sqrt(sum((x1-x2)^2)))
}


#find the nearest node from the remaining list
get.nearest<- function(remain.nodes,current){
	i = 0
	shortest.dist = 0
	min  = c()
	current=current[2:3]
	rec = numeric(nrow(remain.nodes))
	id = remain.nodes[,1]
	cor = remain.nodes[,2:3]
	for(i in 1:nrow(remain.nodes)){
		#store the distance of nodes into a vector
		cur.dist = distance(current,cor[i,])
		min = rbind(min,c(i,id[i],cur.dist))
	}
	min.node = min[which.min(min[,3]),]
	return (min.node)
}


#get the list of nodeId and minimum distance by greedy algorithm
min.total.dist = 0
best.result = c()
for (i in 1:nrow(data)){
	total.dist = 0
	visit.nodes = c()
	current = data[i,]
	visit.nodes = current
	#remain.nodes = subset(data,V1!=i)
	remain.nodes = data[-i,]
	
	while(nrow(remain.nodes)>0) {
		current = tail(visit.nodes,n=1)		
		next.node = get.nearest(remain.nodes,current) 
		visit.nodes = rbind(visit.nodes,data[next.node[2],])			
		#remain.nodes = subset(remain.nodes,V1!=next.node[1])
		remain.nodes = remain.nodes[-next.node[1],]
		total.dist = total.dist + next.node[3]
	}
	
	if(total.dist < min.total.dist){
		min.total.dist = total.dist
		best.result = remain.nodes[,1]
	}

}

print(min.total.dist)
print(best.result)

