function [X, im_height, im_width, num_bmp_files, num_files, idxbmp, files] ...
   = loadImages(directory)
%% ============================= LOAD IMAGES =============================== %%
% Load the images in a single matrix X. 
% Only load greyscale bitmap files - tifs are too large.
%findfiles( ...
%  'C:/Users/sydne/Documents/Auburn Postdoc Comes Lab/RHEED Images/', ...
%  '*.bmp');
    
% Load the entire directory of processed images into the X data matrix
files = readdir(directory);
num_files = length(files);

% idx is a logical array which reads true for bitmap files in the directory
file_idx = cell2mat( cellfun(@(x) ~isempty(strfind(x,'.bmp')), files, ...
  'UniformOutput', false) );
% idxbmp contains the index values of bitmap files in 'files'
idxbmp = find(file_idx);
num_bmp_files = length(idxbmp);
  
% Read the first image from the directory into Octave
img = imread([directory files{idxbmp(1)}]);
  
% Initialize the X data matrix
[im_height,im_width] = size(img);
X = zeros(num_bmp_files,im_width*im_height);
  
% Save some time, go ahead and store the first image.
X(1,:) = img(:);
  
for i = 2:num_bmp_files
  % Read each processed image in and store it in X
  img = imread([directory files{idxbmp(i)}]);
  X(i,:) = img(:);
endfor
