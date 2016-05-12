import random, sys, gzip
class tour:
	def __init__(self):
		self.path = [None] * 1
		self.fit = 0
		self.travel = 0
		
	def mutate(self):
		a = random.randint(0, len(self.path)-1)
		b = random.randint(0, len(self.path)-1)
		
		temp = self.path[a]
		self.path[a] = self.path[b]
		self.path[b] = temp
	
	def blanktour(self, size):
		self.path = [None] * size
		return self.paths
		
	def newtour(self,tovisit):
		self.path = tovisit[:]
		random.shuffle(self.path)
		return self.path
		
	def setpath(self,update):
		self.path = update
		
	def tourlen(self):
		return len(self.path)
		
	def visits(self,city):
		return (city in self.path)
		
	def get(self,idx):
		return self.path[idx]
		
	def setspot(self, put, spot):
		self.path[spot] = put
		self.fit = 0
		self.travel = 0
	
	def getfit(self):
		if (self.fit == 0):
			self.fit = 1.0/self.getdist()
		return self.fit
	
	def getdist(self):
		if (self.travel == 0):
			self.calc()
		return self.travel
	
	def calc(self):
		tot = 0
		for i in range(len(self.path)-1):
			tot += self.path[i].distanceTo(self.path[i+1].index)
		self.travel = tot
		return tot
		
	def tostr(self):
		build = ""
		
		build = str ( map(maphelper3, self.path))
		return build
	
class vertex:
	def __init__(self, idx):
		self.name = "Austin"
		self.edges = {}
		self.index = idx
		self.pos = (0,0)
	
	def setpos(self, x, y):
		self.pos = (x,y)
	
	def setIndex(self, idxin):
		self.index = idxin
		
	def setName(self,namein):
		self.name = namein
		
	def addEdge(self, v, edge_weight):
		self.edges[v.getIdx()] = edge_weight
		# if symmetric
		v.edges[self.index] = edge_weight
		
	def distanceTo(self, otheridx):
		return self.edges[otheridx]
	
	def getIdx(self):
		return self.index

def maphelper(t):
	return t.getfit()

def maphelper2(t):
	return t.tostr()

def maphelper3(v):
	return int(v.name)

class pop:
	
	def __init__(self, initpopsize, initflag, cities):
		self.tours = [None] * initpopsize
		self.size = initpopsize
		self.popset = False
		if (initflag):
			for i in range(len(self.tours)):
				t = tour()
				debug = t.newtour(cities)
				self.tours[i] = t
	
	def get(self,index):
		return self.tours[index]
	
	def settour(self,index, tourtoset):
		self.tours[index] = tourtoset
	
	def popsize():
		return self.size
	
	def calc(self):
		self.popcorn = map( maphelper , self.tours)
		self.popset = True
		return self.popcorn
		
	def tostr(self):
		if (self.popset):
			return zip(map(maphelper2, self.tours), self.popcorn)
		else:
			return map(maphelper2, self.tours)
	
	def max_fit(self): # returns tuple of tour, fitness val
		if (not self.popset):
			self.calc()
			self.popset = True
		val = max(self.popcorn)
		return (self.tours[self.popcorn.index(val)], val)
	
	def getparent(self, subpopsize, cities):
		if ( self.popset):
			temp = random.randint(0, len(self.popcorn) - subpopsize)
			subpop = self.popcorn[temp:temp+subpopsize]
			return self.tours[ subpop.index(max(subpop)) + temp]
		else:
			temp = random.randint(0, len(self.tours) - subpopsize)
			subpop = pop(subpopsize, False, cities)
			subpop.tours = self.tours[temp:temp+subpopsize]
			subpop.calc()
			return subpop.max_fit()[0]
			
	
class gen:
	def __init__(self, mutationrate, gensize, tournamentsize, elitismflag, cities):
		self.rate = mutationrate
		self.poolsize = gensize
		self.tsize = tournamentsize
		self.eflag = elitismflag
		
		
		self.saved = cities
		
		self.pool = pop(gensize, True, cities)
	
	def evolve(self):
		nextpool = pop(self.poolsize, False, self.saved)
		start = 0
		
		if (self.eflag):
			elite = self.pool.max_fit()
			nextpool.settour(0, elite[0])
			start += 1
			
		# Crossover step
		for i in range(start, self.poolsize):
			tourA = self.pool.getparent(self.tsize, self.saved)
			tourB = self.pool.getparent(self.tsize, self.saved)
			nextpool.settour(i, self.cross(tourA,tourB))

		# Mutation step
		for m in nextpool.tours:
			if random.random() < self.rate:
				m.mutate()
		
		self.pool = nextpool
		
	
	def cross(self,tourA, tourB):
		apath = tourA.path
		bpath = tourB.path
		
		s = random.randint(0, len(apath))
		e = random.randint(s, len(apath))
		
		subb = [elem for elem in bpath if not(elem in apath[s:e])]
		
		
		child = subb[:s] + apath[s:e] + subb[s:]
		
		childtour = tour()
		childtour.setpath(child)
	
		return childtour

def distance(posa, posb):
	return ( (posb[1] - posa[1]) ** 2 + (posb[0] - posa[0]) ** 2 ) ** 0.5

def main():
	
	path =  sys.argv[1]
	
	# with gzip.open(path,'rb') as f:
	# 	file = f.readlines()
	
	file = open(path, 'r')
	
	counter = 0
	curr_cities = []
	for line in file:
		if ord(line[0]) >= 58 or ord(line[0]) <= 47 : 
			continue
		temp = line.strip().split()
		
		city = vertex(counter)
		city.setName(temp[0])
		city.setpos(float(temp[1]), float(temp[2]))
		
		for i in range(counter-1, -1, -1):
			city.addEdge( curr_cities[i] ,distance( city.pos, curr_cities[i].pos))
		
		curr_cities.append(city)
		counter += 1
		

	r = int(sys.argv[2])
	p = int(sys.argv[3])
	
	
	#  mutation rate, popsize, tourneysize, eliteflag, cities
	mr = float(sys.argv[4])
	ps = int(sys.argv[5])
	ts = int(sys.argv[6])
	
	
	ga = gen(mr, ps, ts, True, curr_cities)
	
	
	for i in range(r):
		ga.evolve()
		if i % p == 0:
			print "Best route at Generation", i
			macks =  ga.pool.max_fit()	
			print macks[0].tostr(),macks[1], macks[0].getdist()
			
	print "Best route at end" 
	macks =  ga.pool.max_fit()	
	print macks[0].tostr(), macks[0].getdist()
		

	# perfect = [1, 49, 32, 45, 19, 41, 8, 9, 10, 43, 33, 51, 11, 52, 14, 13, 47, 26, 27, 28, 12, 25, 4, 6, 15, 5, 24, 48 ,38, 37, 40, 39, 36, 35, 34, 44, 46, 16, 29, 50, 20, 23, 30, 2, 7, 42, 21, 17, 3, 18, 31, 22]
	# perf = tour()
	# perfpath= []
	# for i in perfect:
	# 	perfpath.append(curr_cities[i-1])
	
	# perf.setpath(perfpath)
	# print perf.getdist()
	# it was like just under 8000 for berlin test
	
main()