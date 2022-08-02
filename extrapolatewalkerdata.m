%% Extrapolate walker data
% This script extrapolates point light walker data.
% Background: Create motion files with different artiuclation speeds
clear all;

origin_directory = pwd;
FID = fopen('sample_walker3.txt');    %open walker data file
walker_array = fscanf(FID,'%f');      %read into matlab
fclose(FID);
walker_array=reshape(walker_array,3,[]).*0.00001;  %order and scale walker array

nt = length(walker_array);
t = 1:99;
texp = 1:0.8:99.4; %adapt the stepsize from 1 to 99 to determine whether walkers should articulate slowlier (<1) or faster (>1).
for i = 1:16 %this loop linearly extrapolates walker data
    xtemp = walker_array(1, i:16:nt);
    xexp = interp1(t, xtemp, texp, 'linear', 'extrap');
    x{i} = xexp(:);
    
    ytemp = walker_array(2, i:16:nt);
    yexp = interp1(t, ytemp, texp, 'linear', 'extrap');
    y{i} = yexp(:);
    
    ztemp = walker_array(3, i:16:nt);
    zexp = interp1(t, ztemp, texp, 'linear', 'extrap');
    z{i} = zexp(:);   
end
% safe all extrapolated data in data matrix
x = [x{:}];
y = [y{:}];
z = [z{:}];

% Reorganise data: this loop selects every row and adds it as coloumns: [A(1,:) A(2,:) A(3,:)]
for i = 1:size(texp,2)    
 xrow = [x(i,:)];
 xnew{i} = xrow(:);
 yrow = [y(i,:)];
 ynew{i} = yrow(:);
 zrow = [z(i,:)];
 znew{i} = zrow(:); 
end

% Get all the data and reshape them
xnew = [xnew{:}];
xnew = reshape(xnew,1,[]); %this reshapes the original and extrapolated data into the right order and format.
ynew = [ynew{:}];
ynew = reshape(ynew,1,[]);
znew = [znew{:}];
znew = reshape(znew,1,[]);

% Final reshape and export.
data = [xnew; ynew; znew]; %this is the format of the reshaped walker_array. 
sample_walker_exp = reshape(data,[],1); %same format as sample_walker3 text file.

% export extrapolated data to text file:
writematrix(sample_walker_exp, 'sample_walker_exp_0.8.txt')
