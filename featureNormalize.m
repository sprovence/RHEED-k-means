function [X_norm, mu, sigma] = featureNormalize(X)
%FEATURENORMALIZE Normalizes the features in X 
%   FEATURENORMALIZE(X) returns a normalized version of X where
%   the mean value of each feature is 0 and the standard deviation
%   is 1. 

% Subtract the mean of each pixel/feature from each column
mu = mean(X);
X_norm = bsxfun(@minus, X, mu);

% Divide each pixel/feature by the standard deviation across each feature.
% sigma = std(X_norm);
% Instead of using the standard deviation, just divide each feature by 255
sigma = 255;
% If the standard deviation is zero, replace it with some small noise (1E-10)
% so that no error is encountered for dividing by zero. Likely, the normalized
% feature will come out to zero as well.
% Note: This can be avoided by just trimming the matrix of features that are all
%       zero using the trimData(X) function. 
%zip = find(sigma == 0);
%sigma(1,zip) = 1E-10;

X_norm = bsxfun(@rdivide, X_norm, sigma);


% ============================================================

end