classdef Spectrum < matlab.graphics.chartcontainer.ChartContainer
%X-ray energy spectrum plot
%
%SYNTAX
% plt = Spectrum(x,y,varargin)
%
%
%INPUTS
% x {(:,1) double} :: X-ray energy channels in units of keV
% y {(:,1) double} :: X-ray counts for each channel in 'x'
% varargin         :: (Optional) Name-Value pairs; mostly compatible with
%                     the MATLAB base function area(x,y,varargin)
%
%OUTPUT
% plt {1x1 Spectrum} :: Axes handle to the Spectrum chart object
%
%
%METHODS (Functions)
% addSpectrum(x,y,varargin)
%
%   DESCRIPTION
%   Overlay a new spectrum over the original Spectrum object. Optional
%   name-value arguments are mostly compatible with the base function 
%   area(x,y).
%
%
% removeSpectrum(varargin)
%
%   DESCRIPTION
%   Deletes the most recent spectrum overlay. Specify 'all' as the only
%   input to delete all spectra overlays, or specify which spectra you wish
%   to delete by passing an index vector. For example, executing the line
%   plt.removeSpectrum([1 2]) will delete the first- and second-most recent
%   spectra overlays. The original Spectrum object cannot be deleted using
%   this method.
%
%
% normalizeSpectrum()
%
%   DESCRIPTION
%   Requires no inputs. Normalizes the y-axis so that the range is [0 1].
%   This makes it much easier to compare multiple spectra, but please note
%   that this action is not reversible.
%
%
% addXrayLabels(varargin)
%
%   DESCRIPTION
%   Labels the most prominent peaks in the Spectrum with the corresponding
%   element (e.g., C, O, Al, Si, Fe, etc.). Input argument is optional.
%
%   Name-value     Default    Description
%   ======================================================================
%   Prominence        90      Relative height of major peaks (percentile).
%                             In other words, you are setting the minimum
%                             prominence of the height of the peaks you
%                             want to label. You can also think of
%                             prominence as the sensitivity of the
%                             labeling algorithm. The higher the
%                             prominence, the more intense the peaks have
%                             to be for the algorithm to label them. 
%
%   Marker           'none'   Add markers to each major peak. Accepts any
%                             combination of a single character marker
%                             style and a single character color code. For
%                             example, 's' will plot square markers at each
%                             major peak while 'sr' will plot red square
%                             markers at each major peak.
%
%   MarkerSize         4      Size of the markers.
%
%   MarkerFaceColor  'none'   Specifies a fill color for your marker.
%                             All basic color options are accepted,
%                             including RGB triplets and hexadecimals.
%   ______________________________________________________________________
%
%
% removeXrayLabels()
%
%   DESCRIPTION
%   Deletes x-ray labels in the Spectrum object. Requires no inputs.
%
%
%EXAMPLE 1 - Plot spectral data for an albite mineral standard
% ab = eds_read('albtie.msa');
% plt = Spectrum(ab.Energy, ab.Counts)
%
%
%EXAMPLE 2 - Label the most prominent characteristic x-rays in a Spectrum
% kln = eds_read('kaolinite.msa');
% plt = Spectrum(kln.Energy, kln.Counts, 'FaceColor', 'k');
% plt.addXrayLabels();
%
%
%EXAMPLE 3 - Same as Example 2, but without assigning the Spectrum to a
%variable and include square red markers with the x-ray labels.
% kln = eds_read('kaolinite.msa');
% Spectrum(kln.Energy, kln.Counts).addXrayLabels('marker','sr');
%
%
%See also
% eds_read

%
% Copyright 2026 Austin M. Weber
%

%=========================================================================
%%%
%%% BEGIN CLASS DEFININITION BODY
%%%
%=========================================================================

%
% Class properties
%
properties
  Energy (:,1) double
  Counts (:,1) double
  LineWidth (1,1) double = 1
  FaceAlpha (1,1) double = 0.1
  FaceColor
  EdgeColor
end
properties(Access = private,Transient,NonCopyable)
  AreaObject (1,1) matlab.graphics.chart.primitive.Area
