function clear_xray_labels(axHandle)
%Clear labels in an xray_plot object
%
%Syntax
% clear_xray_labels(axHandle)
%
%Inputs
% axHande (Required) : handle to an xray_plot axes
%
%
%Examples
% plt1 = xray_plot('file1.msa');
% xray_peak_label(plt1)
% clear_xray_labels(plt1)
%
% See also
%  xray_peak_label, xray_plot, add_xray_plot, read_msa

% Copyright 2025 Austin M. Weber

% Find label objects
markers = findall(axHandle.Parent,'Type','Line');
textlabels = findall(axHandle.Parent,'Type','Text');
delete(markers)
delete(textlabels)

end