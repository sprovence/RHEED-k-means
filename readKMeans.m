function cluster = readKMeans(fname, directory)
% readKMeans(fname)
% Function for reading in K Means run text files.
% Input:
%		fname = the filename of the text file, must include '.txt'
%   directory = the directory in which the text file resides
% Output:
%   cluster = a structure array containing a field, times, that 
% 				  indicates the times that have been grouped to the structure
% 				  index. As the cluster has been sorted chronologically, it also has
%           a field, originalIndex, that indicates the original cluster number
%           it was put into. Note that times is actually the frame number, which
%           may not be the same as the actual time (must be divided by fps)

fid = fopen([directory fname],'r');
formatSpec = '%s\n';

% Read in the header data
% Throw out the first line
tline = fgets(fid);
% Second line read K
tline = fgets(fid);

% Read in the rest of the data as filenames and cluster numbers
data = textscan(fid, formatSpec, 'Delimiter', {'\n','\r'});
data = cell2mat(data);

% Find the index of cluster headings in the cell array
clusterIndex = cellfun(@(x) strfind(x,'Cluster'), data, ...
	'UniformOutput', false);
clusterIndex = find(not(cellfun('isempty', clusterIndex)));
% Check to see if textscan split the cluster number to the next line (the
% number will be in front of a colon)
if isempty(strfind(data{clusterIndex(1)},':'))
% Add one to each index since the line will split to the next line
  clusterIndex = clusterIndex + 1;
end

K = length(clusterIndex);

% Create an array that contains the index of cells in the cell array that 
% contain the file ending, .bmp
bmpFiles = cellfun(@(x) strfind(x, '.bmp') || strfind(x, '.BMP'), data, ...
  'UniformOutput', false);
bmpFiles = find(not(cellfun('isempty', bmpFiles)));

% Initialize an array to store the start times for each cluster
startTimeIndexed = [];

for i = 1:K
	% For each cluster, extract the times
  if clusterIndex(i) <= length(data)
	  clusterNumber = data{clusterIndex(i)};
    if ~isempty(strfind(clusterNumber, ' '))
	    clusterNumber = str2num(clusterNumber(strfind(clusterNumber,' '):end-1));
    else
      clusterNumber = str2num(clusterNumber(1:end-1));
    endif
    
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
      if length(shortData) > 1
  	    splitArray = cell2mat(cellfun(@(x) strsplit(x,{'_','.'}), shortData(1:end-1), ...
          'UniformOutput', false));
      elseif length(shortData) == 1
          splitArray = strsplit(shortData{1}, {'_','.'});
      end
        
  	  times = splitArray(:,end-1);
  	  times = cellfun('str2num',times);
  	  times = sort(times);
  	else
      times = 0;
    endif
  
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