classdef eds_read
%Custom MATLAB class for reading/visualizing EDS spectral data
%
%SYNTAX
% spec = EDS_READ(filename)
%
%INPUT
% filename {char} :: Name of .msa or .emsa file
%
%OUTPUT
% data {EDS_READ} :: An eds_read object with the following properties:
%                 
%                  Property    Class    Description
%                  ===================================================
%                  FileName    char     Name of the .msa file
%                  Metadata    struct   Metadata contained in the file
%                  Energy      double   X-ray energy bins (keV)
%                  Counts      double   Number of counts per energy bin
%
%
%METHODS (Functions)
% plot_spectrum :: Quick plot of counts versus energy; If you want a 
%                  spectrum with more features, type: help Spectrum
%
%
%EXAMPLE 1 - Read an x-ray energy file for albite and view its metadata
% file = 'C:\Users\JohnDoe\Data\albite.msa';
% ab = EDS_READ(file);
% ab.MetaData
%
%EXAMPLE 2 - Make a quick visualization of an x-ray energy spectrum
% nist610 = EDS_READ('610_glass_standard.msa');
% nist610.plot_spectrum('LineWidth',2,'FaceAlpha',0.5);
%
%
%See also
% Spectrum, eds_classification 

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
  FileName   (1,:) char
  Metadata   struct = struct()
  Energy     (1,:) double
  Counts     (1,:) double
end

%
% Public Methods
%
methods
  function obj = eds_read(filename)
    %
    % Constructor
    %
    arguments
      filename (1,:)   char
    end

    %
    % Input parsing
    %
    [~,~,ext] = fileparts(filename); % Gets file extension
    if ~ismember(lower(ext), {'.msa', '.emsa'})
      error(['File must have a .msa or .emsa extension, ' ...
             'but the file extension provided was "%s".'], ext);
    end
    if ~isfile(filename)
      error(['Unable to locate file: %s\nPlease check spelling '...
            'and make sure the file is on the search path.'], filename);
    end

    %
    % Define and assign object properties
    %
    obj.FileName = filename;

    % Read energy file
    fid = fopen(filename, 'rt');
    if fid == -1
      error('Failed to open file: %s', filename);
    end
    close_file_when_function_ends = onCleanup(@() fclose(fid));
    [meta, dataLines] = eds_read.read_file(fid);
    obj.Metadata = meta;
    [obj.Energy, obj.Counts] = ...
      eds_read.parse_numeric_data(dataLines, meta);
    if isempty(obj.Energy) && ~isempty(obj.Counts)
      % That is, the Energy data were not stored in the .msa file and need
      % to be reconstructed from the OFFSET and XPERCHAN fields given
      % in the metadata.
      obj.Energy = obj.reconstruct_xray_energy_channels();
    end
    % Convert all energy values to keV
    obj.Energy = obj.Energy * obj.energyUnitToKeV();

    % Convert to column vectors
    obj.Energy = obj.Energy';
    obj.Counts = obj.Counts';

  %  
  % End constructor  
  %
  end

  %
  % Additional methods
  %
  function h = plot_spectrum(obj,varargin)
    h = area(obj.Energy, obj.Counts, ...
      'LineWidth',1,...
      'FaceAlpha',0.1,...
      varargin{:});
    C = h.FaceColor;
    h.EdgeColor=C;
    xlabel(gca,'Energy (keV)')
    ylabel(gca,'Counts')
    xlim(gca,[0 10])
    ax = ancestor(h, 'axes');
    ax.YAxis.Exponent = 0;
    ax.YAxis.TickLabelFormat = '%g';
  end

%
% End Public Methods
%
end

%
% Private Methods
%
methods (Access = private)
  function energy = reconstruct_xray_energy_channels(obj)
    n = numel(obj.Counts);
    xperchan = obj.get_numeric_metadata('XPERCHAN', 1);
    offset   = obj.get_numeric_metadata('OFFSET', 0);
    energy = offset + (0:n-1)' * xperchan;
  end

  function val = get_numeric_metadata(obj, key, defaultVal)
    fn = fieldnames(obj.Metadata);
    match = fn(startsWith(fn, key, 'IgnoreCase', true));
    if ~isempty(match)
      v = str2double(obj.Metadata.(match{1}));
      if ~isnan(v)
        val = v;
        return
      end
    end
    val = defaultVal;
  end

  function factor = energyUnitToKeV(obj)
    % Calculates correction factor to convert energy units into keV. Uses
    % the XUNITS field in the metadata to determine this. If the units
    % are already in keV, then factor is set to 1 (the default).
    xunits = '';
    if isfield(obj.Metadata, 'XUNITS')
      xunits = lower(strtrim(obj.Metadata.XUNITS));
    end

    if contains(xunits, 'kev')
      factor = 1;
    elseif contains(xunits, 'ev')
      factor = 1e-3;
    elseif contains(xunits, 'mev')
      % I have never actually seen this in an .msa file, but just in case I
      % am including an elseif statement to check.
      factor = 1e3;
    else
      warning(['Missing or unexpected XUNITS ("%s") in the metadata; '...
        'assuming the energy data are in units of keV.'], xunits);
      factor = 1;
    end
  end

