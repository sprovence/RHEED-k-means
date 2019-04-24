% analyzeKMeans.m
% Process and visualize data files output by kmeans clustering
% Script for batch processing and plotting k-means data files

% Load the images package
pkg load image;
clear;

%% ============================ INPUT DATA ==================================%%
%%%%% Modify the following variables before running this file %%%%%

run = '041219_1 LCO-LAO Growth';     % The growth number and folder name in the data directory
write_dir = '../RHEED/k-means/';    % The output directory for the data.
displayImages = true;    % true indicates that images should be displayed next
                          % to the time plot of the cluster data.
fps = 2;                 % The number of frames per second in the image series.
SAVEAS = 'Cluster Plot.jpeg';  % The name of the output plots when they are
                                    % saved to the directory.
                          
%% ==========================================================================%%

%% ===================== READ K-MEANS TEXT FILES ============================%%

directory = [write_dir run "/"];

% Find all folders in the directory for the run that begin with k[x], where x
% is an integer
listing = dir(directory);
for i = 1:length(listing)
	if listing(i).isdir && strncmpi(listing(i).name,'k',1)
		folder = listing(i).name;
		knum = folder(2:end);
    % Find the filename of the k-means output text file.
		fname = ['k-means-' knum ' ' run '.txt'];
    % Read in the cluster as a structure with one field, times.
    kfolder = [directory, folder, '/'];
		cluster = readKMeans(fname, kfolder);
    clear("image");
    
    % If the images stored in the folder should be displayed, read in the images
    % and create a JxMXN array where J is the average image for cluster K and
    % M is the image height and N is the image width.
    if displayImages
      klisting = dir([kfolder '*.bmp']);
      
      % In order to sort by cluster number, convert klisting structure to cell
      % array and sort by row.
      Kfields = fieldnames(klisting);
      Kcell = struct2cell(klisting);
      
      sz = size(Kcell);
      % Transpose Kcell cell array to use sort by rows
      Kcell = Kcell';
      % Append a cell array of just cluster numbers (cast as numbers) to sort
      % the cell array by rows.
      clusterNums = cell2mat(regexp(Kcell(:,1),'\d*','Match'));
      clusterNums = cellfun(@str2num, clusterNums);
      clusterNums = num2cell(clusterNums);
      Kcell = [clusterNums Kcell];
      Kcell = sortrows(Kcell, 1);
      % Delete the additional column
      Kcell = Kcell(1:sz(2),2:sz(1)+1);
      % Transpose Kcell to convert it back to a structure
      Kcell = Kcell';
      % Convert the cell array back into a sorted structure
      klisting = cell2struct(Kcell, Kfields, 1);
      
      for j = 1:length(klisting)
        index = cluster(j).originalIndex;
        image(j,:,:) = imread([kfolder klisting(index).name]);
      endfor
      
      % Plot the clustering as a function of time with images.
      plotClusters(cluster, fps, image);
    else
      plotClusters(cluster, fps);
    endif
    
    K = length(cluster);
    saveas(gcf,[kfolder,"k",num2str(K)," ", SAVEAS]);
	endif	
endfor
