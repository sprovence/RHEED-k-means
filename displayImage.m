function displayImage(colVec,row,col)
  % DISPLAYIMAGE Display a 2D greyscale bitmap image
  % displayImage(colVec, row, col) takes a column vector representing a 
  %   greyscale image and re-wraps it back into a matrix and then displays it.
  % Inputs:
  %     colVec = a 1D array of pixel intensity values
  %     row = the number of row pixels in the original image
  %     col = the number of column pixels in the original image
  % Outputs:
  %    <none>
  
  % Reformat the column array
  image = uint8(reshape(colVec, row, col));
  
  imagesc(image);
  colorbar;
endfunction
