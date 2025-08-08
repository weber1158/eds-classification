function xray_peak_label_best(axHandle,prominence,x_tolerance)
%Label peaks in an xray_plot with the most likely ("best") element

% Copyright ©Austin M. Weber 2025

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
element_Zs = energies.Z; % 95x1 double
energy_vals = energies{:,3:end}; % 95x8 double

% Loop through peaks
peak_positions = find(idx);
num_peaks = length(peak_positions);
no_double_label=0; % Preallocate
current_atomic_number = 1; % Preallocate
for peak = 1:num_peaks
 if no_double_label==peak
	continue
 end
 nth_peak_energy = keV(peak_positions(peak));
 % Find elements that may be associated with that peak
 lowerBound = nth_peak_energy - x_tolerance;
 upperBound = nth_peak_energy + x_tolerance;
 % Match index matrix
 match_matrix = energy_vals >= lowerBound & energy_vals <= upperBound;
 % Get list of all matching elements (i.e., rows containing true values)
 row_idx = logical(sum(match_matrix,2));
 element_list = element_names(row_idx);
 if peak == num_peaks
	% Label the peak as the first element in the element list
	hold('on')
	% Add red marker to peak
	plot_red_marker(local_maxima_energies,peak)
	% Add label to peak
	if ~isempty(element_list)
	plot_element_label(local_maxima_energies,peak,element_list{1})
	hold('off')
	end
 else
	% Loop through the remaining peaks to check their element lists
	for n=(peak+1):num_peaks
 	% Get the list of elements for the n+nth peak
 	n_plus_nth_peak_energy = keV(peak_positions(n));
 	lB = n_plus_nth_peak_energy - x_tolerance;
 	uB = n_plus_nth_peak_energy + x_tolerance;
 	mM = energy_vals >= lB & energy_vals <= uB;
 	rI = logical(sum(mM,2));
 	eL = element_names(rI);
	% Delete the elements whose atomic numbers are less than the atomic
	% number of the most recent element
	atomic_numbers = element_Zs(rI);
	atomic_numbers_too_low_index = atomic_numbers > current_atomic_number;
	eL(atomic_numbers_too_low_index) = [];
 		% Compare this list to the list for the nth peak
 		element_match = contains(element_list,eL);
 		if any(element_match)
			% Label the nth peak as that element
			nth_label = element_list{element_match};
			hold('on')
	 		% Add red marker to peak
     		plot_red_marker(local_maxima_energies,peak)
	 		% Add label to peak
	 		plot_element_label(local_maxima_energies,peak,nth_label)

			% Label the n+nth peak as that element
	 		% Add red marker to peak
	 		plot_red_marker(local_maxima_energies,n)
	 		% Add label to peak
	 		plot_element_label(local_maxima_energies,n,nth_label)
			hold('off')

			% Adjust no_double_label index number so that the main for-loop
			% will skip the n+nth peak (because it has already been labeled)
			no_double_label=n;

			% Adjust current_atomic_number
			current_atomic_number = find(strcmp(element_names,nth_label));

		else
			% Check if final iteration
			if n == num_peaks
				% Check if element is known
				if isempty(element_list)
					element_list = {'?'};
				end
				% Label the peak as the first element in the element list
				hold('on')
				% Add red marker to peak
				plot_red_marker(local_maxima_energies,peak)
				% Add label to peak
				plot_element_label(local_maxima_energies,peak,element_list{1})
				hold('off')
			end
 		end
	end
 end
end

% End main function body
end

%
% LOCAL FUNCTIONS
%
function [local_maxima_energies,localMax] = ...
			evaluate_local_maxima(keV,Counts,min_sep,prominence)
	% Find local maxima
	localMax = islocalmax(Counts,...
		                  'MinSeparation',min_sep,...
						  'SamplePoints',keV,...
						  'MinProminence',prominence);
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
function plot_red_marker(energy_table,index)
	plot(energy_table.keV(index),energy_table.Counts(index),...
		'sr','MarkerSize',3,...
		'HandleVisibility','off')
end
function plot_element_label(energy_table,index,label)
	text(energy_table.keV(index),...
 		energy_table.Counts(index),...
 		label,...
		'HorizontalAlignment','center',...
		'VerticalAlignment','bottom')
end