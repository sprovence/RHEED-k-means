function [x1 x2 y1 y2] = getWindow(image, xwindow, ywindow)
%GETWINDOW finds the correct boundary of a RHEED image for subsequent cropping.
%   [x1 x2 y1 y2] = getWindow(image) returns the boundaries of the window of the
%                   relevant RHEED pattern. The function makes an initial guess
%                   at the location of the window, but asks the user to confirm.
%   Inputs:
%         image = a uint8 greyscale image matrix
%         xwindow = The width of the window in pixels (int)
%         ywindow = The height of the window in pixels (int)
%
%   Outputs:
%         x1 = The lower x boundary of the image
%         x2 = The upper x boundary of the image
%         y1 = The lower y boundary of the image
%         y2 = The upper y boundary of the image

pkg load signal;

if nargin < 2
  xwindow = 125;
  ywindow = 80;
endif

% Initialize
[im_height,im_width] = size(image);

% Find the maximum pixel value in the image
maxval = max(max(image));

% Calculate the marginals in the x- and y-directions (sum of intensity values
% across a row or column) for the initial window guess.
xmarginal = sum(image,1);
ymarginal = sum(image,2);

% Find the peaks of the RHEED streaks in the image from the x marginal
% In order to determine the n = 0 RHEED streak, assume it will be the x
% marginals curve with the greatest degree of symmetry. Define the symmetry
% to be the point from which if the function were mirrored around an axis  
% defined by that point, it would have the lowest residual sum of squares value
% compared to mirroring it around any other point on the curve.

% Calculate the mirrored RSS for each point.
rss = rssMirror(xmarginal);

% Find the minimum RSS value and define that point as the n = 0 RHEED spot in
% the x-direction.
[~, minrss] = min(rss);

% Use the RHEED intensity to find the n = 1 RHEED peaks.
[xpks, xloc] = findpeaks(xmarginal,"MinPeakDistance",10);
numpks = length(xpks);

% Define the 0th order RHEED peak as the peak closest to the RSS minimum.
[~, centeridx] = min(abs(xloc - minrss));
xn0 = xloc(centeridx);

% Have the user confirm that the correct peak was found
figure(2,"name","Select the center of the RHEED pattern.","pointer", ...
  "crosshair","position",[100 200 1200 900]);
imshow(image);
hold on;
line([xn0 xn0],[0 im_height],"color","g","LineWidth",1);
correct = yes_or_no("\nIs the line correctly centered across the RHEED pattern?\n");
while ~correct
  fprintf("Select the central point of the RHEED pattern.\n"); 
  if ~isfigure(2)
    figure(2,"name","Select the center of the RHEED pattern.", "pointer", ...
      "crosshair", "position",[300 200 1200 900]);
    imshow(image);
    hold on;
    line([xn0 xn0],[0 im_height],"color","g","LineWidth",1);
  endif
  [x,y,~] = ginput(1);
  hold off;
  imshow(image);
  hold on;
  xn0 = round(x);
  line([xn0 xn0],[0 im_height],"color","g","LineWidth",1);
  correct = yes_or_no("Is this line correctly centered across the RHEED pattern?\n"); 
    if correct
      % Re-define the center index if a new central point is point
      [~, centeridx] = min(abs(xloc - xn0));
    endif
endwhile
close(2);

% Find the y-locations of the peaks of the RHEED streaks corresponding to the
% x-peaks.
ypks = zeros(1,numpks);
yloc = zeros(1,numpks);
for i = 1:numpks
  [ypks(1,i),yloc(1,i)] = max(image(:,xloc(i)));
endfor

% Find the maximum y-peaks and set that as a lower bound. First check the 0th
% order spot, and see if either of the peaks to either side are greater. If so,
% keep iterating left and right to find a lower peak. If a local maximum is 
% found, then set that as a lower bound -- do not attempt to find a global 
% maximum, as it could be a Kikuchi line.
ymax = yloc(1,centeridx);
yidx = centeridx;
oneMoreIter = true;
while oneMoreIter == true;
if yidx ~= 1 && yidx ~= length(yloc)
  if ymax < yloc(1,yidx - 1) && ymax < yloc(1,yidx + 1)
    [ymax,in] = max([yloc(1,yidx - 1),yloc(1,yidx + 1)]);
    if in == 1
      yidx = yidx - 1;
    elseif in == 2
      yidx = yidx + 1;
    endif
    oneMoreIter = true;
  else
    oneMoreIter = false;
  endif
  oneMoreIter = false;
else
  oneMoreIter = false;
endif
endwhile

% Setup conditions so that the window must be part of the image, and can't go
% off one edge.
if ymax < ywindow
  ymax = ywindow + 1;
endif
if ymax + ywindow > im_height
  ymax = im_height - ywindow;
endif
if xn0 < xwindow
  xn0 = xwindow + 1;
endif
if xn0 + xwindow > im_width
  xn0 = im_width - xwindow;
endif

% Have the user confirm that the correct peak was found
figure(2,"name","Select the center of the RHEED pattern.", "pointer", ...
  "crosshair", "position",[300 200 1200 900]);
imshow(image);
hold on;
rectangle("Position",[( xn0 - xwindow ), ( ymax - ywindow ), ...
  2*xwindow, 2*ywindow],"EdgeColor",[0, 0, 1]);
line([0 im_width],[ymax ymax],"color","g","LineWidth",1);
correct = yes_or_no("\nIs the window for the RHEED pattern correctly centered along the vertical axis?\n");
while ~correct
  fprintf("Select the center for the vertical axis.\n"); 
  if ~isfigure(2)
    figure(2,"name","Select the center of the RHEED pattern.", "pointer", ...
      "crosshair", "position",[300 200 1200 900]);
    imshow(image);
    hold on;
    rectangle("Position",[( xn0 - xwindow ), ( ymax - ywindow ), ...
      2*xwindow, 2*ywindow],"EdgeColor",[0, 0, 1]);
    line([0 im_width],[ymax ymax],"color","g","LineWidth",1);
  endif
  [x,y,~] = ginput(1);
  hold off;
  imshow(image);
  hold on;
  ymax = round(y);
  rectangle("Position",[( xn0 - xwindow ), (ymax - ywindow), ...
    2*xwindow, 2*ywindow],"EdgeColor",[0, 1, 0]);
  line([0 im_width],[ymax ymax],"color","g","LineWidth",1);
  correct = yes_or_no("Is this window correctly centered across the RHEED pattern?\n"); 
endwhile
close(2);

% Calculate the output values.
x1 = xn0 - xwindow;
x2 = xn0 + xwindow;
y1 = ymax - ywindow;
y2 = ymax + ywindow;