function intensities = peak_intensity(data)
%Peak intensity of each mineral-forming element in an EDS spectrum
%
%SYNTAX
% intensities = PEAK_INTENSITY(data)
%
%INPUT
% data {table} :: A table of EDS data with columns labeled "Energy" and
%                 "Counts". The "Energy" data must be in units of keV.
%
%OUTPUT
% intensities {table} :: A table of elemental peak intensities that can be
%                        used as the first input argument for the
%                        "eds_classification" function.
%
%
%EXAMPLE
% filename = 'phenom_berea.emsa';
% data = subtract_background(filename);
% peakInt = PEAK_INTENSITY(data);
% mineral = eds_classification(peakInt)
%
%
%See also
% net_intensity, subtract_background, msa_classification

% Copyright 2026 Austin M. Weber

% Define list of mineral-forming elements
elements = {'F','Na','Mg','Al','Si','P','S','Cl',...
            'K','Ca','Ti','Cr','Mn','Fe'};

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

% Find the index positions in data.Energy that are closest to each energy
keV = data.Energy;
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