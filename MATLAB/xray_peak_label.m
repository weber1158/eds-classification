function xray_peak_label(axHandle,prominence,x_tolerance)
%Label most prominent peaks in an xray_plot
%
%Syntax
% xray_peak_label(axHandle)
% xray_peak_label(axHandle,prominence)
% xray_peak_label(axHandle,prominence,x_tolerance)
%
%Inputs
% axHandle : axes handle to an open xray_plot object
% prominence : (Optional, default=90) percentile between 0 and 100 that
%  specifies the minimum prominence of the x-ray peaks to be labeled.
% x_tolerance : (Optional, default=0.025) the energy value corresponding 
%  to a peak in an EDS spectrum is unlikely to exactly match the literature 
%  value for the element, so a tolerance in x must be defined. Tolerance 
%  must be in units of keV. 
%
%Examples
% data = read_msa('file1.msa');
% plt = xray_plot(data);
% xray_peak_label(plt)
%
% % Label the peaks above the 95th percentile in height
% xray_peak_label(plt,95)
%
% See also
%  xray_plot, read_msa

% Copyright ©Austin M. Weber 2024

keV = axHandle.XData;
Counts = axHandle.YData;
min_sep = 0.1;

% Delete any pre-existing labels
points = findobj(gca,'Type','Line');
labels = findobj(gca,'Type','Text');
delete(points);
delete(labels);

% Check whether prominence was specified
if ~exist('prominence','var') % i.e., if the user does not specify a prominence
	% Evaluate the 90th-percentile cutoff point for determining local maxima
	prominence = prctile(Counts,90);
	% Find local maxima
	[local_maxima_energies,idx] = evaluate_local_maxima(keV,Counts,min_sep,prominence);

else % i.e., the user specifies a prominence
	user_prominence = prctile(Counts,prominence);
	[local_maxima_energies,idx] = evaluate_local_maxima(keV,Counts,min_sep,user_prominence);
end

% Check whether x_tolerance was specified
if nargin == 3
   % If true, is x_tolerance defined correctly?
   if ~isa(x_tolerance,'double')
	   error('The ''x_tolerance'' input must be numeric (default=0.025).')
   end
   if x_tolerance < 0
	   error('The ''x_tolerance'' input must be greater than zero (default=0.025).')
   end
else
   % Set x_tolerance
   x_tolerance = 0.0250;
end

% Import x-ray energy table
energies = readtable('XrayEnergyTable.csv','Delimiter','comma',...
    'ReadVariableNames',true,'VariableNamingRule','preserve');
element_names = energies.Element; % 95x1 cell
energy_vals = energies{:,3:end}; % 95x8 double

%
% Identify the elements that most likely correspond to the local maxima
%
% Energy values corresponding to peaks
peak_energies = keV(idx); % [1xN] double

% Delete peak energies less than 0.025 keV
low_energies = peak_energies <= 0.025;
peak_energies(low_energies) = []; 

% Number of peaks
number_of_peaks = length(peak_energies);

% Preallocate memory for labels
peak_labels = cell(number_of_peaks,1); % [1xN] cell

% Loop through peaks to identify elements
for peak = 1:number_of_peaks
 % Engergies likely won't match the expected energy exactly, so check for
 % matches within a range:
  lowerBound = peak_energies(peak) - x_tolerance;
  upperBound = peak_energies(peak) + x_tolerance;
 % Match index matrix
  match_matrix = energy_vals >= lowerBound & energy_vals <= upperBound;
 % Get list of all matching elements (i.e., rows containing true values)
  row_idx = logical(sum(match_matrix,2));
  element_list = element_names(row_idx);
 % Define labels
  if numel(element_list) == 0
    peak_labels(peak) = {" ?"};
  elseif numel(element_list) == 1
    peak_labels(peak) = {join([" " element_list])};
  else
    label = element_list{1};
    for L = 2:length(element_list)
     label = join([label "," element_list{L}]);
    end
    peak_labels(peak) = {join([" [" label "]"])};
  end
end

% Add data to plot
hold('on')
	% Label prominent peaks with red markers
	plot(local_maxima_energies.keV,local_maxima_energies.Counts,...
        'sr','MarkerSize',3,...
        'HandleVisibility','off')
	% Add labels for the most likely element classification
	for n = 1:number_of_peaks
		text(local_maxima_energies.keV(n),...
		     local_maxima_energies.Counts(n),...
			 peak_labels(n),...
			'HorizontalAlignment','left',...
			'VerticalAlignment','middle',...
			'Rotation',90)
	end
hold('off')
% End main function body
end

%
% LOCAL FUNCTIONS
%
function [local_maxima_energies,localMax] = evaluate_local_maxima(keV,Counts,min_sep,prominence)
	% Find local maxima
	localMax = islocalmax(Counts,'MinSeparation',min_sep,'SamplePoints',keV,'MinProminence',prominence);
	x_max = keV(localMax);
	y_max = Counts(localMax);
	% Delete any values less than 0.025 keV
	energy_idx = x_max <= 0.025;
	x_max(energy_idx) = [];
	y_max(energy_idx) = [];
	% Create table of local maxima energies
	local_maxima_energies = array2table([x_max',y_max'],...
	                           'VariableNames',{'keV','Counts'});
end