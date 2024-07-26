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
% % Plot multiple spectra on the same plot with normalized units
% f1 = read_msa('file1.msa');
% f2 = read_msa('file2.msa');
% f1.Counts = normalize(f1.Counts,'Range',[0 1]);
% f2.Counts = normalize(f2.Counts,'Range',[0 1]);
% figure
% plt = XRAY_PLOT(f2);
% hold on
%  XRAY_PLOT(f1);
% hold off
% legend('F2','F1')
%
% See also
%  xray_peak_label, read_msa

% Copyright ©Austin M. Weber 2024


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
	xlim([0,10]), xticks(0:1:10)
	set(gca,'TickDir','out','YGrid','on','YMinorTick','on','YMinorGrid','on','MinorGridLineStyle','-.','MinorGridAlpha',0.1)
	box off
	fontname(gcf,'Default')
	fontsize(gcf,12,"points")
	ax = ancestor(figHandle, 'axes');
    ax.YAxis.Exponent = 0;
    xtickformat('%.0f')
	f = gcf;
	f.Units = 'inches';
	f.Position = [5,4,6,3];
	f.Name = 'Xray Plot';
end