function [data,h] = subtract_background(filename,varargin)
%Subtract background (Bremsstrahlung) radiation from EDS data
%
%DESCRIPTION
% Fits a high-degree polynomial or spline curve to local minima in an EDS
% spectrum and subtracts this curve (ideally representing the
% Bremsstrahlung x-ray counts) from the remaining spectrum (therefore
% leaving behind just the characteristic x-ray peaks).
%
% A smoothing operation is applied to the spectrum prior to background
% subtraction in order to reduce the number of local minima produced by
% noise in the spectrum. If the user has access to SIGNAL PROCESSING
% TOOLBOX then the smoothing operation is carried out via Savitzky-Golay
% filtering, which preserves the intensities of the peaks. Otherwise, a
% simple running average is used to smooth noise in the spectrum (by
% default, the running average operation uses a sliding window of 15
% channels. This can be adjusted by setting the `SmoothingFactor=value`
% argument).
%
% If the user has CURVE FITTING TOOLBOX installed, a smoothing spline model
% is fit to the local minima and this curve (representing the background)
% is then subtracted from the spectrum. Otherwise, the local minima are fit
% using a polynomial model, which the user can adjust by setting the
% `Degree=value` argument (the default polynomial degree is `Degree=10`).
%
%
%SYNTAX
%  data = SUBTRACT_BACKGROUND(filename,varargin)
% [~,h] = SUBTRACT_BACKGROUND(filename)
%
%INPUT
% filename {char} :: Name of an EDS spectral data file (.msa / .emsa)
%
%OUTPUT
% data {table}    :: Background-subtracted EDS data with columns for Energy
%                    (in units of keV) and Counts.
%
% h {Figure}      :: Handle to figure object.
%
%
%NAME-VALUE ARGUMENTS
% Degree          :: Degree of the polynomial. Default=10
% MinSeparation   :: Minimum separation between peaks. This parameter
%                    defines the minimum distance between local minima.
%                    Default=0.13 (keV)
% SmoothingFactor :: Smoothing factor. Default=15
%
%
%EXAMPLE
% filename = 'quattro_cemas.msa';
% [data,h] = SUBTRACT_BACKGROUND(filename, Degree=9, SmoothingFactor=10);
%
%
%See also
% net_intensity, peak_intensity, eds_read

% Copyright 2026 Austin M. Weber

% Default conditions
default_degree = 10;   % Used if curve fitting toolbox is not installed
default_minSep = 0.13; % Used for defining spread of local minima
default_smooth = 15;   % Used if signal processing toolbox is not installed

% Define validation functions
file_valFun   = @(x) ischar(x);
degree_valFun = @(x) isnumeric(x) & isscalar(x);
minSep_valFun = @(x) isnumeric(x) & isscalar(x);
smooth_valFun = @(x) isnumeric(x) & isscalar(x);

% Input parsing
parser = inputParser();
addRequired(parser,'filename',file_valFun);
addParameter(parser,'Degree',default_degree,degree_valFun);
addParameter(parser,'MinSeparation',default_minSep,minSep_valFun);
addParameter(parser,'SmoothingFactor',default_smooth,smooth_valFun);
parse(parser,filename,varargin{:});
degree = parser.Results.Degree;
minSep = parser.Results.MinSeparation;
smooth_factor = parser.Results.SmoothingFactor;

if degree < 0
  degree = abs(degree);
  warning('Polynomial degree cannot be negative. Absolute value used instead.')
elseif degree == 0
  error('Polynomial degree cannot be zero.')
end
if minSep <= 0
  error('MinSeparation must be greater than zero. Default=0.13.')
end
if smooth_factor <= 1
  error('SmoothingFactor must be a positive integer greater than 1. Default=15.')
end


%
% Load the spectrum
%
spectrum = eds_read(filename);

%
% Check if SIGNAL PROCESSING TOOLBOX is installed
% 
installations = ver;
installation_names = [installations.Name];
sig_proc_toolbox = 'signal processing toolbox';
spt_is_installed = contains(lower(installation_names), sig_proc_toolbox);
  %
  % Smooth the data
  %
  if spt_is_installed
    % Smooth the data with the Savitsky-Golay algorithm
    frame_len = 5; % i.e. Number of points in the sliding window
    poly_deg = 3;  % i.e. Degree of the local polynomial
    spectrum.Counts = sgolayfilt(spectrum.Counts, poly_deg, frame_len);
  else
    % Smooth the data with a moving average
    spectrum.Counts = movmean(spectrum.Counts, smooth_factor);
  end