end

%
% Public Methods
%
methods
  function obj = Spectrum(x,y,varargin)
  % Spectrum object constructor
    arguments
      x (:,1) double = NaN
      y (:,1) double = NaN
    end
    arguments (Repeating)
      varargin
    end
    args = {'Energy', x, 'Counts', y};
    args = [args varargin];
    obj@matlab.graphics.chartcontainer.ChartContainer(args{:});
  end

  function ax = getSpectrumAxes(obj)
  % Get current Spectrum axes [gca does not work for some reason]
    ax = getAxes(obj);
  end

  function addSpectrum(obj,x,y,varargin)
  % Overlay a new spectrum onto the existing Spectrum object
    arguments
      obj (1,1) Spectrum
      x (:,1) double
      y (:,1) double
    end
    arguments (Repeating)
      varargin
    end
    % Append new area chart to axes
    ax = getAxes(obj);
    num_axes = length(findobj(ax.Children,'Type','Area')); % For determining series index
    hold(ax, 'on');
    A=area(ax, x, y, ...
      'LineWidth',1,...
      'FaceAlpha',0.1,...
      'SeriesIndex',num_axes+1,...
      varargin{:});
    hold(ax, 'off');
  
    % Paint edge line color the same as the face color if the user does not
    % specify the edge line color
    edgeColorIdx = any(ismember(varargin,'EdgeColor'));
    if ~edgeColorIdx
      A.EdgeColor = A.FaceColor;
    end
  end

  function normalizeSpectrum(obj)
  % Normalize y-axis from 0 to 1
    arguments
      obj (1,1) Spectrum
    end
    ax = getAxes(obj);
    AreaObjects = findobj(ax.Children,'Type','Area'); % N×1 Area

    num_area_objects = length(AreaObjects);

      for a = 1:num_area_objects
        X = AreaObjects(a).XData;
        Y = AreaObjects(a).YData;
        start_idx = find(X>=0.01,1); % Find index for eV = 10
        Y_max = max(Y(start_idx:end));
        Y_normalized = Y ./ Y_max;
        AreaObjects(a).YData = Y_normalized;
      end

    ylabel(ax, 'Counts (normalized)')
    p = ancestor(ax, 'axes');
    p.YAxis.TickLabelFormat = '%g';
  end

  function removeSpectrum(obj,varargin)
  % Deletes most recent spectrum overlay
    arguments
      obj (1,1) Spectrum
    end
    arguments (Repeating)
      varargin
    end
    if nargin > 2
      error('Too many input arguments!')
    end
    ax = getAxes(obj);
    AreaObjects = findobj(ax.Children,'Type','Area'); % N×1 Area
    num_area_objects = length(AreaObjects);

    % User provides no input
    if nargin == 1
      if num_area_objects == 1
        warning(['Issue with the removeSpectrum() operation: '...
                 'Could not find a spectrum to remove '...
                 '(other than the parent Spectrum object). '...
                 'Operation canceled.'])
      else
        delete(AreaObjects(1))
      end
    end

    % User provides an input
    if nargin == 2
      % Check whether input was numeric or char
      if isa(varargin{1},'char')
        if strcmpi(varargin{1},'all')
          delete(AreaObjects(1:end-1))
        else
          error(['Invalid input for the removeSpectrum() operation. '...
            'Your options are: no input arguments, the character '...
            'vector ''all'', or a vector of positive integers.'])
        end

      elseif isa(varargin{1},'double')
        if ~isvector(varargin{1})
          error(['Invalid input for the removeSpectrum() operation. '...
            'Your options are: no input arguments, the character '...
            'vector ''all'', or a vector of positive integers.'])
        end
        if any(varargin{1} < 1)
          error(['Invalid input for the removeSpectrum() operation. '...
            'Your options are: no input arguments, the character '...
            'vector ''all'', or a vector of positive integers.'])
        end
        if any(varargin{1} == num_area_objects)
          idx = find(varargin{1} == num_area_objects,1);
          varargin{1}(idx) = [];
          warning(['Ignoring index %d because this would delete the '...
                   'the original Spectrum object!'], num_area_objects)
        end
        if any(varargin{1} > num_area_objects)
          if isscalar(varargin{1})
            error(['Invalid input for the removeSpectrum() operation. '...
                   'Value exceeds the total number of objects in the '...
                   'chart!'])
          else
            idx = varargin{1} > num_area_objects;
            varargin{1}(idx) = [];
            warning(['Ignoring index values that exceed the total '...
                     'number of objects in the chart.'])
          end
        end
        delete(AreaObjects(varargin{1}))

      else
        error(['Invalid input for the removeSpectrum() operation. '...
               'Your options are: no input arguments, the character '...
               'vector ''all'', or a vector of positive integers.'])
      end
    end
  end

  function addXrayLabels(obj, varargin)
    ax = getAxes(obj);

    mfc_valid_fcn = @(x) (strcmpi(x,'none') || strcmpi(x,'auto')) || ...
                         (ischar(x)&&isscalar(x)&&contains('wkrgbcym',x))||...
                         (isnumeric(x) && isequal(length(x),3)) || ...
                         (contains(x,'#') && isequal(length(x),7));
                         % i.e., must equal: 'none', a color shorthand, an
                         % rgb triplet, or a hexadecimal code.


    p = inputParser;
    addParameter(p, 'min_sep',   0.1,  @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'prominence', 90,  @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'marker',     '',  @(x) ischar(x));
    addParameter(p, 'MarkerSize',  4,  @(x) isnumeric(x) && isscalar(x));
    addParameter(p, 'MarkerFaceColor',...
                               'none', mfc_valid_fcn);

    parse(p, varargin{:});
    minSep = p.Results.min_sep;
    prom   = p.Results.prominence;
      prom = prctile(obj.Counts, prom);
    marker = p.Results.marker;
    mkr_sz = p.Results.MarkerSize;
    mkr_fc = p.Results.MarkerFaceColor;

    xrayEnergyTable = readtable('XrayEnergyTable.csv',...
                                'Delimiter','comma',...
                                'ReadVariableNames',true,...
                                'VariableNamingRule','preserve');
     element_names= xrayEnergyTable.Element;
     xray_lines = [3 5 6 11]; % 3:11 for all x-ray lines
                              % [3 5 6 11] for Ka, Kb, La, and Ma only
     energy_vals  = xrayEnergyTable{:,xray_lines};
     line_names   = xrayEnergyTable.Properties.VariableNames(xray_lines);

    function peak_energy = find_major_peaks(energies,counts,...
                                                 min_separation,prominence)
      idx = islocalmax(counts,...
                      'MinSeparation',min_separation,...
                      'SamplePoints',energies,...
                      'MinProminence',prominence);
    	x_max = energies(idx);
    	y_max = counts(idx);
    	% Delete any values less than 0.025 keV because some EDS software
      % insert a fake peak at 0 keV (i.e., the "zero-strobe peak") which
      % the software uses to correct for electronic drift. See Goldstein et
      % al. (2018, Chapter 17, p. 242) for additional details. 
      % DOI:10.1007/978-1-4939-6676-9
    	energy_idx = x_max <= 0.025;
    	x_max(energy_idx) = [];
    	y_max(energy_idx) = [];
    	% Create table of local maxima energies
    	peak_energy = array2table([x_max, y_max],...
                                'VariableNames',{'Energy','Counts'});
    end

    peak_energy = find_major_peaks(obj.Energy, obj.Counts, minSep, prom);
    num_major_peaks = length(peak_energy.Counts);
    original_labels = cell([num_major_peaks 1]);

    max_peak_energy = max(peak_energy.Counts);
    padding = max_peak_energy*1.02 - max_peak_energy;

    hold(ax, 'on')
    for k = 1:num_major_peaks
      e_k = peak_energy.Energy(k);
      dist_from_each_char_xray = abs(energy_vals - e_k);
      [smallest_dist, line_idx] = min(dist_from_each_char_xray(:));

      if ~isempty(smallest_dist) && smallest_dist <= minSep
        [row_idx, col_idx] = ind2sub(size(energy_vals), line_idx);
        element_abbreviation = element_names{row_idx};
        line_label = line_names{col_idx};
        label = sprintf('%s %s', element_abbreviation, line_label);
        label = strrep(label,'a1','_α');
        label = strrep(label,'b1','_β');
      else
        label = '';
      end
      original_labels{k} = char(label);

      if ~isempty(label)
        y_value = peak_energy.Counts(k);
        text(ax, e_k, y_value+padding, label,...
             'HorizontalAlignment','center',...
             'VerticalAlignment','middle',...
             'FontSize',8)
        if ~isempty(marker)
          plot(ax, e_k, y_value, marker, ...
            'LineStyle', 'none', ...
            'MarkerSize', mkr_sz,...
            'MarkerFaceColor',mkr_fc);
        end
      end
    end
    hold(ax, 'off')
    
    for j = 1:num_major_peaks
      label_n = original_labels{j};
      if ~contains(label_n,'K')
        % Label is an L- or M- line; check to see if there is a
        % corresponding K- line. If not, replace the L- or M-line label
        % with the closest K- line.
        e_j = peak_energy.Energy(j);
        dist_from_Kalpha_lines = abs(energy_vals(:,1) - e_j);
        row_idx = dist_from_Kalpha_lines <= minSep;
        if sum(row_idx) == 1
          % There is a corresponding K-line. Overwrite the previous label.
          new_element = element_names{row_idx};
          new_label = sprintf('%s K_α',new_element);

          if sum(contains(original_labels, new_element)) == 0
            hold(ax, 'on')
            % Delete previous text object
            text_objects = findobj(ax,'Type','Text');
            for t = 1:length(text_objects)
              if strcmp(text_objects(t).String, label_n)
                delete(text_objects(t))
              end
            end
            % textObj = text_objects();
            % delete(textObj);
            % Add new text object
            y_value = peak_energy.Counts(j);
            text(ax, e_j, y_value+padding, new_label,...
              'HorizontalAlignment','center',...
              'VerticalAlignment','middle',...
              'FontSize',8)
          end
        end
      end
    end

  end

  function removeXrayLabels(obj)
    ax = getAxes(obj);
    TextObjects = findobj(ax.Children,'Type','Text');
    MarkerObjects = findobj(ax.Children,'Type','Line');
    delete(TextObjects)
    delete(MarkerObjects)
  end

