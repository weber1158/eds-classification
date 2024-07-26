function xray_peak_label(axHandle,prominence)
%Label most prominent peaks in an xray_plot
%
%Syntax
% xray_peak_label(axHandle)
% xray_peak_label(axHandle,prominence)
%
%Inputs
% axHandle : axes handle to an open xray_plot object
% prominence : (Optional, default=90) percentile between 0 and 100 that
%  specifies the minimum prominence of he x-rary peaks to be labeled.
%
% xray_peak_label(axHandle) adds labels to characteristic x-ray peaks in
%   the chart with the axes handle 'figHandle'
%
%Examples
% data = read_msa('file1.msa');
% plt = xray_plot(data);
% xray_peak_label(plt)
%
% % Label the peaks above the 95th percentile in size
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

if ~exist('prominence','var') % i.e., if the user does not specify a prominence
	% Evaluate the 90th-percentile cutoff point for determining local maxima
	prominence = prctile(Counts,90);
	% Find local maxima
	[local_maxima_energies,idx] = evaluate_local_maxima(keV,Counts,min_sep,prominence);

else % i.e., the user specifies a prominence
	user_prominence = prctile(Counts,prominence);
	[local_maxima_energies,idx] = evaluate_local_maxima(keV,Counts,min_sep,user_prominence);
end

% Estiamte the elements for each local maximum
energies = readtable('XrayEnergyTable.txt','Delimiter','tab',...
	'NumHeaderLines',1,'LeadingDelimitersRule','ignore');
energies(:,3) = [];
vars = {'Z','Element','Ka1','Ka2','Kb','La1','La2','Lb1','Lb2','Lg1'};
energies.Properties.VariableNames = vars;
% Extract energies in keV and save as a matrix
energies_vals = energies{:,3:end};

% Identify the elements that most likely correspond to the local maxima
Z_idx = keV(idx);
% Delete values less than 0.025 keV
i = Z_idx <= 0.025;
Z_idx(i) = []; 
% Create a table of most likely elements
Z_table = zeros(length(Z_idx),1);
Z_table = num2cell(Z_table);
for k = 1:length(Z_idx)
	zmin = Z_idx(k) - 0.0175;
	zmax = Z_idx(k) + 0.0175;
	z_all = energies_vals >= zmin & energies_vals <=zmax;
	z_sum = logical(sum(z_all,2));
	e_idx = energies{z_sum,2};
	if length(e_idx) < 1
		e_idx = "?";
	end
	Z_table{k} = string(e_idx(1));
end
elements = Z_table;

% Add data to plot
hold('on')
	% Label prominent peaks with red markers
	plot(local_maxima_energies.keV,local_maxima_energies.Counts,...
        'sr','MarkerSize',3,...
        'HandleVisibility','off')
	% Add labels for the most likely element classification
	for n = 1:numel(elements)
		text(local_maxima_energies.keV(n),local_maxima_energies.Counts(n),elements(n),...
			'HorizontalAlignment','center',...
			'VerticalAlignment','bottom',...
			'FontName','Calibri')
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
	local_maxima_energies = array2table([x_max',y_max'],'VariableNames',{'keV','Counts'});
end