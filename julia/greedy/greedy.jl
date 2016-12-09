
function distance(x,y)
    return sqrt((x[1] - y[1])^2  + (x[2] - y[2])^2)
end

function read_data()
    try
        count = 0
        g = Dict()
        for line in eachline(STDIN)
            cur = split(strip(line))
            if !in(cur[1], Set(["NAME", "COMMENT", "TYPE", "DIMENSION:",
                                "EDGE_WEIGHT_TYPE", "NODE_COORD_SECTION", "EOF"]))
                g[cur[1]] = [[parse(Int,cur[2]), parse(Int,cur[3])], Any[]]
                count += 1
            end
        end
        for i in keys(g)
            for j in keys(g)
                if i != j
                    dist = distance(g[i][1], g[j][1])
                    push!(g[i][2], (dist, j))
                end
            end
        end
        for i in keys(g)
            sort!(g[i][2], lt=(x,y)->isless(x[1],y[1]))
        end
        return (count, g)
    catch err
        showerror(STDOUT, err, backtrace())
        return (0, Dict())
    end
end


function tsp(g, n)
    cur = "1"
    seen = Set()
    path = []
    count = 0
    dist = 0
    show = false
    for i in 1:n-1
        push!(seen, cur)
        push!(path, cur)
        count += 1
        d, cur = get_nearest_unseen(g[cur][2], seen, count, n)
        dist += d
        show = false
    end
    println(dist)
    println(path)
end


function get_nearest_unseen(ls, seen, num_seen, n)
    for entry in ls
        if  num_seen == n - 1 && entry[2] == "1"
            return entry
        elseif !in(entry[2], seen)
            return  entry
        end
    end
    println("EXITED")
    exit(1)
end


function main()
    n, graph = read_data()
    tsp(graph, n)
end


main()
