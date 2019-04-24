% processVideo.m
% Process a video into a series of bitmap images
% Script for batch processing bitmap images of RHEED screen

% Load the images package and clear the workspace
pkg load image;
pkg load video;
clear;

%% ============================ INPUT DATA ==================================%%
%%%%% Modify the following variables before running this file %%%%%

% Note that the file must be in .avi format
vname = '041219_1 LCO-LAO Growth';
directory = ...
    'C:/Users/sydne/Documents/Auburn Postdoc Comes Lab/RHEED Video/';
XWindowSize = 300;                         % in pixels (default = 250)
YWindowSize = 150;                         % in pixels (default = 160)
cropImageAtTime = 60;                      % in seconds (default = 10)

%% ==========================================================================%%

%% ============================= LOAD VIDEO =============================== %%
% Load the video

fprintf('\nLoading the video into Octave.\n');

info = aviinfo([directory vname ".avi"]);
numFrames = info.NumFrames;

% Process the first image to set a window for all subsequent images
cropImageAtTime = cropImageAtTime*info.FramesPerSecond;  
                     % Multiply seconds by fps to get frame number

image = aviread([directory vname ".avi"], cropImageAtTime);
bwimage = rgb2gray(image);

% Get the boundaries of the image to crop. Ignore the last 20 pixels as that is
% the scroll window and not part of the RHEED screen.
XWindowSize = round(XWindowSize/2);
YWindowSize = round(YWindowSize/2);
[x1 x2 y1 y2] = getWindow(bwimage(1:end-20,1:end-20), XWindowSize, YWindowSize);
% Crop the image
tic;
img = bwimage(y1:y2,x1:x2);
[im_height,im_width] = size(img);

% Make a new directory for the processed images named after the filename and 
% save the image to the directory
mkdir(directory, vname);
imwrite(img, [directory vname "/" vname "_1.bmp"]);

% Repeat the process for the other frames.  
for i = 2:numFrames
  % Read in the frame from the video
  image = aviread([directory vname ".avi"], i);
  % Convert the image to greyscale
  bwimage = rgb2gray(image);
  % Crop the image based on the parameters determined from the first frame.
  img = bwimage(y1:y2,x1:x2);
  % Save the image to file as a bitmap
  imwrite(img, [directory vname "/" vname "_" num2str(i) ".bmp"]);
  if mod(i,round(numFrames/100)) == 0
    fprintf("Processed %d%% of the video. \n", round(100*i/numFrames)); 
  endif
end 
toc;
fprintf("Video conversion complete. \n");