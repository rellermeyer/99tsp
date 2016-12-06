package tspsa


type Route struct {
	R []Node			// Routes
	D float64 			// distance
}

/*
 * Swap the Nodes in the Route for the given 2 positions
 *
 * n1: Node1 index
 * n2: Node2 index
 */
func (r *Route) SwapNodes(n1 int, n2 int) {
	t1 := r.R[n1]
	t2 := r.R[n2]
	r.R[n1] = t2
	r.R[n2] = t1
}

/*
 * Return the number of Nodes in the route
 * return: (int)
 */
func (r *Route) Nodes() int {
	return len(r.R)
}

/*
 * Calculate the total route distance for the traveling salesman and return the float value
 * return: Route Distance (float64)
 */
func (r *Route) CalcDistance() float64 {
	td := 0.0
	for i := 0; i < r.Nodes(); i++ {
		s := r.R[i]
		var e Node
		if i+1 < r.Nodes() {
			e = r.R[i+1]
		} else {
			e = r.R[0]
		}
		td += s.GetEuDistance(&e)
	}
	r.D = td
	return r.D
}
/*
 * String function for the Route Struct
 */
func (r *Route) String() string {
	t := ""
	for i := 0; i < r.Nodes(); i++ {
		t += r.R[i].String()
	}
	return t
}