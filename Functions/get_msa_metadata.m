function md = get_msa_metadata(filename)
%Extract metadata from EMSA spectral data files (.msa)
%
%SYNTAX
% md = get_msa_metadata(filename)
%
%DESCRIPTION
% The output of this function is equivalent to the second output of the
% read_msa() function (which is the preferred method of getting these 
% results).
%
%INPUT
% filename : Name of file including the .msa extenstion in single quotes
%
%OUTPUT
% md : Cell array of metadata
%
%EXAMPLES
% md = get_msa_metadata('file1.msa')
%
% % Or,
% [~,md] = read_msa('file1.msa')
%
%
%See also
% read_msa

% Copyright ©Austin M. Weber 2024

% Read the text file into a cell array of strings
fid = fopen(filename, 'r');
data = textscan(fid, '%s', 'Delimiter', '\n');
fclose(fid);
lines = data{1};

% Define the regular expression pattern to match metadata lines
metadata_pattern = '^#\s*([^:]+):\s*(.+)$';

% Initialize a cell array to store metadata
metadata = cell(0);

% Loop through each line in the file
for i = 1:numel(lines)
    % Check if the line matches the metadata pattern
    matches = regexp(lines{i}, metadata_pattern, 'tokens');
    if ~isempty(matches)
        % Extract metadata and store it
        metadata = [metadata; matches{1}];
    end
end

md = metadata;

end