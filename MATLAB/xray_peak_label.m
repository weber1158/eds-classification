function xray_peak_label(axHandle,prominence,x_tolerance,algorithm)
%Label peaks in an EDS spectrum
%
%Syntax
% xray_peak_label(axHandle)
% xray_peak_label(axHandle,prominence)
% xray_peak_label(axHandle,prominence,x_tolerance)
% xray_peak_label(axHandle,prominence,x_tolerance,algorithm)
% xray_peak_label(axHandle,algorithm)
%
%Inputs
% axHande (Required) : handle to an xray_plot axes
% prominence (Optional) : minimum prominence of peaks to be labeled. Must
%                         be a percentile between 1 and 99. Default=90
% x_tolerance (Optional) : the +/- energy range used to identify elements
%                          relative to the energy of each peak. Must be in
%                          units of keV. Default=0.025
% algorithm (Optional) : the labeling algorithm. Default='best'. The other
%                        options are 'all' which labels each peak with all
%                        of the possible elements, and 'first' which labels
%                        each peak with the first possible element.
%
%
%Examples
% plt1 = xray_plot('file1.msa');
% xray_peak_label(plt1)
%
% plt2 = xray_plot('file2.msa');
% xray_peak_label(plt2,95,0.027,'all')
%
% See also
%  clear_xray_labels, xray_plot, add_xray_plot, read_msa

% Copyright 2025 Austin M. Weber

% Parse user inputs
num_inputs = nargin;
if num_inputs < 1
	error('The function ''xray_peak_label'' requires at least one input.')
end

if num_inputs < 2
	prominence = 90;
end

if num_inputs == 2
	if ~isa(prominence,'double')
		if isa(prominence,'char')
			algorithm = prominence;
			prominence = 90;
		elseif isa(prominence,'string')
			algorithm = char(prominence);
			prominence = 90;
		else
			error('Second input must be a numeric value between 1 and 99 (which sets the prominence parameter). The second input may also be the name of the labeling algorithm (i.e., ''best'' or ''all'').')
		end
	end
end

if num_inputs < 3
	x_tolerance = 0.025;
end

if num_inputs == 4
	if isempty(prominence)
		prominence = 90;
	end
	if isempty(x_tolerance)
		x_tolerance = 0.025;
	end
	if ~isa(algorithm,'char')
		if ~isa(algorithm,'string')
			error('Fourth input must be a string. Try ''best'' or ''all''.')
		end
	end
end

if ~exist('algorithm','var')
	algorithm = 'best';
end

% Delete any previous scatter points
objects = findall(axHandle.Parent.Parent);
markers = findobj(objects,'Type','Line');
if numel(markers) > 0
 delete(markers)
end

% Apply labeling algorithm to the figure
switch lower(algorithm)
	case 'best'
		xray_peak_label_best(axHandle,prominence,x_tolerance) % See the \private\ folder
	case 'all'
		xray_peak_label_all(axHandle,prominence,x_tolerance) % See the \private\ folder
	case 'first'
		xray_peak_label_first(axHandle,prominence,x_tolerance) % See the \private\ folder
	otherwise
		error('Algorithm parameter not recognized. Try ''best'' or ''all''.')
end

% End main function
end