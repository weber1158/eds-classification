function pixWidth = sem_pixel_size(image_file_name)
%Evaluates the pixel size of an SEM-generated .tif image
%
% SYNTAX
%  pixWidth = sem_pixel_size(image_file_name)
%
% NOTES
%  Computes the pixel size of a .tif image in units of microns/pixel. The
%  result is printed along with the units and stored in a variable. This
%  function is useful if you need to create a scale bar for the image.
%
%  DISCLAIMER: Only guaranteed to work on .tif images collected on either
%  the FEI Quanta 250 at SEMCAL or the Quattro SEM at CEMAS; it will not
%  work on general tagged image format files.
%
% EXAMPLE
%  img = 'imBSE.tif';
%  pw = sem_pixel_size(img)
%    The pixel size of imBSE.tif is 0.0674 μm/pixel.
%    pw = 
%     0.0674
%
% See also
%  get_sem_metadata

%  ©Austin M. Weber 2024


% Store input as a new variable name
imgName = image_file_name;

% Extract image info
Istruct = imfinfo(imgName);

% Extract character array of metadata
Imet = Istruct.UnknownTags.Value;

% Horizontal field width
hfw = extractBetween(Imet,"HFW=","VFW"); % Find value
hfw = cell2mat(hfw); % Convert from cell array to matrix
hfw = str2double(hfw); % Convert from string to double-precision (15 decimal places)
hfw = hfw*1e6; % Convert from units of meters to microns

% Number of pixels in the X direction
pixls = Istruct.Width;

% Evaluate pixel size
pixWidth= hfw/pixls;

% Print result
disp(['The pixel size of ' imgName ' is ' sprintf('%0.4f',pixWidth) ' μm/pixel.'])
end