s = [1 1 1 2 2 2 3 3 4 4 5 6 6 7 8 9 9 10 11 12 12]
t = [4 11 8 5 3 10 9 14 11 5 6 7 12 8 9 10 13 14 12 13 14]
dist = [1136 1702 2828 2349 596 789 366 385 683 959 573 732 1450 750 706 451 839 246 2049 1128 1976]

traffic_matrix = ones(14,14)



%NSF = graph(s, t, weights)
%NSF.Nodes.Number = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}'
%plot(NSF,'Layout', 'auto','EdgeLabel',NSF.Edges.Weight)

%s = [1 1 2 2 3 3 4 5];
%t = [2 6 6 3 5 4 5 6];
%dist = [500 800 300 500 300 500 800 500];

%{
traffic_matrix = [0 20 10 10 20 10; 
                  20 0 20 10 20 10;
                  10 20 0 20 10 0;
                  10 10 20 0 10 20;
                  20 20 10 10 0 20;
                  10 10 0 20 20 0;] 
                  %}


G = graph(s,t,dist)


plot(G,'Layout','auto','EdgeLabel',G.Edges.Weight)


routes = getRoutes(G)


cenas = getLinks(G,[1 2 3 4])

firstFit(G,routes,traffic_matrix)

function OUTPUT = firstFit(G, routes, matrix)
    
    effective_routes = getEffectiveRoutes(G,routes,matrix);

    num_edges = height(G.Edges);
    allocated_lambdas = cell(num_edges,1);
    %for i=1:num_edges
    %    allocated_lambdas{i,1} = -1;  %start with -1 (no assigned wave lengths)
    %end
    
    possible_lambda = 1;
    for i = 1:size(effective_routes,1)
        this_links = getLinks(G, effective_routes{i,1});
        num_links = length(this_links);
        for index = 1:num_links
            link_index = this_links(index);
            lambdas = allocated_lambdas{link_index,1};
            if(isempty(lambdas))
                lambdas(end+1) = possible_lambda;
                allocated_lambdas{link_index,1} = lambdas; %allocate first wavelength if no wavelengths in link 
                path = effective_routes{i,1};
                OUTPUT{i,1} = path;
                OUTPUT{i,2} = possible_lambda;
                possible_lambda = 1;
            else
                while(ismember(possible_lambda,lambdas))
                    possible_lambda = possible_lambda + 1;
                end
                if(index < num_links) %check if this is not the last link in this path
                    bool = true;
                    while(bool)
                        if(~ismember(possible_lambda, allocated_lambdas{link_index,1}))
                            for j = index + 1 :num_links %check remaining links in path
                                if(ismember(possible_lambda,allocated_lambdas{this_links(j),1})) %if lambda is not available try again with next lambda
                                    possible_lambda = possible_lambda + 1;
                                    bool = true;
                                    break;
                                end
                                bool = false; %stop loop when possible lambda is available for every link in path
                            end
                        else %if this lambda exists in current link try next lambda
                            possible_lambda = possible_lambda + 1; 
                        end
                    end
                    lambdas(end+1) = possible_lambda; %insert the available lambda
                    allocated_lambdas{link_index,1} = lambdas; 
                    path = effective_routes{i,1};
                    OUTPUT{i,1} = path;
                    OUTPUT{i,2} = possible_lambda;
                else
                    if(~ismember(possible_lambda, allocated_lambdas{link_index,1}))
                        lambdas(end+1) = possible_lambda; %insert the available lambda
                        allocated_lambdas{link_index,1} = lambdas; 
                        path = effective_routes{i,1};
                        OUTPUT{i,1} = path;
                        OUTPUT{i,2} = possible_lambda;
                        possible_lambda = 1;
                        
                    end
                end
                
            end
        end
    end

end


function out = getEffectiveRoutes(G, routes, matrix)
 out = {}; %cell array with all routes wich have traffic and have a string conversion
    e_i = 0; %output cell row index
    for i = 1:size(routes,1) %iterate through all routes
        current_path = routes(i,1)
        path_array = cell2mat(current_path) %convert cell to array 

        if(pathHasTraffic(path_array, matrix)) %check if it has traffic
            e_i = e_i + 1
            %string = arrayToString(path_array) %comparable string
            out{e_i,1} = path_array 
            %effective_routes{e_i,2} = string
        end
    end
end

function out = getLinks(G, path) %returns an array of pointers to the edges of the path
    edges = G.Edges(:,1);
    out = [];
    i = 1;
    for node=1:length(path)-1
        %s = string(path(node)).append(string(path(node+1)))
        for edge=1:height(edges)
            array = table2array(edges(edge,:));
            if(ismember(path(node),array) && ismember(path(node+1),array)) %
                out(i) = edge;
                i = i +1;
            end
        end
    end
end



function ROUTES = getRoutes(G)
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


function output = pathHasTraffic(path, matrix)
    l = length(path);
    i = path(1);
    j = path(l);
    if(matrix(i,j) == 0)
        output = false;
    else
        output = true;
    end
end


function output = arrayToString(a)
    s = string(a);
    output = strjoin(s);
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
            [currentPath, currentDist] = shortestpath(tempG,i,t) %missing previous links in path
            PATHS{i} = currentPath;
            DISTANCES(i) = currentDist;
            else 
                break
            end
        end
    end
    %DISTANCES = sort(DISTANCES);
end






