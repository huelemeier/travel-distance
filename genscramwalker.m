function [scram_walker_array]=genscramwalker(walker_array,npoints)

%walker y dims    
max_height=max(walker_array(2,:));
min_height=min(walker_array(2,:));

%walker x dims
max_width=max(walker_array(1,:));
min_width=min(walker_array(1,:));

% get start of each frame
getpointsframes = 1:npoints:length(walker_array-npoints);

% empty position variable
randpos=zeros(2,npoints);

% make scrambled walker variable
scram_walker_array = zeros(size(walker_array));

%generate random positions for each point

for index = 1:npoints
   
    max_for_point_x = max(walker_array(1,getpointsframes+(index-1)));   
    min_for_point_x = min(walker_array(1,getpointsframes+(index-1)));
 
    max_for_point_y = max(walker_array(2,getpointsframes+(index-1)));    
    min_for_point_y = min(walker_array(2,getpointsframes+(index-1)));
    
    maxpossible_x = max_width-max_for_point_x;
    minpossible_x = min_width-min_for_point_x;
            
    maxpossible_y = max_height-max_for_point_y;
    minpossible_y = min_height-min_for_point_y;
    
    randpos(1,index) = (maxpossible_x-minpossible_x).*rand()+minpossible_x;
    randpos(2,index) = (maxpossible_y-minpossible_y).*rand()+minpossible_y;
    
    scram_walker_array(1:2,getpointsframes+(index-1))=[walker_array(1,getpointsframes+(index-1))+randpos(1,index);walker_array(2,getpointsframes+(index-1))+randpos(2,index)];
    
end
    
scram_walker_array(3,:)=walker_array(3,:);

end
    
    
    
  
