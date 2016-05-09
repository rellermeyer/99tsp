
#Name: Shuoyi Yang
#UTEID: sy6955
	
#CS 345
#Greed algorithm for TSP.
	
	
	#reading data from the input path
	read.data<-function(){
	filepath = readline("Enter data file:")	
	data = read.table(filepath,skip =6, header=FALSE,nrow=length(readLines(filepath))-7)
	return(data)
	}
	
	#calculate the euclidean distance between two node
	distance <- function(x1,x2){
		return (sqrt(sum((x1-x2)^2)))
	}
	
	
	#find the nearest node from the remaining list
	get.nearest<- function(remain.nodes,current){
		i = 0
		shortest.dist = 0
		min  = c()
		current=current[2:3]
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
	
	
	#find the shortest path for any start point
	any.start.shortest.path<-function(data){
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
			remain.nodes = remain.nodes[-next.node[1],]
			total.dist = total.dist + next.node[3]
			}
		if(total.dist < min.total.dist){
			min.total.dist = total.dist
			best.result = visit.nodes[,1]
			}
		}
		print(paste("minimum distance:",min.total.dist))
		print(best.result)
	}
	
	#find the shortest path from node 1
	shortest.path<-function(data){
		first.node = data[1,]
		remain.nodes = data[-1,]
		total.dist = 0
		visit.nodes=first.node
			while(nrow(remain.nodes)>0) {
			current = tail(visit.nodes,n=1)		
			next.node = get.nearest(remain.nodes,current) 
			visit.nodes = rbind(visit.nodes,data[next.node[2],])			
			remain.nodes = remain.nodes[-next.node[1],]
			total.dist = total.dist + next.node[3]
			}
		print(paste("minimum distance :",total.dist))
		print(visit.nodes[,1])
	}
	
	#main function
	main<-function(){
	shortest.path(read.data())
	#any.start.shortest.path(read.data())
	}
	
   
   if(interactive()) main()
