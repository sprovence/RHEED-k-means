% main.m
% Main script for PCA/K-means analysis of RHEED .avi videos. Automates the video
% decomposition, PCA, k-means, and analysis scripts into one file.

% Load packages and clear the workspace
pkg load image;
pkg load video;
clear;

%% ============================ INPUT DATA ==================================%%
%%%%% Modify the following variables before running this file %%%%%

% Note that the file must be in .avi format
XWindowSize = 20;                         % in pixels (default = 250)
YWindowSize = 10;                         % in pixels (default = 160)
cropImageAtTime = 10;                      % in seconds (default = 10)

D = 5;                 % The reduced dimension of the problem after running PCA.
NUM_CLUSTERS = 5;      % The maximum number of clusters k-means will run

SAVEAS = 'sample';     % The name of the output plots when they are
                       % saved to the directory.
displayImages = true;  % true indicates that images should be displayed next
                       % to the time plot of the cluster data.

%% ==========================================================================%%

# Run the automated video frame decomposition script to crop images.
[video_directory, run, fps] = processVideo(XWindowSize,YWindowSize,cropImageAtTime);

# Determine the output directory for k-means data.
mkdir(video_directory,'k-means'); 
output_directory = [video_directory,'k-means\'];

# Run PCA and k-means clustering.
kmeans(run, video_directory, output_directory, fps, D, NUM_CLUSTERS);

# Plot the PCA and k-means data
analyzeKMeans(run, output_directory, fps, SAVEAS, displayImages);