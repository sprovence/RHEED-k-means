function analyzeKMeans(run, write_dir, fps, SAVEAS, displayImages = true)
% ANALYZEKMEANS Process and visualize data files output by kmeans clustering
% Function processes and plots k-means output data files
%
% Inputs:
%   run = The growth number and folder name in the main directory (string)
%   write_dir = The output directory for the data. (string)
%   fps = The number of frames per second of the exported .avi video 
%         (int, default=2)
%   SAVEAS = The name of the output plots when they are saved to the write 
%            directory (string)
%   displayImages = % Boolean, true indicates that images should be displayed
%                     next to the time plot of the cluster data. (default=true)

%% ===================== READ K-MEANS TEXT FILES ============================%%

directory = [write_dir run '\'];

% Find the number of clusters through the number of k folders in the directory
kfolders = dir([directory,'k*']);
kfolders = [kfolders.isdir];
NUM_CLUSTERS = nnz(kfolders);

% Visualize the mean cluster images saved in each cluster folder.
for K = 1:NUM_CLUSTERS
  for i = 1:K
    cluster_dir = [directory, 'k', num2str(K), '\'];
    % Load the .mat cluster image file, the matlab variable is called 'image'
    load([cluster_dir 'cluster', num2str(i), '.mat']);
    im_name = ['cluster', num2str(i)];
    imwrite(image, [cluster_dir, im_name, '.bmp'], 'bmp');
  endfor
endfor

% Find all folders in the directory for the run that begin with k[x], where x
% is an integer
line = [];
listing = dir(directory);
for i = 1:length(listing)
	if listing(i).isdir && strncmpi(listing(i).name,'k',1)
		folder = listing(i).name;
		knum = folder(2:end);
    % Find the filename of the k-means output text file.
		fname = ['k-means-' knum ' ' run '.txt'];
    % Read in the cluster as a structure with one field, times.
    kfolder = [directory, folder, '\'];
		cluster = readKMeans(fname, kfolder);
    clear('image');
    
    % Extract the beginning and end times for the cluster
    for k = 1:length(cluster)
        if ~isempty(cluster(k).times)
          line = [line, cluster(k).times(1), cluster(k).times(end)];
        else
          line = [line, NA, NA];
        endif  
    endfor
    
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
    saveas(gcf,[kfolder,'k',num2str(K),' ', SAVEAS, ' Cluster Plot.jpeg']);
	endif	
endfor

% Append the line of cluster start/end times to the .csv file.      
try 
    csvname = [directory, run, '_ClusterTimes.csv'];
    dlmwrite(csvname, line);
catch
    warning('Error in writing to file.\n');
end

endfunction