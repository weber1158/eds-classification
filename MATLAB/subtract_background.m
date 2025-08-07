function [new_data,figHandle] = subtract_background(data,varargin)
%Subtract the background radiation (Bremsstrahlung) from an EDS spectrum
%
%Syntax
% SUBTRACT_BACKGROUND(data)
% SUBTRACT_BACKGROUND(data,Name=Value)
% new_data = SUBTRACT_BACKGROUND(data)
% [~,figHandle] = SUBTRACT_BACKGROUND(data)
%
%
%Inputs
% data (Required) :: {Table or Char} An EDS data table produced by the read_msa
%                                    function OR the name of a spectral file 
%                                    (.msa or .emsa) on the search path.
%
%Name-Value Pairs
% Degree :: {Numeric} The degree of the polynomial. Default=10
% MinSeparation :: {Numeric} The minimum separation between peaks (in keV).
%                            Default=0.13
% SmoothingFactor :: {Numeric} The smoothing parameter. Default=15
%
%
%Outputs
% new_data :: {Table} Background-subtracted data with columns: keV and Counts.
% figHandle :: {matlab.ui.Figure} Visualization of the background subtraction
%
%
%Example
% filename = 'file1.msa';
% data = read_msa(filename);
% [data_bs,fig] = SUBTRACT_BACKGROUND(data,Degree=9,SmoothingFactor=10);
%
%See also
% read_msa, xray_plot

% Copyright 2025 Austin M. Weber

% Default conditions
default_degree = 10;
default_minSep = 0.13;
default_smooth = 15;

% Define validation functions
data_valFun   = @(x) istable(x) | ischar(x);
degree_valFun = @(x) isnumeric(x) & isscalar(x);
minSep_valFun = @(x) isnumeric(x) & isscalar(x);
smooth_valFun = @(x) isnumeric(x) & isscalar(x);

% Input parsing
parser = inputParser();
addRequired(parser,'data',data_valFun);
addParameter(parser,'Degree',default_degree,degree_valFun);
addParameter(parser,'MinSeparation',default_minSep,minSep_valFun);
addParameter(parser,'SmoothingFactor',default_smooth,smooth_valFun);
parse(parser,data,varargin{:});
degree = parser.Results.Degree;
minSep = parser.Results.MinSeparation;
smooth = parser.Results.SmoothingFactor;

if degree < 0
  degree = abs(degree);
  warning('Polynomial degree cannot be negative. Absolute value used instead.')
elseif degree == 0
  error('Polynomial degree cannot be zero.')
end
if minSep <= 0
  error('MinSeparation must be greater than zero. Default=0.13.')
end
if smooth <= 1
  error('SmoothingFactor must be a positive integer greater than 1. Default=15.')
end

%
% Smooth the data
%
if ischar(data)
  spectrum = read_msa(data);
  counts_smooth = movmean(spectrum.Counts, smooth);
  spectrum.Counts = counts_smooth;
  data_smooth = spectrum;
else
  counts_smooth = movmean(data.Counts, smooth);
  data.Counts = counts_smooth;
  data_smooth = data;
end

%
% Perform background subtraction
%
  % Extract x and y data
  x = data_smooth.keV;
  y = data_smooth.Counts;

  % Get local minima values
  min_idx = islocalmin(y,...
                       'MinSeparation',minSep,...
                       'SamplePoints',x);
  loc_mins_x = x(min_idx);
  loc_mins_y = y(min_idx);

  % Fit a polynomial model to the local minima (from x=0 to x=10 keV)
  stop_idx = find(round(loc_mins_x)==10,1);
  loc_mins_x_stop = loc_mins_x(1:stop_idx);
  loc_mins_y_stop = loc_mins_y(1:stop_idx);
  C = polyfit(loc_mins_x_stop,loc_mins_y_stop,degree);

  % Apply model to x data and subtract results from original y data,
  % setting all values x>9 equal to zero to prevent the polynomial from
  % curving upward as x approaches infinity
  y_modeled = polyval(C,x);
  idx9 = find(round(x)==9);
	y_modeled(idx9(1):end) = 0;
  y_background_subtracted = y - y_modeled;

  % Adjust background-subtracted y data so that negative values are set to 0
  negative_idx = y_background_subtracted < 0;
  y_background_subtracted(negative_idx) = 0;

  % Create table for output
  new_data = array2table([x,y_background_subtracted],...
    'VariableNames',{'keV','Counts'});

%
% Produce visualization for the background subtraction
%
if nargout == 2
  % Create figure
	figHandle = figure;
  tiledlayout(3,1)
  nexttile

  % 1st subplot: Original data with local minima identified
  xray_plot(data);
  ylim(gca,[0,prctile(y,98)]) % Zoom in witin the 98th percentile
  hold on
	  plot(loc_mins_x,loc_mins_y,'-.r') % Overlay local minima
  hold off
  legend(gca,'Original Data','Local Minima','Location','northeast');

  nexttile
  % 2nd subplot: Polynomial fitted to the local minima
  plot(loc_mins_x,loc_mins_y,'-.r')
  xlim(gca,[0,10])
  ylim(gca,[0,max(loc_mins_y)])
  xlabel('keV','FontWeight','bold')
  ylabel('Counts','FontWeight','bold')
  hold on
	  model_fit = polyval(C,loc_mins_x(1:stop_idx));
	  plot(loc_mins_x(1:stop_idx),model_fit,'-g') % Overlay the polynomial model
  hold off
  set(gca,'TickDir','out','YGrid','on',...
    'YMinorTick','on','YMinorGrid','on',...
    'MinorGridLineStyle','-.','MinorGridAlpha',0.1)
  box off
  legend('Local Minima',[num2str(degree) '^\circ Polynomial'],...
    'Location','northeast');

  nexttile
  % 3rd subplot: Background-subtracted data
  plt3 = area(new_data.keV,new_data.Counts,...
      'LineWidth',0.9,...
      'FaceAlpha',0.5);
  plt3.FaceColor = 'm';
  plt3.EdgeColor = 'm';
  ylabel('Counts','FontWeight','bold')
  xlabel('keV','FontWeight','bold')
  xlim([0,15])
  set(gca,'TickDir','out','YGrid','on',...
    'YMinorTick','on','YMinorGrid','on',...
    'MinorGridLineStyle','-.','MinorGridAlpha',0.1)
  box off
  legend('Background Subtracted Data',...
    'Location','northeast');
  ax = ancestor(plt3, 'axes');
  ax.YAxis.Exponent = 0;

  % Reposition figure, adjust fonts, modify aspect ratio
  f=gcf;
  fontname(f,'Default')
  fontsize(f,12,"points")
  f.Units='pixels';
  f.Position=[488 100 640 650];
end

end