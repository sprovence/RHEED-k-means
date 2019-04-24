function cluster = readKMeans(fname, directory)
% readKMeans(fname)
% Function for reading in K Means run text files.
% Input:
%		fname = the filename of the text file, must include '.txt'
% Output:
% 		cluster = a structure array containing a field, times, that 
% 				  indicates the times that have been grouped to the structure
% 				  index. As the cluster has been sorted chronologically, it also has
%           a field, originalIndex, that indicates the original cluster number
%           it was put into. 

fid = fopen([directory fname],'r');
formatSpec = '%s';

% Read in the header data
% Throw out the first line
tline = fgets(fid);
% Second line read K
tline = fgets(fid);
K = str2num(tline(end-1));
% Throw out the third line, the directory of the video files
tline = fgets(fid);

% Read in the rest of the data as filenames and cluster numbers
data = textscan(fid, formatSpec);
data = cell2mat(data);

% Find the index of cluster headings in the cell array
clusterIndex = cellfun(@(x) strfind(x,'Cluster'), data, ...
	'UniformOutput', false);
clusterIndex = find(not(cellfun('isempty', clusterIndex)));
% Add one to each index since the line will split to the next line
clusterIndex = clusterIndex + 1;
K = length(clusterIndex);

% Create an array that contains the index of cells in the cell array that 
% contain the file ending, .bmp
bmpFiles = cellfun(@(x) strfind(x, '.bmp'), data, 'UniformOutput', false);
bmpFiles = find(not(cellfun('isempty', bmpFiles)));

% Initialize an array to store the start times for each cluster
startTimeIndexed = [];

for i = 1:K
	% For each cluster, extract the times
	clusterNumber = data{clusterIndex(i)};
	clusterNumber = str2num(clusterNumber(1:end-1));
  
  % Find the indices of the correct line in data in each cluster and store it
  % in bmpFilesinCluster
	if i ~= K
    bmpFilesinCluster = bmpFiles(bmpFiles > clusterIndex(i) & ...
      bmpFiles < clusterIndex(i+1));
	else
    bmpFilesinCluster = bmpFiles(bmpFiles > clusterIndex(i));
	end
  
  if ~isempty(bmpFilesinCluster)
    % Shorten the data cell array into only the relevant lines
    shortData = data(bmpFilesinCluster);
    % Stringsplit each line of the shortData to find the number between the
    % _ and .
	  splitArray = cell2mat(cellfun(@(x) strsplit(x,{'_','.'}), shortData, ...
      'UniformOutput', false));
	  times = splitArray(:,end-1);
	  times = cellfun('str2num',times);
	  times = sort(times);
	else
    times = 0;
  endif
  
  startTimeIndexed = [startTimeIndexed min(times)];
	% Store the sorted time indices in a structure array, cluster
	unsorted_cluster(i).times = times;
end

% Close the text file.
fclose(fid);

% Sort the clusters in chronological order
startTimeSorted = sort(startTimeIndexed);
empties = find(startTimeSorted == 0);
if ~isempty(empties)
  startTimeSorted = circshift(startTimeSorted, -1*length(empties));
end

multipleZeros = 1;
for i = 1:K
  clusterOrder = find(startTimeSorted(i) == startTimeIndexed);
  cluster(i).originalIndex = clusterOrder(multipleZeros);
  
  if startTimeSorted(i) ~= 0    
    cluster(i).times = unsorted_cluster(clusterOrder).times;    
  else
    cluster(i).times = [];
    multipleZeros = multipleZeros + 1;
  end
endfor


end