function axHandle = xray_plot(data)
%Takes a table of EDS data generated with the read_msa()
%function and plots a visualization.
%
%Syntax
% axHandle = XRAY_PLOT(data)
% axHandle = XRAY_PLOT(filename)
%
%Inputs
% data : table produced by the read_msa() function
% filename : (string) name of EMSA file including .msa extension
%
%Output
% axHandle : axes handle for editing the plot after compilation
%
%Examples
% data = read_msa('file1.msa');
% plt = XRAY_PLOT(data);
%
% % Or,
% plt = XRAY_PLOT('file1.msa');
%
%
% See also
%  add_xray_plot, xray_peak_label, clear_xray_labels, read_msa

% Copyright ©Austin M. Weber 2025


%
% Function body begins here
%
if isstring(data) || ischar(data)
	% User input was a .msa file name
	axHandle = localplotfunction(read_msa(data));
	plotDetails(axHandle)
elseif istable(data)
	% User input was a .msa table
	axHandle = localplotfunction(data);
	plotDetails(axHandle)
else
	error('Input must be a file name (e.g., ''file1.msa'') or a table of x-ray energies produced from the read_msa() function.')
end
end % End main function

%
% Local functions
%
function plt = localplotfunction(data_table)
  % Determine the number of existing xray spectra in the current figure
    cf = gcf;
    areas = findobj(cf,'Type','Area');
    num_spectra = length(areas);
  % Define color order and color index
    cmap=colormap("lines");
    if num_spectra >= 1
     ci = cmap(num_spectra+1,:);
    else
     ci = cmap(1,:);
    end
  % Generate visualization
	plt = area(data_table.keV,data_table.Counts,'LineWidth',0.9,...
        'EdgeColor',ci,...
        'FaceColor',ci,'FaceAlpha',0.5);
end
function plotDetails(figHandle)
	ylabel('Counts','FontWeight','bold')
	xlabel('keV','FontWeight','bold')
	xlim([0,15])
	set(gca,'TickDir','out','YGrid','on','YMinorTick','on','YMinorGrid','on','MinorGridLineStyle','-.','MinorGridAlpha',0.1)
	box off
	fontname(gcf,'Default')
	fontsize(gcf,12,"points")
	ax = ancestor(figHandle, 'axes');
    ax.YAxis.Exponent = 0;
	f = gcf;
	f.Units = 'pixels';
	f.Position = [488 242 640 360]; % 16:9 aspect ratio
	f.Name = 'Xray Plot';
end