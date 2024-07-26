function [data,metadata] = read_msa(filename)
%Read EMSA spectral data files (.msa)
%
%Syntax
% READ_MSA(filename)
% data = READ_MSA(filename)
% [~,metadata] = READ_MSA(filename)
%
%Input
% filename : (string) name of file on the current path (ex. 'file1.msa')
%
%Outputs
% data : Nx2 table with variables 'keV' and 'Counts'
% metadata : (optional) Nx2 cell array containing file metadata
%
%Examples
% % Read x-ray energy data
% READ_MSA('file1.msa')
%
% % View metadata for 'file2.msa'
% [~,md] = READ_MSA('file2.msa')
%
% % Note that the output of the 2nd command can also be achieved by:
% md = get_msa_metadata('file2.msa')
%
%See also
% GET_MSA_METADATA

% Copyright ©Austin M. Weber 2024

%
% Begin function body
%
if isstring(filename)
    filename = char(filename);
else
    if ~ischar(filename)
        error('The input must be a string. For example: read_msa(')
    end
end
if ~strcmp(filename(end-3:end),'.msa')
    filename = [filename '.msa'];
end
if exist(filename, 'file') ~= 2
    error_string = ['The input ''' sprintf('%s',filename) ''' does not exist on the current path.'];
    error(error_string)
end

% Retrieve the file metadata
metadata = get_msa_metadata(filename); % Function included with the
% EDS Classification for MATLAB package

% Extract important metadata keys
md_keys = metadata(:,1);
npoints_idx = contains(md_keys,'NPOINTS'); % Number of datapoints
xunits_idx = contains(md_keys,'XUNITS'); % keV or eV
datatype_idx = contains(md_keys,'DATATYPE'); % X and Y data? Or X data only?
xperchan_idx = contains(md_keys,'XPERCHAN'); % X-ray channel spacing interval
offset_idx = find(contains(md_keys,'OFFSET'),1); % Offset in the X data
choffset_idx = contains(md_keys,'CHOFFSET'); % Channel offset

% Extract the metadata values
md_values = metadata(:,2);
datatype = md_values(datatype_idx);
npoints = str2double(cell2mat(md_values(npoints_idx)));
xunits = md_values(xunits_idx);
offset = str2double(cell2mat(md_values(offset_idx)));
xperchan = str2double(cell2mat(md_values(xperchan_idx)));
choffset = str2double(cell2mat(md_values(choffset_idx)));

% Import numeric data as a table
if strcmp(datatype,'Y')
    % MSA file only contains intensity data; need to generate
    % array of corresponding x-ray wavelengths.
    if strcmpi(xunits,'kev')
        kev = zeros(npoints,1);
        kev(1) = offset;
        kev(2:end) = (offset + (1:npoints-1) .* xperchan);
    else
        % Assumes the units are electron volts (ev)
        ev = zeros(npoints,1);
        ev(1) = offset;
        ev(2:end) = (offset + (1:npoints-1) .* xperchan);
        kev = ev ./ 1000;
    end
    % Get numeric data
    counts = readmatrix(filename,'FileType','text');
    if size(counts,2) > 1
	    counts = reshape(counts',[],1);
    end
	counts = rmmissing(counts);
    if choffset > 0
        kev(1:choffset) = [];
        counts(1:choffset) = [];
    end
    % Combine everything into a table
    data = array2table([kev counts],'VariableNames',{'keV','Counts'});
    
elseif strcmp(datatype,'XY')
    data = readmatrix(filename,'FileType','text');
    data = rmmissing(data);
    kev = data(:,1);
    counts = data(:,2);
    if ~strcmpi(xunits,'kev')
        % Assumes the units are electron volts (eV) and converts to keV
        kev = kev ./ 1000;
    end
    data = array2table([kev counts],'VariableNames',{'keV','Counts'});
    
else
    error('MSA file has an unknown datatype.');
end

% END MAIN FUNCTION
end