%
% End Public Methods
%
end

%
% Private Methods
%
methods(Access = protected)
  function setup(obj,varargin)
    ax = getAxes(obj);
    obj.AreaObject = area(ax,NaN,NaN,...
                          'LineWidth',1,...
                          'FaceAlpha',0.1,...
                          'SeriesIndex',1);
  end

  function update(obj)
    obj.AreaObject.XData = obj.Energy;
    obj.AreaObject.YData = obj.Counts;

    % Parse optional name-value args
    obj.AreaObject.LineWidth = obj.LineWidth;
    obj.AreaObject.FaceAlpha = obj.FaceAlpha;

    % Parse optional name-value args
    if ~isempty(obj.FaceColor)
        obj.AreaObject.FaceColor = obj.FaceColor;
    end
    if ~isempty(obj.EdgeColor)
        obj.AreaObject.EdgeColor = obj.EdgeColor;
    else
        obj.AreaObject.EdgeColor = obj.AreaObject.FaceColor;
    end

    % Add axes labels
    ax = getAxes(obj);
    xlabel(ax,'Energy (keV)')
    ylabel(ax,'Counts')

    % Set ticks
    p = ancestor(ax, 'axes');
    p.YAxis.Exponent = 0;
    p.YAxis.TickLabelFormat = '%g';
    p.XLim = [0 10];
  end

%
% End Private Methods
%
end

%=========================================================================
%%%
%%% END CLASS DEFININITION BODY
%%%
end
%=========================================================================
