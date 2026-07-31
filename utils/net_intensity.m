function net = net_intensity(data,width)
%Net intensity of each mineral-forming element in an EDS spectrum
%
%DESCRIPTION
% Uses a trapezoidal sum approximation to "integrate" the areas beneath
% the curve for each mineral-forming element's known characteristic x-ray
% energies. The output of this function is similar to the output obtained
% with peak_intensity(data), but, because net intensities consider the 
% total number of counts for each element rather than the number of counts
% at the peak maxima, net_intensity(data) is, in principle, a better
% approximation of each element's relative intensity in an EDS spectrum.
%
%
%SYNTAX
% net = NET_INTENSITY(data)
% net = NET_INTETNSITY(data,width)
%
%INPUT
% data {table}   :: A table of EDS data with columns labeled "Energy" and
%                   "Counts". The "Energy" data must be in units of keV.
% width {double} :: (Optional) The width of the integration area in keV.
%                   Default=0.15 keV
%
%OUTPUT
% net {table}    :: A table of elemental net intensities that can be used
%                   as the first input argument for the eds_classification
%                   function.
%
%
%EXAMPLE
% filename = 'phenom_berea.emsa';
% data = subtract_background(filename);
% net = NET_INTENSITY(data);
% mineral = eds_classification(net)
%
%See also
% peak_intensity, subtract_background, msa_classification

%Copyright 2026 Austin M. Weber

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

% Define data variables
keV = data.Energy;
counts = data.Counts;
if nargin < 2 || isempty(width)
  width = 0.15; % keV
end

% Find the index positions in data.Energy that are closest to each energy
intensities = zeros(size(energies));
for k = 1:length(energies)
  % Define energy bin
  e_0 = energies(k);
  lower_e = e_0 - width/2;
  upper_e = e_0 + width/2;

  % Define bin index
  integration_window_idx = keV >= lower_e & keV <= upper_e;
  if nnz(integration_window_idx) < 2
    intensities(k) = NaN; % Not enough points to integrate
    continue
  end

  % Integrate the areas under the peaks
  netCounts = counts(integration_window_idx);
  netCounts(netCounts < 0) = 0;
  intensities(k) = trapz(keV(integration_window_idx), netCounts);
end

% Convert into a table
net = array2table(intensities,'VariableNames',elements);

end