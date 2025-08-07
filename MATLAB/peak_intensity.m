function intensities = peak_intensity(data)
%Evaluates the peak intensities for each mineral-forming element in an EDS
%spectrum
%
%Syntax
% PEAK_INTENSITY(data)
% intensities = PEAK_INTENSITY(data)
%
%
%Input
% data (Required) :: {Table} An EDS data table produced with the read_msa()
%                            and/or the subtract_background() function
%
%
%Output
% intensities :: {Table} Peak intensity table for the mineral-forming elements
%
%
%Example
% filename = 'file1.msa';
% data = read_msa(filename);
% data_bs = subtract_background(data);
% peakInt = PEAK_INTENSITY(data_bs);
% mineral = donarummo_classification(peakInt);
%
%
%See also
% read_msa, subtract_background

% Copyright 2025 Austin M. Weber

% Define list of elements
elements = {'F','Na','Mg','Al','Si','P','S','Cl','K','Ca','Ti','Cr','Mn','Fe'};

% Define keV for each mineral-forming element (K-alpha):
energies = [0.6768
            1.04098 
            1.2536
            1.4867
            1.73998
            2.0137
            2.30784
            2.62239
            3.3138
            3.69168
            4.51084
            5.41472
            5.89875
            6.40384]';

% Find the index positions in data.keV that are closest to each energy
keV = data.keV;
idx = zeros(size(energies));
for k = 1:length(idx)
  i = find(round(energies(k),2) == round(keV,2),1);
  idx(k) = i;
end

% Evaluate the peak intensity at each index position
counts = data.Counts;
intensities = zeros(size(energies));
for j = 1:length(intensities)
  intensity = counts(idx(j));
  intensities(j) = intensity;
end

% Convert into a table
intensities = array2table(intensities,'VariableNames',elements);

end