function [fpath,vname,fps] = processVideo(XWindowSize=250, YWindowSize=160, 
  cropImageAtTime=10)
% PROCESSVIDEO
% Process a video into a series of bitmap images, saved in the same directory
% as the video file.

% Inputs:
%   XWindowSize = The horizontal video crop size (pixels) (int, default = 250)
%   YWindowSize = The vertical video crop size (pixels)   (int, default = 160)
%   cropImageAtTime = The time used to select a crop area (seconds) 
%                     (int, default=10)
%

%% ============================= LOAD VIDEO =============================== %%
% Load the video

fprintf('\nSelect a video to process.\n');
[fname, fpath, fltidx] = uigetfile('*.avi', 'Select a video to process.');

# Get video parameters
[~, vname, ext] = fileparts([fpath, fname]);
info = aviinfo([fpath fname]);
numFrames = info.NumFrames;
num_digits = numel(num2str(numFrames));
str_format = ['%0' num2str(num_digits) '.f'];
fps = info.FramesPerSecond;

% Process the first image to set a window for all subsequent images
cropImageAtTime = cropImageAtTime*info.FramesPerSecond;  
                     % Multiply seconds by fps to get frame number

image = aviread([fpath fname], cropImageAtTime);
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
mkdir(fpath, vname);

% Repeat the process for the other frames.  
for i = 1:numFrames
  try
    % Read in the frame from the video
    image = aviread([fpath fname], i);
    % Convert the image to greyscale
    bwimage = rgb2gray(image);
    % Crop the image based on the parameters determined from the first frame.
    img = bwimage(y1:y2,x1:x2);
    % Save the image to file as a bitmap
    imwrite(img, [fpath,vname,'/',vname,'_',num2str(i,str_format),'.bmp']);
    if mod(i,round(numFrames/100)) == 0
     fprintf('Processed %d%% of the video. \n', round(100*i/numFrames)); 
    endif
  catch
    fprintf('Unable to read frame %d.\n',i);
    return;
  end_try_catch
end 
toc;
fprintf('Video conversion complete. \n');
endfunction