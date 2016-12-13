% file format :: (node_num,x_coord,y_coord)
% matrix node # will be denoted by matrix row 

function [lat,long,numCities] = parse_to_map(filename)

    % need to ignore the first 6 lines %
    fprintf('Currently parsing input file to generate TSP map. \n');
    [~, n_l_s] = system(['grep -c ".$" ' filename]);
    n_lines = str2double(n_l_s) - 7; 
    nCities = n_lines; % note :: problem scales O(n^2)

    fid = fopen(filename);
    % skip first 6 lines
    for k = 1:1:6
        tline = fgets(fid);
    end
    % read values from here
    formatSpec = '%d %d %d';
    sizeA = [3 nCities+1];
    A = fscanf(fid,formatSpec,sizeA);
    A = A';
    fclose(fid);

    %%%%%%%%% code above this can be put into a parsing method %%

    cities = A(:,1)';
    citiesLon = A(:,2)';
    citiesLat = A(:,3)';

    lat = citiesLat;
    long = citiesLon;
    numCities = nCities;

end
