%cost of an edge
%data.travellingSalesmanProblemInstance.graph.vertex{1}.edge{1}.Attributes.cost;

%other node
%data.travellingSalesmanProblemInstance.graph.vertex{1}.edge{1}.Text;
function [cost] = MatlabGreedy(filename)
    %read XML file into a structure
    [data] = xml2struct(filename);
    [t,numnodes] = size(data.travellingSalesmanProblemInstance.graph.vertex);
    G = graph;

    i = 1;

    %add nodes to graph
    while i <= numnodes
        G = addnode(G,int2str(i));    
        i = i+1;
    end

    P = G;
    i = 1;

    %add weights
    while i <= numnodes
        str = int2str(i);
        j = 1;
        while j < numnodes
            node = data.travellingSalesmanProblemInstance.graph.vertex{i}.edge{j}.Text;
            node = int2str(str2num(node) + 1); %translate to start at index 1 to account for matlab
            weight = str2num(data.travellingSalesmanProblemInstance.graph.vertex{i}.edge{j}.Attributes.cost);

            if (findedge(G,str,node) == 0 && j ~= i) %if edge has not been added already
                G = addedge(G,str,node,weight);
            end

            j = j+1;
        end

        i = i+1;
    end

    %setting up travelling saleman vars
    i = 1; %initial starting point
    j = 1;
    str = int2str(i);
    weights = zeros(numnodes,1);
    nnodes = zeros(numnodes,1);
    visited = zeros(numnodes,1);
    visited(i) = 1; 
    done = false;
    cost = 0;

    disp('Path taken')
    disp(i)
    while(~done)

      %get neighbors
      while j <= numnodes
        str2 = int2str(j);
        if(findedge(G,str,str2) ~= 0)
            w = G.Edges.Weight(findedge(G,str,str2));
            weights(j) = w;
            nnodes(j) = j;
        end
        j = j+1;
      end 

      %remove weight 0 from missing edge between self and self
      [M,I] = min(weights);
      weights(I) = [];
      nnodes(I) = [];

      %find next nearest non visited neighbor
      nearest = false;
      while(~nearest)
        [M,I] = min(weights); %get minimum weight
        nei = nnodes(I);

        if(visited(nei) == 0) %if not visited
            nearest = true;        
            P = addedge(P,str,int2str(nei));
            visited(nei) = 1;
            cost = cost + G.Edges.Weight(findedge(G,str,int2str(nei)));
            str = int2str(nei);
            disp(nei);
        else %if visited, remove and try again
            weights(I) = [];
            nnodes(I) = [];
        end
      end

      %check if done
      if ~ismember(0,visited)
          done = true;
      end
    end

    %add final point 
    P = addedge(P,'1',int2str(nei));
    cost = cost + G.Edges.Weight(findedge(G,'1',int2str(nei)));
    plot(P)
end
