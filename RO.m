%s = [1 1 1 2 2 2 3 3 4 4 5 6 6 7 8 9 9 10 11 12 12]
%t = [4 11 8 5 3 10 9 14 11 5 6 7 12 8 9 10 13 14 12 13 14]
%weights = [1136 1702 2828 2349 596 789 366 385 683 959 573 732 1450 750 706 451 839 246 2049 1128 1976]

%NSF = graph(s, t, weights)
%NSF.Nodes.Number = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}'
%plot(NSF,'Layout', 'auto','EdgeLabel',NSF.Edges.Weight)

s = [1 1 2 2 3 3 4 5];
t = [2 6 6 3 5 4 5 6];
dist = [500 800 300 500 300 500 800 500];

traffic_matrix = [0 20 10 10 20 10; 
                  20 0 20 10 20 10;
                  10 20 0 20 10 0;
                  10 10 20 0 10 20;
                  20 20 10 10 0 20;
                  10 10 0 20 20 0;]


G = graph(s,t,dist)

plot(G,'Layout','auto','EdgeLabel',G.Edges.Weight)



routes = getRoutes(G)



function[OUTPUT] = firstFit(G, routes, matrix)

    for i = 1:size(routes,1) 
    end
end

function[ROUTES] = getRoutes(G)
    start = 1;
    
    for i = 1:height(G.Nodes)-1
     
        for j = i+1:height(G.Nodes)
            [path, dist, edgepath] = shortestpath(G,i,j);
            ROUTES{start,1} = path;
            ROUTES{start,2} = dist;
            ROUTES{start,3} = edgepath;
            start = start +1;
        end
    end
end


function[DISTANCES, PATHS] = kShortestPath(G,s,t,k) %yikes, tem problemas
    if(s == t)
        error("Source and Terminal nodes can't be the same")
    end
    [path, dist] = shortestpath(G,s,t) %get first shortest path and distance
    n = size(path, 2)
    PATHS{1} = path;
    DISTANCES(1) = dist;
    if (n == 2)
        tempG = rmedge(G,path(1,1),path(1,2))
        [currentPath, currentDist] = shortestpath(tempG,1,t)
        PATHS{2} = currentPath;
        DISTANCES(2) = currentDist;
    else
        for i = 2:k %get second to Kth shortest path
            if(i <= n-1) %n is the size of the shortest path. Num edges = n-1
            tempG = rmedge(G,path(1,i),path(1,i+1))
            [currentPath, currentDist] = shortestpath(tempG,s,t)
            PATHS{i} = currentPath;
            DISTANCES(i) = currentDist;
            else 
                break
            end
        end
    end
    %DISTANCES = sort(DISTANCES);
end


function[PATH, DISTANCE] = kShortestPath_wiki(G, s, t, k)
    
end



