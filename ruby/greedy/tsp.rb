require 'set'

Edge = Struct.new(:u, :v, :w)
Node = Struct.new(:x, :y, :n)

def greedy(nodes, start)
  solution = [start]

  remaining = Set.new(nodes.keys)
  remaining.delete(start)

  u = start

  while remaining.length > 0
    best = nil
    best_cost = nil

    remaining.each do |v|
      tmp = dist(nodes[u], nodes[v])
      if best == nil or tmp < best_cost
        best = v
        best_cost = tmp
      end 
    end

    remaining.delete(best)
    u = best
    solution.push(u)
  end

  solution.push(start)

  return solution
end

def dist(a, b)
  return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
end

def main()
  nodes = {}

  STDIN.each_with_index do |line, idx|
    line_split = line.split()
    begin
      line_split.map! { |x| Integer(x) }
      tmp = Node.new
      tmp.n, tmp.x, tmp.y = line_split
      nodes[tmp.n] = tmp
    rescue
    end
  end

  total = 0

  solution = greedy(nodes, 1)

  1.upto(solution.length-1) do |i|
    u = nodes[solution[i-1]]
    v = nodes[solution[i]]
    total += Math.sqrt(dist(u, v))
  end

  puts "Path: "
  puts solution
  puts "Path Cost: "
  puts total
end

main()