end

methods (Static, Access = private)
  function [meta, dataLines] = read_file(fid)
    meta = struct();
    dataLines = {};
    inData = false;

    % Test for end of file (feof)
    while ~feof(fid)
      rawLine = fgetl(fid); % Read line from file
      if ~ischar(rawLine)
        break
      end
      line = strtrim(rawLine); % Trims whitespace

      if inData
        % That is, "if we have reached the data portion of the
        % the file where the line does not start with '#'"
        if isempty(line)
          continue
        end
        if startsWith(line, '#ENDOFDATA', 'IgnoreCase', true)
          break
        end
        dataLines{end+1} = line;
        continue
      end

      if isempty(line) || ~startsWith(line, '#')
        % That is, "if the line is empty, or if the line is a
        % metdata line that begins with '#'"
        continue
      end

      % For some reason, some metadata lines may start with one
      % or more '#' symbols, and so the following cmd will trim
      % any number of leading '#' symbols from the metadata line
      content = strtrim(regexprep(line, '^#+', ''));

      if startsWith(content, 'SPECTRUM', 'IgnoreCase', true)
        % That is, "if we have reached the last metadata line
        % before the data section, which is identified by the 
        % 'SPECTRUM' key word"
        inData = true;
        continue
      end

      % Extract value(s) from the metadata line
      colonIdx = strfind(content, ':');
      if isempty(colonIdx)
        continue
      end
      key = strtrim(content(1:colonIdx(1)-1));
      value = strtrim(content(colonIdx(1)+1:end));
      fieldName = matlab.lang.makeValidName(key);
      meta.(fieldName) = value; % Add to output struct
    end % End of while loop
  end % End of read_file function

  function [energy, counts] = parse_numeric_data(dataLines, meta)
    % This part is pretty tricky. I have examined numerous .msa and .emsa
    % files from multiple SEMs that use different software, and what I have
    % found is that different software programs save the numeric data
    % (i.e., the Energy and Counts data) in vastly different formats. Some
    % software programs save the counts data in a single column with no
    % column for energy, other programs save the energy data and the counts
    % data as separate columns, and one program that I have found saves the
    % count data across FOUR separate columns... Luckily, each of these
    % programs is fairly consistent in the way that they hardcode the meta
    % data, and the metadata elucidates how to unpack the numeric data.
    % That is, using the NCOLUMNS and DATATYPE fields from the metadata
    % I have been able to program this function to predict the formatting
    % of the numeric data, and using the OFFSET and XPERCHAN fields it
    % is possible to reshape the data and to reconstruct the original x-ray
    % energy channels.
    allVals = [];
    for i = 1:numel(dataLines)
      parts = strtrim(strsplit(dataLines{i}, ',')); % Trims trailing commas
      nums = str2double(parts);
      nums = nums(~isnan(nums));
      allVals = [allVals, nums];
    end
    allVals = allVals(:);

    dataType = '';
    if isfield(meta, 'DATATYPE')
      dataType = upper(strtrim(meta.DATATYPE));
    end

    if strcmp(dataType, 'XY')
      % Numeric data are provided for both Energy and Counts (I will never
      % understand why this is not the only way to store the data)
      if mod(numel(allVals), 2) ~= 0
        warning('Odd number of values found for XY data; dropping the last one.');
        allVals(end) = [];
      end
      pairs = reshape(allVals, 2, [])';
      energy = pairs(:, 1);
      counts = pairs(:, 2);
    else
      % DATATYPE is 'Y' (or something else/nothing). Every value
      % is a count, regardless of how many are in a line.
      energy = [];
      counts = allVals;
    end
  end

end
%
% End Private Methods
%

%=========================================================================
%%%
%%% END CLASS DEFININITION BODY
%%%

end
%=========================================================================