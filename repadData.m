function X_pad = repadData(X, indices)
%REPAD Repads an array with zeros
%   X_pad = REPAD(X, indices) repads the matrix X with columns of zeros at the
%         locations specified by the array of indices.

[m,n] = size(X);

X_pad = X;

% Re-pad the columns with pixels that are 0.
for i = indices
  if (i == 1)
    X_pad = [zeros(m,1) X_pad];
  elseif (i == indices(end))
    X_pad = [X_pad zeros(m,1)];
  else
    X_pad = [X_pad(:,1:i-1) zeros(m,1) X_pad(:,i:end)];
  endif 
endfor

endfunction