%
% Perform background subtraction
%
  % Extract x and y data
  x = spectrum.Energy';
  y = spectrum.Counts';

  % Get local minima values
  min_idx = islocalmin(y,...
                       'MinSeparation',minSep,...
                       'SamplePoints',x);
  loc_mins_x = x(min_idx);
  loc_mins_y = y(min_idx);

  % Fit a polynomial model to the local minima (from x=0 to x=10 keV)
  stop_idx = find(round(loc_mins_x)==10,1);
  if ~isempty(stop_idx)
    loc_mins_x_stop = loc_mins_x(1:stop_idx);
    loc_mins_y_stop = loc_mins_y(1:stop_idx);
  else
    % stop_idx is empty
    loc_mins_x_stop = loc_mins_x;
    loc_mins_y_stop = loc_mins_y;
  end
  C = polyfit(loc_mins_x_stop,loc_mins_y_stop,degree);

  % Apply model to x data and subtract results from original y data,
  % setting all values x>9 equal to zero to prevent the polynomial from
  % curving upward as x approaches infinity
   %
   % Check if CURVE FITTING TOOLBOX is installed
   % 
   cur_fit_toolbox = 'curve fitting toolbox';
   cft_is_installed = contains(lower(installation_names), cur_fit_toolbox);
   if cft_is_installed % i.e., CURVE FITTING TOOLBOX
    f_curve = fit(loc_mins_x_stop,loc_mins_y_stop,"smoothingspline");
    y_modeled = f_curve(x);
    y_background_subtracted = y - y_modeled;
   else
    y_modeled = polyval(C,x);
    idx9 = find(round(x)==9);
	  y_modeled(idx9(1):end) = 0;
    y_background_subtracted = y - y_modeled;
   end

  % Adjust background-subtracted y data so that negative values are set to 0
  negative_idx = y_background_subtracted < 0;
  y_background_subtracted(negative_idx) = 0;

  % Create table for output
  data = array2table([x,y_background_subtracted],...
    'VariableNames',{'Energy','Counts'});

%
% Produce visualization for the background subtraction
%
  if nargout == 2
    % Create figure
	  h = figure;
    tiledlayout(3,1)
    nexttile
  
    % 1st subplot: Original data with local minima identified
    spectrum.plot_spectrum();
    ylim(gca,[0,prctile(y,98)]) % Zoom in witin the 98th percentile
    hold on
	    plot(loc_mins_x,loc_mins_y,'-or',...
        'MarkerFaceColor','auto','LineWidth',0.5,...
        'MarkerSize',3) % Overlay local minima
    hold off
    legend(gca,'Original Data (Smoothed)','Local Minima',...
      'Location','northeast',...
      'IconColumnWidth',14);
  
    nexttile
    % 2nd subplot: Polynomial fitted to the local minima
    plot(loc_mins_x,loc_mins_y,'-or','LineWidth',0.5,...
      'MarkerFaceColor','auto','MarkerSize',3)
    xlim(gca,[0,10])
    ylim(gca,[0,max(loc_mins_y)])
    xlabel('Energy (keV)')
    ylabel('Counts')
    hold on
      if cft_is_installed % i.e., CURVE FITTING TOOLBOX
        plot(x,y_modeled,'k-','LineWidth',1)
        legend('Local Minima','Spline Fit',...
          'IconColumnWidth',14)
      else
	      model_fit = polyval(C,loc_mins_x(1:stop_idx));
	      plot(loc_mins_x(1:stop_idx),model_fit,'-k',...
          'LineWidth',1) % Overlay the polynomial model
        legend('Local Minima',[num2str(degree) '^\circ Polynomial'],...
          'Location','northeast','IconColumnWidth',14);
      end
    hold off
  
    nexttile
    % 3rd subplot: Background-subtracted data
    plt3 = area(data.Energy,data.Counts,...
        'LineWidth',1,...
        'FaceAlpha',0.1,...
        'FaceColor',[0.0660 0.4430 0.7450],...
        'EdgeColor',[0.0660 0.4430 0.7450]);
    ylabel('Counts')
    xlabel('Energy (keV)')
    xlim([0,10])
    legend('Background Subtracted Data',...
      'Location','northeast','IconColumnWidth',14);
    ax = ancestor(plt3, 'axes');
    ax.YAxis.Exponent = 0;
  end

end